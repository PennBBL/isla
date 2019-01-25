#' ---
#' title: "Multivariate Voxelwise `gam()` For Raw vs. ISLA CBF Models"
#' author: "Tinashe M. Tapera"
#' date: "2018-01-23"
#' ---

#+ setup
suppressPackageStartupMessages({
  library(tidyr)
  library(dplyr)
  library(knitr)
  library(ggplot2)
  library(magrittr)
  library(stringr)
  library(oro.nifti)
})
set.seed(1000)
print(paste("Updated:", format(Sys.time(), '%Y-%m-%d ')))
#' # Running All ISLA Models with Voxelwise `gam()`
#' This notebook runs all of the desired ISLA models. See [this notebook](MassUnivariate_Voxelwise.md) for a walkthrough on how it works.

#' 1. islaCBF ~ s(age) + s(age, by=sex) + sex + cbfMotion (size = 3)
demographics <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/demographics/n1601_demographics_go1_20161212.csv") %>%
  as_tibble() %>%
  mutate(sex = as.ordered(as.factor(sex)),
         age = ageAtScan1 / 12,
         scanid = as.character(scanid)) %>%
  select(sex, age, scanid)

y_path <- file.path("/data/jux/BBL/projects/isla/data/coupling_maps_PMACS/gmd_cbf_size3")

cbfMotion <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/n1601_PcaslQaData_20170403.csv") %>%
  select(scanid, pcaslRelMeanRMSMotion) %>%
  mutate(scanid = as.character(scanid))

all_scans <-
  list.files(y_path,  pattern = "mixture_cbf_isla.nii.gz", recursive = TRUE, full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "[:digit:]{4,}")) %>%
  select(scanid, everything())

cbf_sample <-
  read.csv("/data/jux/BBL/projects/isla/data/cbfSample.csv") %>%
  as_tibble() %>%
  transmute(scanid = as.character(scanid))

covariates_df <-
  all_scans %>%
  left_join(demographics, by = "scanid") %>%
  left_join(cbfMotion, by = "scanid") %>%
  inner_join(cbf_sample, by = "scanid") %>%
  mutate(include = 1) %>%  # for inclusion critera
  filter(scanid != 4445) %>% #broken nifti for this scanID
  filter(complete.cases(.))

if (all(purrr::map_lgl(covariates_df$path, file.exists))){
  #ensures that all of the paths are correctly written

  covariates <- "/data/jux/BBL/projects/isla/data/sandbox/isla_cbf3_covariates.rds" %T>%
    saveRDS(covariates_df, .)

}

output <- file.path("/data/jux/BBL/projects/isla/results/islaCBF_3")
image_paths <- "path"
mask <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/gm10pcalcovemask.nii.gz")
smoothing <- 0
inclusion <- "include"
subjID <- "scanid"
my_formula <- "~s(age)+s(age,by=sex)+sex+pcaslRelMeanRMSMotion"
padjust <- "fdr"
run_command <- sprintf("Rscript /data/jux/BBL/projects/isla/code/voxelwiseWrappers/gam_voxelwise.R -c %s -o %s -p %s -m %s -s %s -i %s -u %s -f %s -a %s -n 5 -s 0 -k 10", covariates, output, image_paths, mask, smoothing, inclusion, subjID, my_formula, padjust)

system(run_command)
#' ***
#' 2. islaCBF ~ s(age) + s(age, by=sex) + sex + cbfMotion (size = 4)
demographics <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/demographics/n1601_demographics_go1_20161212.csv") %>%
  as_tibble() %>%
  mutate(sex = as.ordered(as.factor(sex)),
         age = ageAtScan1 / 12,
         scanid = as.character(scanid)) %>%
  select(sex, age, scanid)

y_path <- file.path("/data/jux/BBL/projects/isla/data/coupling_maps_PMACS/gmd_cbf_size4")

cbfMotion <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/n1601_PcaslQaData_20170403.csv") %>%
  select(scanid, pcaslRelMeanRMSMotion) %>%
  mutate(scanid = as.character(scanid))

all_scans <-
  list.files(y_path,  pattern = "mixture_cbf_isla.nii.gz", recursive = TRUE, full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "[:digit:]{4,}")) %>%
  select(scanid, everything())

cbf_sample <-
  read.csv("/data/jux/BBL/projects/isla/data/cbfSample.csv") %>%
  as_tibble() %>%
  transmute(scanid = as.character(scanid))

covariates_df <-
  all_scans %>%
  left_join(demographics, by = "scanid") %>%
  left_join(cbfMotion, by = "scanid") %>%
  inner_join(cbf_sample, by = "scanid") %>%
  mutate(include = 1) %>%  # for inclusion critera
  filter(scanid != 4445) %>% #broken nifti for this scanID
  filter(complete.cases(.))

if (all(purrr::map_lgl(covariates_df$path, file.exists))){
  #ensures that all of the paths are correctly written

  covariates <- "/data/jux/BBL/projects/isla/data/sandbox/islaCBF_4_covariates.rds" %T>%
    saveRDS(covariates_df, .)

}

output <- file.path("/data/jux/BBL/projects/isla/results/islaCBF_4")
image_paths <- "path"
mask <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/gm10pcalcovemask.nii.gz")
smoothing <- 0
inclusion <- "include"
subjID <- "scanid"
my_formula <- "~s(age)+s(age,by=sex)+sex+pcaslRelMeanRMSMotion"
padjust <- "fdr"
run_command <- sprintf("Rscript /data/jux/BBL/projects/isla/code/voxelwiseWrappers/gam_voxelwise.R -c %s -o %s -p %s -m %s -s %s -i %s -u %s -f %s -a %s -n 5 -s 0 -k 10", covariates, output, image_paths, mask, smoothing, inclusion, subjID, my_formula, padjust)

system(run_command)
#' ***
#' 3. rawCBF ~ s(age) +  s(age, by=sex) + sex + cbfMotion (control)
demographics <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/demographics/n1601_demographics_go1_20161212.csv") %>%
  as_tibble() %>%
  mutate(sex = as.ordered(as.factor(sex)),
         age = ageAtScan1 / 12,
         scanid = as.character(scanid)) %>%
  select(sex, age, scanid)

y_path <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf")

cbfMotion <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/n1601_PcaslQaData_20170403.csv") %>%
  select(scanid, pcaslRelMeanRMSMotion) %>%
  mutate(scanid = as.character(scanid))

all_scans <-
  list.files(y_path,  pattern = ".nii.gz", recursive = TRUE, full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=cbf/)[:digit:]{4,}")) %>%
  select(scanid, everything())

cbf_sample <-
  read.csv("/data/jux/BBL/projects/isla/data/cbfSample.csv") %>%
  as_tibble() %>%
  transmute(scanid = as.character(scanid))

covariates_df <-
  all_scans %>%
  left_join(demographics, by = "scanid") %>%
  left_join(cbfMotion, by = "scanid") %>%
  inner_join(cbf_sample, by = "scanid") %>%
  mutate(include = 1) %>%  # for inclusion critera
  filter(scanid != 4445) %>% #broken nifti for this scanID
  filter(complete.cases(.))

if (all(purrr::map_lgl(covariates_df$path, file.exists))){
  #ensures that all of the paths are correctly written

  covariates <- "/data/jux/BBL/projects/isla/data/sandbox/rawcbf_covariates.rds" %T>%
    saveRDS(covariates_df, .)

}

output <- file.path("/data/jux/BBL/projects/isla/results/rawCBF")
image_paths <- "path"
mask <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/gm10pcalcovemask.nii.gz")
smoothing <- 0
inclusion <- "include"
subjID <- "scanid"
my_formula <- "~s(age)+s(age,by=sex)+sex+pcaslRelMeanRMSMotion"
padjust <- "fdr"
run_command <- sprintf("Rscript /data/jux/BBL/projects/isla/code/voxelwiseWrappers/gam_voxelwise.R -c %s -o %s -p %s -m %s -s %s -i %s -u %s -f %s -a %s -n 5 -s 0 -k 10", covariates, output, image_paths, mask, smoothing, inclusion, subjID, my_formula, padjust)

system(run_command)
