#' ---
#' title: "Spatial Correlation Density Plots"
#' author: "Tinashe M. Tapera"
#' date: "2018-02-05"
#' ---

#+ setup
suppressPackageStartupMessages({
  library(tidyr, quietly = TRUE)
  library(dplyr, quietly = TRUE)
  library(knitr, quietly = TRUE)
  library(ggplot2, quietly = TRUE)
  library(magrittr, quietly = TRUE)
  library(stringr, quietly = TRUE)
  library(oro.nifti, quietly = TRUE)
  library(purrr, quietly = TRUE)
  library(ggpubr, quietly = TRUE)
})
set.seed(1000)
SAMPLE <- TRUE # sample the full data if memory is limited e.g. not in qsub
#' # Introduction
#' Here we visualise the relationship between GMD values and CBF, Alff, and Reho in the PNC sample for ISLA. We append to the previous work by calculating spatial correlation per participant and then plotting these correlation coefficients. First, how to load the images and calculate spatial correlation.

# relevant paths
gmd_path <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/voxelwiseMaps_gmd")
cbf_path <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf")
mask_path <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/gm10pcalcovemask.nii.gz")

# one gmd image
gmd_example <-
  list.files(gmd_path,
    pattern = regex("[^tmp.nii.gz]"),
    full.names = TRUE)[2] %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  select(scanid, everything())

# the same scanid's cbf image
cbf_example <-
  list.files(cbf_path,
    pattern = regex("[^tmp.nii.gz]"),
    full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  select(scanid, everything()) %>%
  filter(scanid == gmd_example$scanid)

#' Here we use the script `spatialcorr.sh` to calculate the spatial correlation for a participant's two images.
spatial_corr_script <- "/data/jux/BBL/projects/isla/code/Correlations/spatialcorr.sh"
system(sprintf("%s %s %s %s",
  spatial_corr_script,
  cbf_example$path,
  gmd_example$path,
  mask_path),
  intern = TRUE)

We can wrap this in an internal function like so:

calculate_spatial_corr <- function(img1_path, img2_path, mask_path){

  spatial_corr_script <- "/data/jux/BBL/projects/isla/code/Correlations/spatialcorr.sh"
  spatial_r <- system(sprintf("%s %s %s %s",
    spatial_corr_script,
    img1_path,
    img2_path,
    mask_path),
    intern = TRUE) %>%
    as.numeric()

  spatial_r
}

calculate_spatial_corr(cbf_example$path, gmd_example$path, mask_path)





#' ---
#' Session info:
print(R.version.string)
print(paste("Last Run:", format(Sys.time(), "%Y-%m-%d")))
