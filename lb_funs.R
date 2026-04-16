# ==============================
# Core functions
# ==============================

RK <- function(k, d=3) {
  fdk <- function(k, d) {
    if (d==0 | k==0) {
      0
    } else {
      fk1d <- floor(k^(1/d))
      ldk <- floor((log(k) - d*log(fk1d)) / (log(fk1d+1) - log(fk1d)))
      bdkplus <- (fk1d + 1)^(d-ldk) * (fk1d + 2)^ldk
      bdk <- fk1d^(d-ldk) * (fk1d + 1)^ldk
      bdkplus + fdk(k-bdk, d-1)
    }
  }
  fdks <- sapply(1:k, fdk, d)
  min((fdks - 1:k)/fdks)
}

lower_bound3 <- function(CL, rk, k) {
  
  range_x <- diff(range(CL$x)) + 3
  range_y <- diff(range(CL$y)) + 3
  range_z <- diff(range(CL$z)) + 3
  
  CL = CL$x + range_x * CL$y + range_x * range_y * CL$z
  
  neighbors_x <- rep(0:1, 4)
  neighbors_y <- rep(rep(0:1, each=2), 2)
  neighbors_z <- rep(0:1, each=4)
  neighbors <- neighbors_x + range_x * neighbors_y + range_x * range_y * neighbors_z
  
  CLplus <- function(CL) {
    unique(c(outer(CL, neighbors, "+")))
  }
  
  CLmin <- function(CL) {
    CLrest <- setdiff(CLplus(CL), CL)
    setdiff(CL, unique(c(outer(CLrest, neighbors, "-"))))
  }
  
  CLprune <- function(CL, i) {
    for (j in seq_len(i)) {
      CL <- CLmin(CL)
    }
    for (j in seq_len(i)) {
      CL <- CLplus(CL)
    }
    CL
  }
  
  max_i <- floor(length(CL)^(1/3))
  sV <- length(CL) > k
  for (i in 0:max_i) {
    pruned <- CLprune(CL,i)
    pruned.plus <- CLplus(pruned)
    pruned.rest <- setdiff(pruned.plus, pruned)
    sV <- max(sV, rk * length(pruned.plus) - length(pruned.rest))
  }
  ceiling(sV)
}

# ==============================
# IO / helper functions
# ==============================

parse_input <- function(input_args) {
  files <- unlist(strsplit(input_args, "[, ]+"))
  files <- trimws(files)
  if (length(files)==1 && dir.exists(files)) {
    files <- list.files(files, pattern="\\.csv$", full.names=TRUE)
    if (length(files)==0) stop("No CSV files found in the specified directory.")
  }
  if (!all(file.exists(files))) {
    missing <- files[!file.exists(files)]
    stop(paste("The following files do not exist:", paste(missing, collapse=", ")))
  }
  return(files)
}

get_k <- function(file, k_in=NULL) {
  if (!is.null(k_in)) return(k_in)
  k_ext <- as.numeric(gsub(".*kval([0-9]+)\\.csv", "\\1", basename(file)))
  if (is.na(k_ext)) 
    stop(paste("Cannot extract k-value from file:", file, "\n",
               "Either provide -k argument or ensure filename contains 'kval<number>'"))
  return(k_ext)
}