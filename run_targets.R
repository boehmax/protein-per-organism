#!/usr/bin/env Rscript
# run_targets.R - Helper script to run the targets pipeline

# Check if targets package is installed
if (!require("targets", quietly = TRUE)) {
  message("Installing targets package...")
  install.packages("targets", repos = "https://cloud.r-project.org/")
}

library(targets)

# Display help information
cat("==========================================================\n")
cat("  Protein per Organism - Targets Pipeline Runner\n")
cat("==========================================================\n\n")

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) > 0 && args[1] %in% c("-h", "--help", "help")) {
  cat("Usage: Rscript run_targets.R [command]\n\n")
  cat("Commands:\n")
  cat("  (no args)   - Run the complete pipeline\n")
  cat("  visualize   - Visualize the pipeline graph\n")
  cat("  manifest    - Show the pipeline manifest\n")
  cat("  outdated    - Show which targets are outdated\n")
  cat("  clean       - Clean all targets\n")
  cat("  help        - Show this help message\n\n")
  cat("Examples:\n")
  cat("  Rscript run_targets.R\n")
  cat("  Rscript run_targets.R visualize\n")
  cat("  Rscript run_targets.R outdated\n\n")
  cat("For more information, see: https://docs.ropensci.org/targets/\n")
  quit(save = "no")
}

# Execute the requested command
if (length(args) == 0) {
  cat("Running the complete targets pipeline...\n\n")
  tar_make()
  cat("\n✓ Pipeline completed successfully!\n")
  cat("Check the output/ directory for results.\n")
} else if (args[1] == "visualize") {
  cat("Generating pipeline visualization...\n\n")
  if (!require("visNetwork", quietly = TRUE)) {
    message("Installing visNetwork package for visualization...")
    install.packages("visNetwork", repos = "https://cloud.r-project.org/")
  }
  tar_visnetwork()
} else if (args[1] == "manifest") {
  cat("Pipeline manifest:\n\n")
  print(tar_manifest())
} else if (args[1] == "outdated") {
  cat("Checking for outdated targets...\n\n")
  outdated <- tar_outdated()
  if (length(outdated) == 0) {
    cat("✓ All targets are up to date!\n")
  } else {
    cat("The following targets are outdated:\n")
    print(outdated)
  }
} else if (args[1] == "clean") {
  cat("Cleaning all targets...\n")
  response <- readline(prompt = "Are you sure you want to clean all targets? (y/n): ")
  if (tolower(response) == "y") {
    tar_destroy()
    cat("✓ All targets cleaned.\n")
  } else {
    cat("Clean cancelled.\n")
  }
} else {
  cat("Unknown command:", args[1], "\n")
  cat("Use 'Rscript run_targets.R help' for usage information.\n")
}
