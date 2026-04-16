#!/usr/bin/env Rscript

if (!requireNamespace("optparse", quietly=TRUE)) 
  install.packages("optparse", repos="https://cloud.r-project.org")
library(optparse)

script_path <- commandArgs(trailingOnly=FALSE)
script_path <- sub("--file=", "", script_path[grep("--file=", script_path)])
script_dir <- dirname(normalizePath(script_path))
source(file.path(script_dir, "lb_funs.R"))

# define command line options
option_list <- list(
  make_option(c("-i","--input"), type="character",
    help="Input cluster information CSV file(s). 
          - Single file: file.csv
          - Multiple files: file1.csv,file2.csv (support comma, space, or mixed usage)
          - Or a directory containing CSV files"
  ),
  make_option(c("-k","--kval"), type="double",
    help="Optional k value. Overrides k from filename (specified as kvalNUMBER)."
  ),
  make_option(c("-o","--output"), type="character", help="Output CSV filename")
)
opt <- parse_args(OptionParser(option_list=option_list))

# check if input is provided
if (is.null(opt$input)) stop("Error: --input must be provided.")

# parse command-line arguments
input_files <- parse_input(opt$input)

# determine k
k_vals <- sapply(input_files, function(f) get_k(f, opt$kval))

# compute ceTDP-cons
if(length(unique(k_vals))==1) {
  k <- k_vals[1]
  rk <- RK(k)
  lbs_list <- lapply(input_files, function(f) {
    cat("Processing: ", f, "\n")
    df <- read.csv(f)
    tdn <- lower_bound3(df, rk, k)
    clz <- dim(df)[1]
    tdp <- tdn / clz
    list(Size=clz, TDN=tdn, TDP=tdp)
  })
} else {
  lbs_list <- mapply(function(f, k) {
    cat("Processing:", f, "with k =", k, "\n")
    df <- read.csv(f)
    rk <- RK(k)
    tdn <- lower_bound3(df, rk, k) 
    clz <- dim(df)[1]
    tdp <- tdn / clz
    list(Size=clz, TDN=tdn, TDP=tdp)
  }, f=input_files, k=k_vals, SIMPLIFY=FALSE)
}

results_df <- do.call(rbind, lapply(seq_along(lbs_list), function(i) {
  df <- as.data.frame(lbs_list[[i]])
  df$File <- basename(input_files[i])
  df
}))
results_df <- results_df[, c("File","Size","TDN","TDP")]

# return output file
if (is.null(opt$output) || opt$output == "") {
  cat("\n=================== Results ===================\n")
  print(results_df, row.names=FALSE)
  cat("===============================================\n\n")
} else {
  output_file <- opt$output
  if (!grepl("\\.[^.]+$", output_file)) {
    output_file <- paste0(output_file, ".csv")
  }
  write.csv(results_df, file=output_file, row.names=FALSE)
  cat("Results saved to:", output_file, "\n")
}
