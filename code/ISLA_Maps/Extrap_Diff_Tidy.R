library(methods)
library(neurobase)
library(stringr)
library(parallel)
library(dplyr)
library(stringr)
# extract the arguments from the arg string
args=commandArgs(trailingOnly=TRUE)

imco_images=as.character(args[1])
bblid=as.character(args[2])
scanid=as.character(args[3])
modality=as.character(args[4])
fwhm=as.character(args[5])

#########################################
#	Step 1: Extrapolate		#
########################################
message("# Extrapolating...")
# make GMD=1 predicted value map	
intercept = readnii(file.path(imco_images,"beta0.nii.gz"))
slope = readnii(file.path(imco_images, "beta1.nii.gz"))
predicted = intercept + slope
writenii(predicted, filename=file.path(imco_images,"predictedGMD1"))
message("Predict GMD=1 successful")

# get gmd
gmdPath = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/voxelwiseMaps_gmd/"
gmd = readnii(file.path(gmdPath, paste0(scanid, "_atropos3class_prob02SubjToTemp2mm.nii.gz")))

# extrapolation here
predicted = intercept + slope*gmd
writenii(predicted, filename=file.path(imco_images, "predictedGMDobs"))
message("Predict GMD + slope successful")

# get Y
maskDir="/data/jux/BBL/projects/isla/data/Masks/"
if(modality == "cbf"){
        yPath = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf/"
        yImage = readnii(file.path(yPath, paste0(scanid,"_asl_quant_ssT1Std.nii.gz")))
	mask = readnii(paste0(maskDir,"gm10perc_PcaslCoverageMask.nii.gz"))
}

if(modality == "alff"){
        yPath = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_alff/"
        yImage = readnii(paste0(yPath,scanid,"_alffStd.nii.gz"))
        mask = readnii(paste0(maskDir,"gm10perc_RestCoverageMask.nii.gz"))
}

if(modality == "reho"){
        yPath = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_reho/"
        yImage = readnii(paste0(yPath,scanid,"_rehoStd.nii.gz"))
        mask = readnii(paste0(maskDir,"gm10perc_RestCoverageMask.nii.gz"))
}

message("Y image read in successful")

# get rsquared
r2 = readnii(file.path(imco_images, "rsquared.nii.gz"))
mix = r2 * predicted + (1 - r2)*yImage
writenii(mix, filename=file.path(imco_images, "mixture"))
message("Extrapolate Map Complete")


####################################
# Step 2: Calculate Difference map #
####################################
message("# Calculating Difference map...")
#read in isla image
islaImage = readnii(file.path(imco_images,"predictedGMD1.nii.gz"))
message("Isla read in successful")

# get the difference
diff = islaImage - yImage
diff = diff * mask

writenii(diff, filename=file.path(imco_images, "isla_diff"))
message("Complete")

##################
#  Step 3: Tidy	 #
##################
message("# Renaming...")
setwd(imco_images)
original_files = list.files(imco_images, pattern=regex("^[^0-9]"))
new_names = original_files %>%
        str_c(bblid, scanid, ., sep="_")%>%
        str_replace(., ".nii.gz", paste0("_fwhm", fwhm, ".nii.gz"))

file.rename(original_files, new_names)

message("Files named successfully")
message("ISLA IMAGES CALCULATED")
