Multivariate Voxelwise `gam()`: ISLA CBF Size 3
================
Tinashe M. Tapera
2018-02-8

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
print(paste("Updated:", format(Sys.time(), '%Y-%m-%d ')))
```

    ## [1] "Updated: 2019-02-13 "

`covariates`

``` r
cbf_sample <- read.csv("/data/jux/BBL/projects/isla/data/cbfSample.csv") %>%
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
  filter(scanid %in% cbf_sample$scanid)

cbfMotion <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/n1601_PcaslQaData_20170403.csv") %>%
  select(scanid, pcaslRelMeanRMSMotion) %>%
  mutate(scanid = as.character(scanid))

cbf_path <- file.path("/data/jux/BBL/projects/isla/data/imco1/gmd_cbf")

all_scans <-
  list.files(cbf_path,  pattern = ".nii.gz", recursive = TRUE, full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=_)[:digit:]{4,}(?=_)")) %>%
  filter(str_detect(path, "isla_diff_vox3")) %>%
  select(scanid, everything())

covariates_df <-
  all_scans %>%
  left_join(demographics, by = "scanid") %>%
  left_join(cbfMotion, by = "scanid") %>%
  mutate(include = 1) %>%  # for inclusion critera
  filter(complete.cases(.))

if (all(purrr::map_lgl(covariates_df$path, file.exists))){
  #ensures that all of the paths are correctly written

  covariates <- "/data/jux/BBL/projects/isla/data/sandbox/voxelwise_gam_covariates_ISLACBF3.rds" %T>%
    saveRDS(covariates_df, .)

}
```

`output`

``` r
output <- file.path(paste0("/data/jux/BBL/projects/isla/results/VoxelWrapperModels/", "cbf3/"))
```

`imagepaths`

``` r
image_paths <- "path"
```

`mask`

``` r
mask <- file.path("/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz")
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
my_formula <- "\"~s(age)+s(age,by=sex)+sex+pcaslRelMeanRMSMotion\""
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
source activate py2k", run_command), "/data/jux/BBL/projects/isla/code/qsub_Calls/RunVoxelwiseIslaCBF3.Sh")
```

``` r
system("qsub -l h_vmem=60G,s_vmem=60G -q himem.q /data/jux/BBL/projects/isla/code/qsub_Calls/RunVoxelwiseIslaCBF3.Sh",
  wait = FALSE,
  intern = FALSE)
```
