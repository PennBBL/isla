#' ---
#' title: "Multivariate Voxelwise `gam()`"
#' author: "Tinashe M. Tapera"
#' date: "2018-01-16"
#' ---

#+ setup
suppressPackageStartupMessages({
  library(tidyr)
  library(dplyr)
  library(knitr)
  library(magrittr)
})
set.seed(1000)
print(paste("Updated:", format(Sys.time(), '%Y-%m-%d ')))

#' # How to Run Voxelwise `gam()` with `voxelwrapper`
#' ## Set up

#' Here we demonstrate the multivariate voxelwise `gam()` for `CBF ~ s(age, by=sex)`, first for raw CBF data, and then, for ISLA-corrected CBF data. We walk through the arguments of the voxelwrapper, creating each within this notebook.
#'
#' 1. `covariates`
#'
#' Here we read in the demographic data and the paths to the CBF images, and write this out to an RDS file in the sandbox:

demographics <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/demographics/n1601_demographics_go1_20161212.csv") %>%
  as_tibble() %>%
  mutate(sex = as.ordered(as.factor(sex)),
         age = ageAtScan1 / 12,
         scanid = as.character(scanid))

voxelwise_path <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf")

all_scans <-
  list.files(voxelwise_path) %>%
  tibble(path = .) %>%
  separate(path, into = c("scanid"), remove = FALSE, extra = "drop") %>%
  mutate(path = paste(voxelwise_path,path, sep = "/")) %>%
  select(scanid, everything())

covariates_df <-
  all_scans %>%
  left_join(demographics, by = "scanid") %>%
  mutate(include = 1) %>%  # for inclusion critera
  filter(scanid != 4445) #broken nifti for this scanID

if (all(purrr::map_lgl(covariates_df$path, file.exists))){
  #ensures that all of the paths are correctly written

  covariates <- "/data/jux/BBL/projects/isla/data/sandbox/voxelwise_gam_covariates.rds" %T>%
    saveRDS(covariates_df, .)

}
#'
#+ eval=FALSE
head(covariates_df) %>% kable()
#'
#' `output`
#' Quickly assign an output directory

output <- file.path("/data/jux/BBL/projects/isla/results/")

#' `imagepaths`
#' Next we find the voxelwise CBF data, and create a spreadsheet of input paths:

image_paths <- "path"

#' `mask`
#' Set the path to the mask image

mask <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/gm10pcalcovemask.nii.gz")

#' `smoothing`
#' The smoothing in sigmas required for the fourd image. Recommended default to 0

smoothing <- 0

#' `inclusion`
#' Whether or not there are some exclusion criteria; currently none

inclusion <- "include"

#' `subjID`
#' The name of the column denoting the subject ID

subjID <- "scanid"

#' `formula`
#' The formula call, as a string. Note that there needn't be any spaces
my_formula <- "\"~s(age,by=sex)\""

#' The remaining arguments, `padjust`, `splits`, `residual`, and `numberofcores`, `skipfourD`, and `residual`,all remain default.
#'
#' ## Running the Model
#'
#' We will call the voxelwrapper from outside the session, but build it in here first using string formatting and system calls, since this is a notebook.

#+ run
# worlds longest single line of code dont judge me
run_command <- sprintf("Rscript /data/jux/BBL/projects/isla/code/voxelwiseWrappers/gam_voxelwise.R -c %s -o %s -p %s -m %s -s %s -i %s -u %s -f %s -n 5 -s 0 -k 10", covariates, output, image_paths, mask, smoothing, inclusion, subjID, my_formula)

cat(run_command, file="/data/jux/BBL/projects/isla/code/sandbox/run_gam_voxelwise.sh")

#' You can then execute the script in the shell.
