# Code created by Codex with GTP-5.4. Here is the prompt
# > I need you to create a small experiment for me. Using the 
# > [ModelMeaslesMixing.R](R/ModelMeaslesMixing.R) model, create a simple
# > population that has five different heterogenous-sized groups, set an 
# > overall vaccination rate of 80%, and create a random contact matrix. Then, 
# > I need you to run 200 simulations using run_multiple for 90 days each. Here 
# > is the change, use a population of 10,000; 50,000; and 100,000; each time 
# > calibrating the model as I do in the example [test-calibration.R](inst/
# > tinytest/test-calibration.R). I need to check whether I get the same 
# > average outbreak size across settings. You can store this under `playgroud/`
#
# The code was checked and edited by a human user.

get_script_path <- function() {
  script_arg <- grep(
    "^--file=",
    commandArgs(trailingOnly = FALSE),
    value = TRUE
  )

  if (length(script_arg) > 0L) {
    return(normalizePath(sub("^--file=", "", script_arg[1L])))
  }

  if (!is.null(sys.frames()[[1L]]$ofile)) {
    return(normalizePath(sys.frames()[[1L]]$ofile))
  }

  normalizePath(
    file.path(getwd(), "playgroud", "mixing_population_scale_experiment.R"),
    mustWork = FALSE
  )
}

make_group_sizes <- function(population_size, weights) {
  group_sizes <- floor(population_size * weights)
  group_sizes[length(group_sizes)] <-
    population_size - sum(group_sizes[-length(group_sizes)])

  as.integer(group_sizes)
}

make_random_contact_matrix <- function(n_groups, seed) {
  set.seed(seed)

  contact_matrix <- matrix(
    stats::runif(n_groups^2, min = 0.1, max = 1.25),
    nrow = n_groups
  )

  contact_matrix <- (contact_matrix + t(contact_matrix)) / 2
  diag(contact_matrix) <- diag(contact_matrix) + 1.5

  round(contact_matrix * 6, digits = 3)
}

compute_exceedance_probabilities <- function(outbreak_sizes, thresholds) {
  probabilities <- vapply(
    thresholds,
    function(threshold) mean(outbreak_sizes > threshold),
    numeric(1L)
  )

  stats::setNames(
    as.list(probabilities),
    paste0("prob_outbreak_gt_", thresholds)
  )
}

calibrate_contact_matrix <- function(
  contact_matrix,
  target_rep_number,
  infectious_period_days,
  transmission_prob
) {
  objective <- function(scale_factor) {
    reproduction_number <- epiworldR::compute_reproduction_number(
      contact_matrix = contact_matrix * scale_factor,
      transmission_prob = transmission_prob,
      infectious_period_days = infectious_period_days,
      infectiousness = NULL,
      susceptibility = NULL,
      check_reciprocity = FALSE
    )$R

    (reproduction_number - target_rep_number)^2
  }

  stats::optimize(
    f = objective,
    interval = c(0, 1000)
  )$minimum
}

run_experiment <- function(
  population_size,
  group_weights,
  contact_matrix,
  target_r0,
  transmission_prob,
  infectious_period_days,
  vaccinated_prop,
  nsims,
  ndays,
  seed,
  nthreads = 2L,
  result_nthreads = 1L,
  outbreak_thresholds = c(5L, 10L, 20L, 50L, 100L, 200L)
) {
  group_sizes <- make_group_sizes(population_size, group_weights)
  group_ids <- paste0("group_", seq_along(group_sizes))

  calibration_factor <- calibrate_contact_matrix(
    contact_matrix = contact_matrix,
    target_rep_number = target_r0,
    infectious_period_days = infectious_period_days,
    transmission_prob = transmission_prob
  )

  calibrated_contact_matrix <- contact_matrix * calibration_factor

  model <- measles::ModelMeaslesMixing(
    n = population_size,
    prevalence = 1 / population_size,
    transmission_rate = transmission_prob,
    vax_efficacy = 0.97,
    contact_matrix = calibrated_contact_matrix,
    hospitalization_rate = 0.05,
    hospitalization_period = 7,
    days_undetected = 2,
    prop_vaccinated = vaccinated_prop
  )

  epiworldR::add_entities_from_dataframe(
    model = model,
    entities = data.frame(
      id = group_ids,
      size = group_sizes
    ),
    col_name = "id",
    col_number = "size",
    as_proportion = FALSE
  )

  epiworldR::run_multiple(
    model,
    ndays = ndays,
    nsims = nsims,
    seed = seed,
    saver = epiworldR::make_saver("outbreak_size", "reproductive"),
    nthreads = nthreads
  )

  # Keep simulation threads at 2, but read results with a single thread.
  # In some environments the parallel result reader cannot open a PSOCK socket.
  results <- epiworldR::run_multiple_get_results(
    model,
    nthreads = result_nthreads
  )

  outbreak_size <- results$outbreak_size
  final_outbreak_size <- outbreak_size[
    outbreak_size$date == max(outbreak_size$date),
    c("sim_num", "outbreak_size")
  ]
  final_outbreak_size <- final_outbreak_size[order(final_outbreak_size$sim_num), ]
  final_outbreak_size$population_size <- population_size
  final_outbreak_size$attack_rate <-
    final_outbreak_size$outbreak_size / population_size

  reproductive <- results$reproductive
  index_case_rt <- reproductive[
    reproductive$source != -1 & reproductive$source_exposure_date == 0,
    c("sim_num", "rt")
  ]
  exceedance_probabilities <- compute_exceedance_probabilities(
    outbreak_sizes = final_outbreak_size$outbreak_size,
    thresholds = outbreak_thresholds
  )

  summary_row <- data.frame(
    population_size = population_size,
    nsims = nsims,
    ndays = ndays,
    prop_vaccinated = vaccinated_prop,
    target_r0 = target_r0,
    transmission_prob = transmission_prob,
    infectious_period_days = infectious_period_days,
    calibration_factor = calibration_factor,
    mean_index_case_rt = mean(index_case_rt$rt),
    mean_outbreak_size = mean(final_outbreak_size$outbreak_size),
    sd_outbreak_size = stats::sd(final_outbreak_size$outbreak_size),
    median_outbreak_size = stats::median(final_outbreak_size$outbreak_size),
    mean_attack_rate = mean(final_outbreak_size$attack_rate),
    q025_outbreak_size = stats::quantile(
      final_outbreak_size$outbreak_size,
      probs = 0.025,
      names = FALSE
    ),
    q975_outbreak_size = stats::quantile(
      final_outbreak_size$outbreak_size,
      probs = 0.975,
      names = FALSE
    ),
    exceedance_probabilities,
    check.names = FALSE
  )

  group_sizes_df <- data.frame(
    population_size = population_size,
    group = group_ids,
    size = group_sizes,
    weight = group_weights
  )

  list(
    summary = summary_row,
    simulation = final_outbreak_size,
    group_sizes = group_sizes_df,
    calibrated_contact_matrix = calibrated_contact_matrix
  )
}

script_path <- get_script_path()
project_root <- dirname(dirname(script_path))
output_dir <- file.path(project_root, "playgroud")

if (!requireNamespace("epiworldR", quietly = TRUE)) {
  stop("The epiworldR package must be installed to run this experiment.")
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

if (requireNamespace("measles", quietly = TRUE)) {
  library(measles)
} else {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    stop(
      "Install either the measles package or devtools to run this experiment."
    )
  }

  devtools::load_all(project_root, quiet = TRUE)
}

group_weights <- c(0.05, 0.09, 0.16, 0.28, 0.42)
population_sizes <- c(20000L, 100000L, 200000L, 400000L) / 2L

target_r0 <- 8
transmission_prob <- 0.2
infectious_period_days <- 4
vaccinated_prop <- 0.90
nsims <- 2000L
ndays <- 90L
nthreads <- 4L
result_nthreads <- 1L
outbreak_thresholds <- c(5L, 10L, 20L, 50L, 100L)
contact_matrix_seed <- 41051L
simulation_seed <- 91300L

base_contact_matrix <- make_random_contact_matrix(
  n_groups = length(group_weights),
  seed = contact_matrix_seed
)
group_ids <- paste0("group_", seq_along(group_weights))

message("Running mixing-model scale experiment...")

experiment_results <- lapply(seq_along(population_sizes), function(i) {
  population_size <- population_sizes[i]

  message("  - population size: ", format(population_size, big.mark = ","))

  run_experiment(
    population_size = population_size,
    group_weights = group_weights,
    contact_matrix = base_contact_matrix,
    target_r0 = target_r0,
    transmission_prob = transmission_prob,
    infectious_period_days = infectious_period_days,
    vaccinated_prop = vaccinated_prop,
    nsims = nsims,
    ndays = ndays,
    seed = simulation_seed + i - 1L,
    nthreads = nthreads,
    result_nthreads = result_nthreads,
    outbreak_thresholds = outbreak_thresholds
  )
})

summary_results <- do.call(
  rbind,
  lapply(experiment_results, function(x) x$summary)
)
simulation_results <- do.call(
  rbind,
  lapply(experiment_results, function(x) x$simulation)
)
group_size_results <- do.call(
  rbind,
  lapply(experiment_results, function(x) x$group_sizes)
)

contact_matrix_results <- cbind(
  group_from = group_ids,
  stats::setNames(as.data.frame(base_contact_matrix), group_ids)
)

calibrated_contact_matrix_results <- do.call(
  rbind,
  lapply(seq_along(experiment_results), function(i) {
    population_size <- population_sizes[i]
    calibrated_contact_matrix <- experiment_results[[i]]$calibrated_contact_matrix

    cbind(
      population_size = population_size,
      group_from = group_ids,
      stats::setNames(as.data.frame(calibrated_contact_matrix), group_ids)
    )
  })
)

write.csv(
  summary_results,
  file = file.path(output_dir, "mixing_population_scale_summary.csv"),
  row.names = FALSE
)
write.csv(
  simulation_results,
  file = file.path(output_dir, "mixing_population_scale_by_simulation.csv"),
  row.names = FALSE
)
write.csv(
  group_size_results,
  file = file.path(output_dir, "mixing_population_scale_group_sizes.csv"),
  row.names = FALSE
)
write.csv(
  contact_matrix_results,
  file = file.path(output_dir, "mixing_population_scale_contact_matrix.csv"),
  row.names = FALSE
)
write.csv(
  calibrated_contact_matrix_results,
  file = file.path(output_dir, "mixing_population_scale_calibrated_contact_matrix.csv"),
  row.names = FALSE
)

saveRDS(
  list(
    summary = summary_results,
    simulations = simulation_results,
    group_sizes = group_size_results,
    base_contact_matrix = base_contact_matrix,
    calibrated_contact_matrices = lapply(
      experiment_results,
      function(x) x$calibrated_contact_matrix
    ),
    config = list(
      population_sizes = population_sizes,
      group_weights = group_weights,
      target_r0 = target_r0,
      transmission_prob = transmission_prob,
      infectious_period_days = infectious_period_days,
      prop_vaccinated = vaccinated_prop,
      nsims = nsims,
      ndays = ndays,
      nthreads = nthreads,
      result_nthreads = result_nthreads,
      outbreak_thresholds = outbreak_thresholds,
      contact_matrix_seed = contact_matrix_seed,
      simulation_seed = simulation_seed
    )
  ),
  file = file.path(output_dir, "mixing_population_scale_results.rds")
)

message("\nSummary results:")
print(summary_results, row.names = FALSE)
