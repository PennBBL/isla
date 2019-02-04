library(dplyr)
library(stringr)

# extract the arguments from the arg string
args=commandArgs(trailingOnly=TRUE)

imco_images=as.character(args[1])
bblid=as.character(args[2])
scanid=as.character(args[3])
size=as.character(args[4])

setwd(imco_images)
original_files = list.files(imco_images, pattern=".nii.gz")
new_names = original_files %>%
	str_c(scanid, ., sep="_")%>%
	str_replace(., ".nii.gz", paste0("_vox", size, ".nii.gz"))

file.rename(original_files, new_names)

message("Files renamed successfully")
