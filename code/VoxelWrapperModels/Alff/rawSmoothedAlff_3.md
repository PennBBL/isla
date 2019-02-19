Multivariate Voxelwise `gam()`: Raw Smoothed Alff (Size: 3)
================
Tinashe M. Tapera
2019-02-11

NB: This is the script used to run the ISLA models. Please see [this notebook](/data/jux/BBL/projects/isla/code/VoxelWrapperModels/MassUnivariate_Voxelwise.md) for a walk through on how this is constructed.

``` r
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
print(paste("Last Run:", format(Sys.time(), "%Y-%m-%d ")))
```

    ## [1] "Last Run: 2019-02-19 "

`covariates`

``` r
rest_sample <- read.csv("/data/jux/BBL/projects/isla/data/restSample.csv") %>%
  select(-X)

demographics <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/demographics/n1601_demographics_go1_20161212.csv") %>%
  as_tibble() %>%
  mutate(
    sex = as.ordered(as.factor(sex)),
    age = ageAtScan1 / 12,
    scanid = as.character(scanid)
  ) %>%
  select(scanid, sex, age) %>%
  filter(scanid %in% rest_sample$scanid)

rest_Motion <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/n1601_RestQAData_20170714.csv") %>%
  select(scanid, restRelMeanRMSMotion) %>%
  mutate(scanid = as.character(scanid))

alff_path <- file.path("/data/jux/BBL/projects/isla/data/rawSmoothedAlff_3")

all_scans <-
  list.files(alff_path,  pattern = ".nii.gz", recursive = TRUE, full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}(?=_)")) %>%
  select(scanid, everything())

covariates_df <-
  all_scans %>%
  left_join(demographics, by = "scanid") %>%
  left_join(rest_Motion, by = "scanid") %>%
  mutate(include = 1) %>%  # for inclusion critera
  filter(complete.cases(.))

if (all(purrr::map_lgl(covariates_df$path, file.exists))){
  #ensures that all of the paths are correctly written

  covariates <- "/data/jux/BBL/projects/isla/data/sandbox/voxelwise_gam_covariates_rawSmoothedCBF_3.rds" %T>%
    saveRDS(covariates_df, .)

}
```

`output`

``` r
output <- file.path(paste0("/data/jux/BBL/projects/isla/results/VoxelWrapperModels/", "rawSmoothedAlff_3/"))
```

`imagepaths`

``` r
image_paths <- "path"
```

`mask`

``` r
mask <- file.path("/data/jux/BBL/projects/isla/data/Masks/gm10perc_RestCoverageMask.nii.gz")
```

`smoothing`

``` r
smoothing <- 0
```

`inclusion`

``` r
inclusion <- "include"
```

`subjID`

``` r
subjID <- "scanid"
```

`formula`

``` r
my_formula <- "\"~s(age)+s(age,by=sex)+sex+restRelMeanRMSMotion\""
```

`padjust`

``` r
padjust <- "fdr"
```

The remaining arguments, `splits`, `residual`, and `numberofcores`, `skipfourD`, and `residual`,all remain default.

``` r
run_command <- sprintf(
  "Rscript /data/jux/BBL/projects/isla/code/voxelwiseWrappers/gam_voxelwise.R -c %s -o %s -p %s -m %s -s %s -i %s -u %s -f %s -a %s -n 5 -s 0 -k 10",
  covariates, output, image_paths, mask, smoothing,
  inclusion, subjID, my_formula, padjust
)
writeLines(c("unset PYTHONPATH; unalias python
export PATH=/data/joy/BBL/applications/miniconda3/bin:$PATH
source activate py2k", run_command), "/data/jux/BBL/projects/isla/code/qsub_Calls/RunVoxelwiseRawSmoothedAlff_3.Sh")
```

``` r
system("qsub -l h_vmem=60G,s_vmem=60G -q himem.q /data/jux/BBL/projects/isla/code/qsub_Calls/RunVoxelwiseRawSmoothedAlff_3.Sh",
  wait = FALSE,
  intern = FALSE)
```
