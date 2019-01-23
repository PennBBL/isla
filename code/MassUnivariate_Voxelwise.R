#' ---
#' title: "Multivariate Voxelwise `gam()`"
#' author: "Tinashe M. Tapera"
#' date: "2018-01-16"
#' output:
#'   github_document:
#'     html_preview: false
#' ---

#+ setup
suppressPackageStartupMessages({
  library(tidyr)
  library(dplyr)
  library(knitr)
  library(magrittr)
  library(stringr)
})
set.seed(1000)
print(paste("Updated:", format(Sys.time(), '%Y-%m-%d ')))
#' # How to Run Voxelwise `gam()` with `voxelwrapper`
#' ## Set up

#' Here we demonstrate the multivariate voxelwise `gam()` for `CBF ~s(age)+s(age,by=sex)+sex+pcaslRelMeanRMSMotion` for a small sample, using ISLA-corrected CBF data. We walk through the arguments of the voxelwrapper, creating each within this notebook.
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

islaCBF_path <- file.path("/data/jux/BBL/projects/isla/data/coupling_maps_PMACS/gmd_cbf_size3")

cbfMotion <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/n1601_PcaslQaData_20170403.csv") %>%
  select(scanid, pcaslRelMeanRMSMotion) %>%
  mutate(scanid = as.character(scanid))

all_scans <-
  list.files(islaCBF_path,  pattern = "mixture_cbf_isla.nii.gz", recursive = TRUE, full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "[:digit:]{4,}")) %>%
  select(scanid, everything())

covariates_df <-
  all_scans %>%
  left_join(demographics, by = "scanid") %>%
  left_join(cbfMotion, by = "scanid") %>%
  mutate(include = 1) %>%  # for inclusion critera
  filter(scanid != 4445) %>% #broken nifti for this scanID
  filter(complete.cases(.)) %>%
  sample_n(30)

if (all(purrr::map_lgl(covariates_df$path, file.exists))){
  #ensures that all of the paths are correctly written

  covariates <- "/data/jux/BBL/projects/isla/data/sandbox/voxelwise_gam_covariates.rds" %T>%
    saveRDS(covariates_df, .)

}
#'
#+ eval=FALSE
# not run
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
my_formula <- "~s(age)+s(age,by=sex)+sex+pcaslRelMeanRMSMotion"

#' `padjust`
#' The output type for the model
padjust <- "fdr"

#' The remaining arguments, `splits`, `residual`, and `numberofcores`, `skipfourD`, and `residual`,all remain default.
#'
#' ## Running the Model
#'
#' We will call the voxelwrapper from outside the command line like so:

#+ run
# worlds longest single line of code please dont judge me
run_command <- sprintf("Rscript /data/jux/BBL/projects/isla/code/voxelwiseWrappers/gam_voxelwise.R -c %s -o %s -p %s -m %s -s %s -i %s -u %s -f %s -a %s -n 5 -s 0 -k 10", covariates, output, image_paths, mask, smoothing, inclusion, subjID, my_formula, padjust)
#not run
#system(run_command)

#' ## Results

#' The results can be found in the `../results/` directory, where the images of the final voxelwise tests are output as nifti's.
