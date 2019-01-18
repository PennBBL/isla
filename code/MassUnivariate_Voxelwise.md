updated: {{format(Sys.time(), '%Y-%B-%d ')}}

``` r
suppressPackageStartupMessages({
  library(tidyr)
  library(dplyr)
    library(knitr)
  library(magrittr)
})
set.seed(1000)
```

How to Run Voxelwise `gam()` with `voxelwrapper`
================================================

Set up
------

Here we demonstrate the multivariate voxelwise `gam()` for `CBF ~ s(age, by=sex)`, first for raw CBF data, and then, for ISLA-corrected CBF data. We walk through the arguments of the voxelwrapper, creating each within this notebook. 1. `covariates` Here we read in the demographic data and the paths to the CBF images, and write this out to an RDS file in the sandbox:

``` r
demographics <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/demographics/n1601_demographics_go1_20161212.csv") %>%
  as_tibble() %>%
  mutate(sex = as.ordered(as.factor(sex)),
         age = ageAtScan1 / 12,
         scanid = as.character(scanid))

head(demographics) %>% kable()
```

|  bblid| scanid | sex |  race|  race2|  ethnicity|  ageAtClinicalAssess1|  ageAtCnb1|  ageAtScan1|  edu1|  fedu1|  medu1|  handednessv2|       age|
|------:|:-------|:----|-----:|------:|----------:|---------------------:|----------:|-----------:|-----:|------:|------:|-------------:|---------:|
|  80010| 2894   | 1   |     1|      1|          2|                   260|        260|         261|    14|     20|     16|             1|  21.75000|
|  80179| 2643   | 2   |     1|      1|          2|                   254|        254|         254|    12|     NA|     14|             1|  21.16667|
|  80199| 2637   | 1   |     5|      3|          1|                   243|        244|         244|    12|     NA|     12|             1|  20.33333|
|  80208| 3016   | 1   |     2|      2|          2|                   245|        245|         246|    11|     12|     12|             2|  20.50000|
|  80249| 2648   | 2   |     1|      1|          2|                   250|        250|         250|    16|     10|     12|             1|  20.83333|
|  80263| 6635   | 2   |     2|      2|          2|                   251|        251|         277|    11|     NA|     12|             1|  23.08333|

``` r
voxelwise_path <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf")

all_scans <-
  list.files(voxelwise_path) %>%
  tibble(path = .) %>%
  separate(path, into = c("scanid"), remove = FALSE, extra = "drop") %>%
  mutate(path = paste(voxelwise_path,path, sep = "/")) %>%
  select(scanid, everything())

head(all_scans) %>% kable()
```

| scanid | path                                                                                                             |
|:-------|:-----------------------------------------------------------------------------------------------------------------|
| 2632   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2632\_asl\_quant\_ssT1Std.nii.gz |
| 2637   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2637\_asl\_quant\_ssT1Std.nii.gz |
| 2643   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2643\_asl\_quant\_ssT1Std.nii.gz |
| 2644   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2644\_asl\_quant\_ssT1Std.nii.gz |
| 2646   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2646\_asl\_quant\_ssT1Std.nii.gz |
| 2647   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2647\_asl\_quant\_ssT1Std.nii.gz |

``` r
covariates_df <-
  all_scans %>%
  left_join(demographics, by = "scanid") %>%
  mutate(include = 1) # for inclusion critera

head(covariates_df) %>% kable()
```

| scanid | path                                                                                                             |  bblid| sex |  race|  race2|  ethnicity|  ageAtClinicalAssess1|  ageAtCnb1|  ageAtScan1|  edu1|  fedu1|  medu1|  handednessv2|       age|  include|
|:-------|:-----------------------------------------------------------------------------------------------------------------|------:|:----|-----:|------:|----------:|---------------------:|----------:|-----------:|-----:|------:|------:|-------------:|---------:|--------:|
| 2632   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2632\_asl\_quant\_ssT1Std.nii.gz |  80961| 1   |     1|      1|          2|                   259|        259|         259|    13|     11|     12|             2|  21.58333|        1|
| 2637   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2637\_asl\_quant\_ssT1Std.nii.gz |  80199| 1   |     5|      3|          1|                   243|        244|         244|    12|     NA|     12|             1|  20.33333|        1|
| 2643   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2643\_asl\_quant\_ssT1Std.nii.gz |  80179| 2   |     1|      1|          2|                   254|        254|         254|    12|     NA|     14|             1|  21.16667|        1|
| 2644   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2644\_asl\_quant\_ssT1Std.nii.gz |  81005| 1   |     1|      1|          2|                   241|        241|         241|    14|     12|     20|             1|  20.08333|        1|
| 2646   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2646\_asl\_quant\_ssT1Std.nii.gz |  80812| 2   |     2|      2|          2|                   246|        246|         247|    12|     12|     14|             1|  20.58333|        1|
| 2647   | /data/joy/BBL/studies/pnc/n1601\_dataFreeze/neuroimaging/asl/voxelwiseMaps\_cbf/2647\_asl\_quant\_ssT1Std.nii.gz |  80607| 1   |     2|      2|          2|                   252|        252|         252|    15|     12|     12|             1|  21.00000|        1|

``` r
if (all(purrr::map_lgl(covariates_df$path, file.exists))){
  #ensures that all of the paths are correctly written

  covariates <- "/data/jux/BBL/projects/isla/data/sandbox/voxelwise_gam_covariates.rds" %T>%
    saveRDS(covariates_df, .)

}
```

1.  `output` Quickly assign an output directory

``` r
output <- file.path("/data/jux/BBL/projects/isla/results/")
```

1.  `imagepaths` Next we find the voxelwise CBF data, and create a spreadsheet of input paths:

``` r
image_paths <- "path"
```

1.  `mask` Set the path to the mask image

``` r
mask <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/gm10pcalcovemask.nii.gz")
```

1.  `smoothing` The smoothing in sigmas required for the fourd image. Recommended default to 0

``` r
smoothing <- 0
```

1.  `inclusion` Whether or not there are some exclusion criteria; currently none

``` r
inclusion <- "include"
```

1.  `subjID` The name of the column denoting the subject ID

``` r
subjID <- "scanid"
```

`formula` The formula call, as a string. Note that there needn't be any spaces

``` r
my_formula <- "\"~s(age,by=sex)\""
```

The remaining arguments, `padjust`, `splits`, `residual`, and `numberofcores`, `skipfourD`, and `residual`,all remain default. \#\# Running the Model We will call the voxelwrapper from outside the session, but build it in here first using string formatting and system calls, since this is a notebook.

``` r
# worlds longest single line of code dont judge me
run_command <- sprintf("qsub -V -S Rscript -cwd -o /data/jux/BBL/projects/isla/code/sandbox/log -e /data/jux/BBL/projects/isla/code/sandbox/log -binding linear:5 -pe unihost 5 -l h_vmem=30.0G,s_vmem=30.0G /data/joy/BBL/applications/groupAnalysis/gam_voxelwise.R -c %s -o %s -p %s -m %s -s %s -i %s -u %s -f %s -n 5 -s 0 -k 10", covariates, output, image_paths, mask, smoothing, inclusion, subjID, my_formula)

cat(run_command, file="/data/jux/BBL/projects/isla/code/sandbox/run_gam_voxelwise.sh")
```

You can then execute the script in the shell.
