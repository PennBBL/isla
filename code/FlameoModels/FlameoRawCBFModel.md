Modelling with Flameo
================
Tinashe M. Tapera
2018-01-30

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
print(paste("Updated:", format(Sys.time(), '%Y-%m-%d ')))
```

    ## [1] "Updated: 2019-01-31 "

We test the following model using `flameo`: `rawCBF ~ s(age) + s(age, by=sex) + sex + cbfMotion` First, grab the demographics file and covariates.

``` r
cbf_sample <-
  read.csv("/data/jux/BBL/projects/isla/data/cbfSample.csv") %>%
  as_tibble() %>%
  transmute(scanid = as.character(scanid))

demographics <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/demographics/n1601_demographics_go1_20161212.csv") %>%
  as_tibble() %>%
  mutate(sex = as.ordered(as.factor(sex)),
         age = ageAtScan1 / 12,
         scanid = as.character(scanid)) %>%
  select(sex, age, scanid) %>%
  filter(scanid %in% cbf_sample$scanid)

cbfMotion <-
  read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/n1601_PcaslQaData_20170403.csv") %>%
  select(scanid, pcaslRelMeanRMSMotion) %>%
  mutate(scanid = as.character(scanid))

covariates <-
  left_join(cbf_sample, demographics, by = "scanid") %>%
  left_join(cbfMotion, by = "scanid") %>%
  mutate(intercept = 1,
         sex_by_age = as.numeric(sex) * age,
         sex_sq = as.numeric(sex) ^2
        ) %>%
  select(intercept, everything(), -scanid)
```

The covariates file ends in `.mat` (from matlab), and denotes is a matrix of the covariates. We use `Text2Vest` in the bash shell to create the flameo compatible file.

``` r
dm <- "/data/jux/BBL/projects/isla/data/sandbox/covariates.mat"
write.table(covariates, "/data/jux/BBL/projects/isla/data/sandbox/covariates.csv", row.names = FALSE, col.names = FALSE, quote = FALSE)
system(sprintf("Text2Vest /data/jux/BBL/projects/isla/data/sandbox/covariates.csv %s", dm))
```

The group file ends in `.grp`, and denotes group differences. In this case, we are not running a test between groups and thus is a string of `group = 1`'s. We again use `Text2Vest` in the bash shell to create a flameo compatible file.

``` r
cs <- "/data/jux/BBL/projects/isla/data/sandbox/group.grp"
writeLines(rep("1", nrow(demographics)), "/data/jux/BBL/projects/isla/data/sandbox/group.txt")
system(sprintf("Text2Vest /data/jux/BBL/projects/isla/data/sandbox/group.txt %s", cs))
```

We do the same for a contrast file, which is a simple matrix.

``` r
tc <- "/data/jux/BBL/projects/isla/data/sandbox/contrast.con"
diag(6)
```

    ##      [,1] [,2] [,3] [,4] [,5] [,6]
    ## [1,]    1    0    0    0    0    0
    ## [2,]    0    1    0    0    0    0
    ## [3,]    0    0    1    0    0    0
    ## [4,]    0    0    0    1    0    0
    ## [5,]    0    0    0    0    1    0
    ## [6,]    0    0    0    0    0    1

``` r
write.table(diag(6), "/data/jux/BBL/projects/isla/data/sandbox/contrast.csv", row.names = FALSE, col.names = FALSE, quote = FALSE)
system(sprintf("Text2Vest /data/jux/BBL/projects/isla/data/sandbox/contrast.csv %s", tc))
```

Also include the mask file

``` r
mask <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/gm10pcalcovemask.nii.gz")
```

Next, merge the nifti images using `fslmerge`. This will be a long string of the paths to the images.

``` r
imagePaths <-
  list.files("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf",
            recursive = TRUE,
            pattern = "nii.gz",
            full.names = TRUE)

toMerge <- paste(imagePaths, collapse = " ")

copefile <- "/data/jux/BBL/projects/isla/data/sandbox/merged_raw_CBF.nii.gz"
system(sprintf("fslmerge -t %s %s", copefile, toMerge), wait = TRUE)
```

Finally, we write out the call to `RunFlameo.sh`

``` r
output_dir <- "/data/jux/BBL/projects/isla/results/flameo/s_age_s_agebysex_sex_cbfMotion"
if(!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

run_command <- sprintf("flameo --copefile=%s  --mask=%s  --dm=%s --tc=%s --cs=%s --runmode=flame1 --ld=%s",
                       copefile, mask, dm, tc, cs, output_dir)

writeLines(c("unset PYTHONPATH; unalias python
export PATH=/data/joy/BBL/applications/miniconda3/bin:$PATH
source activate py2k", run_command), "/data/jux/BBL/projects/isla/code/RunFlameo.Sh")
```
