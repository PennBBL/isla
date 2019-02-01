#' ---
#' title: "Modelling with Flameo"
#' author: "Tinashe M. Tapera"
#' date: "2018-01-30"
#' ---

library(dplyr)
library(stringr)
print(paste("Updated:", format(Sys.time(), '%Y-%m-%d ')))

#' We test the following model using `flameo`:
#' `rawCBF ~ s(age) + s(age, by=sex) + sex + cbfMotion`
#' First, grab the demographics file and covariates.

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
         sex_sq = as.numeric(sex) ^2) %>%
  arrange(scanid) %>%
  select(intercept, everything(), -scanid)

#' The covariates file ends in `.mat` (from matlab), and denotes is a matrix of the covariates. We use `Text2Vest` in the bash shell to create the flameo compatible file.
dm <- "/data/jux/BBL/projects/isla/data/sandbox/covariates.mat"
write.table(covariates, "/data/jux/BBL/projects/isla/data/sandbox/covariates.csv", row.names = FALSE, col.names = FALSE, quote = FALSE)
system(sprintf("Text2Vest /data/jux/BBL/projects/isla/data/sandbox/covariates.csv %s", dm))

#' The group file ends in `.grp`, and denotes group differences. In this case, we are not running a test between groups and thus is a string of `group = 1`'s. We again use `Text2Vest` in the bash shell to create a flameo compatible file.
cs <- "/data/jux/BBL/projects/isla/data/sandbox/group.grp"
writeLines(rep("1", nrow(demographics)), "/data/jux/BBL/projects/isla/data/sandbox/group.txt")
system(sprintf("Text2Vest /data/jux/BBL/projects/isla/data/sandbox/group.txt %s", cs))

#' We do the same for a contrast file, which is a simple matrix.
tc <- "/data/jux/BBL/projects/isla/data/sandbox/contrast.con"
diag(6)
write.table(diag(6), "/data/jux/BBL/projects/isla/data/sandbox/contrast.csv", row.names = FALSE, col.names = FALSE, quote = FALSE)
system(sprintf("Text2Vest /data/jux/BBL/projects/isla/data/sandbox/contrast.csv %s", tc))

#' Also include the mask file

mask <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/gm10pcalcovemask.nii.gz")

#' Next, merge the nifti images using `fslmerge`. The argument will be a long string of the paths to the images. Specifically, we write a file called `RunFlameo.sh` that we will call from the command line in `qsub`. Use a preamble to activate the correct environment

imagePaths <-
  list.files("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf",
             pattern = ".nii.gz", recursive = TRUE, full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  select(scanid, everything()) %>%
  filter(scanid %in% cbf_sample$scanid) %>%
  arrange(scanid)

toMerge <- paste(imagePaths$path, collapse = " ")

copefile <- "/data/jux/BBL/projects/isla/data/sandbox/merged_raw_CBF.nii.gz"
run_command <- sprintf("fslmerge -t %s %s", copefile, toMerge)

write(c("unset PYTHONPATH; unalias python",
             "export PATH=/data/joy/BBL/applications/miniconda3/bin:$PATH",
             "source activate py2k",
             run_command),
           "/data/jux/BBL/projects/isla/code/qsub_Calls/RunFlameo.Sh",
           append = FALSE)

#' Finally, we write out the call to `RunFlameo.sh`

output_dir <- "/data/jux/BBL/projects/isla/results/flameo/s_age_s_agebysex_sex_cbfMotion"
if(!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

run_command <- sprintf("flameo --copefile=%s  --mask=%s  --dm=%s --tc=%s --cs=%s --runmode=flame1 --ld=%s",
                       copefile, mask, dm, tc, cs, output_dir)

write(run_command, "/data/jux/BBL/projects/isla/code/qsub_Calls/RunFlameo.Sh", append = TRUE)
