GMD Correlation Plots
================
Tinashe M. Tapera
2018-02-04

``` r
suppressPackageStartupMessages({
  library(fslr)
  library(dplyr)
  library(tidyr)
  library(stringr)
})
set.seed(1000)
print(paste("Updated:", format(Sys.time(), '%Y-%m-%d')))
```

    ## [1] "Updated: 2019-02-13"

This script is used to smooth the CBF maps for both radius of 3 and 4. See here: code/sandbox/final\_code\_Kristin/flameo/flameo\_orig\_smooth.R

``` r
print("Gathering data for cbf (size = 3)")
```

    ## [1] "Gathering data for cbf (size = 3)"

``` r
smoothed_dir <- "/data/jux/BBL/projects/isla/data/rawSmoothedCBF_3"
if(!dir.exists(smoothed_dir)){
  dir.create(smoothed_dir, recursive = TRUE)
}

y_path <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf")

radius <- 3
if(radius==4){
    sigma = radius / 2.35482004503
}
if(radius==3){
    sigma = radius / 2.35482004503
}

mask <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/gm10pcalcovemask.nii.gz")
print("Running fslsmooth")
```

    ## [1] "Running fslsmooth"

``` r
all_scans <-
  list.files(y_path,  pattern = ".nii.gz", recursive = TRUE, full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  filter(scanid != 4445) %>% #broken nifti for this scanID
  mutate(path = lapply(.$path, function(x) {
                        return_path <- str_extract(x, "(?<=/)[:digit:]{4,}.*") %>%
                          str_replace(., ".nii.gz", "_smoothed.nii.gz") %>%
                          file.path(smoothed_dir,.)
                        fslsmooth(as.character(x), sigma = sigma, mask = mask, outfile = return_path, verbose = FALSE)
                        return(return_path)
                        })
          )

print(sprintf("Done! Smoothed images are in %s", smoothed_dir))
```

    ## [1] "Done! Smoothed images are in /data/jux/BBL/projects/isla/data/rawSmoothedCBF_3"

``` r
print("Gathering data for cbf (size = 4)")
```

    ## [1] "Gathering data for cbf (size = 4)"

``` r
smoothed_dir <- "/data/jux/BBL/projects/isla/data/rawSmoothedCBF_4"
if(!dir.exists(smoothed_dir)){
  dir.create(smoothed_dir, recursive = TRUE)
}

radius <- 4
if(radius==4){
        sigma = radius / 2.35482004503
}
if(radius==3){
        sigma = radius / 2.35482004503
}

print("Running fslsmooth")
```

    ## [1] "Running fslsmooth"

``` r
all_scans <-
  list.files(y_path,  pattern = ".nii.gz", recursive = TRUE, full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  filter(scanid != 4445) %>% #broken nifti for this scanID
  mutate(path = lapply(.$path, function(x) {
                        return_path <- str_extract(x, "(?<=/)[:digit:]{4,}.*") %>%
                          str_replace(., ".nii.gz", "_smoothed.nii.gz") %>%
                          file.path(smoothed_dir,.)
                        fslsmooth(as.character(x), sigma = sigma, mask = mask, outfile = return_path, verbose = FALSE)
                        return(return_path)
                        })
          )
print(sprintf("Done! Smoothed images are in %s", smoothed_dir))
```

    ## [1] "Done! Smoothed images are in /data/jux/BBL/projects/isla/data/rawSmoothedCBF_4"
