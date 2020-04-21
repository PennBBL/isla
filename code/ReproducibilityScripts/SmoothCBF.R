#' ---
#' title: "Smoothing"
#' author: "Tinashe M. Tapera"
#' date: "2019-02-04"
#' ---

#+ setup
suppressPackageStartupMessages({
  library(fslr)
  library(dplyr)
  library(tidyr)
  library(stringr)
})
set.seed(1000)
print(paste("Updated:", format(Sys.time(), '%Y-%m-%d')))

#' This script is used to smooth the CBF maps for both radius of 3 and 4. See here: code/sandbox/final_code_Kristin/flameo/flameo_orig_smooth.R

print("Gathering data for cbf (size = 3)")

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

print("Gathering data for cbf (size = 4)")

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
