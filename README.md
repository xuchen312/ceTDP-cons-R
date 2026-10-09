# ceTDP-cons-R

**Stage 2 R script** for computing conservative lower bounds on the TDP (True Discovery Proportion) using **ceTDP-cons**.

## Installation

No additional packages required. Download `lb.R` and `lb_funs.R` and run directly. Or clone the repository:

```bash
git clone https://github.com/xuchen312/ceTDP-cons-R.git
cd ceTDP-cons-R
```
  
## General Usage

### Command line (bash)
  
```bash
Rscript lb.R -k <k-value> -i <file> -o <output>
```

### In R/RStudio

```r
source("lb_funs.R")
```

Then use the R functions directly (see Example below)
  
## Arguments
  
- `-k` - Minimum significant cluster size **minus 1** (output from Stage 1)

- `-i` - Either:

    - A directory containing multiple input files (CSV/TSV), or

    - A single file with voxel coordinates (x, y, z) for a single region (derived from Stage 1)

- `-o` - (Optional) Output CSV file name. If provided, results are saved to the specified file.

### Input file format

CSV or TSV format with `x`, `y`, `z` columns:

```
x,y,z
26,72,24
27,72,24
30,72,24
...
```
  
## Output

A table summarizing the estimated lower bounds for each input region:

- `File`: input file name
- `Size`: |S| = number of voxels in the region (row count)
- `TDN`: TDN (True Discovery Number) lower bound
- `TDP`: corresponding TDP lower bound = TDN / |S|

If `-o` is specified, the table is also saved as a CSV file.

## Examples

### Command line example

```bash
Rscript lb.R -k 20 -i xyz.csv -o results
```

Output (printed to terminal, and saved to `results.csv`):

```
=================== Results ===================
    File Size  TDN       TDP
 xyz.csv 7689 3635 0.4727533
===============================================
```

## R usage example

```r
# load functions
source("lb_funs.R")

# read data
input <- read.csv("xyz.csv")
k <- 20

# compute lower bounds
rk <- RK(k)
tdn <- lower_bound3(input, rk, k)
tdp <- tdn / nrow(input)

# print results
cat("TDN:", tdn, "\nTDP:", tdp, "\n")
```

## Any questions or bugs?

Please contact Xu Chen at xuchen312@gmail.com.
