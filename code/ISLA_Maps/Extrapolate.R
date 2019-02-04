library(methods)
library(neurobase)
library(stringr)
library(parallel)
library(dplyr)

# extract the arguments from the arg string
args=commandArgs(trailingOnly=TRUE)

imco_images=as.character(args[1])
bblid=as.character(args[2])
scanid=as.character(args[3])
modality=as.character(args[4])
# the following is a very inflexible way to extract parameters! AWFUL CODE! d-_-b
# using the path as input:
# scanid is the 4 digit number
#scanid=str_extract(inputs, "/\\d{4}/")%>%
#	gsub("/","",.,fixed=TRUE)
#bblid is the 5+ digit number
#bblid=str_extract(inputs,"/\\d{4,}/")%>%
#	gsub("/","",.,fixed=TRUE)

#modality is the last string
#modality=str_extract(inputs,"/[a-z]+/$")%>%
#        gsub("/","",.,fixed=TRUE)


# make GMD=1 predicted value map
intercept = readnii(file.path(imco_images,"beta0.nii.gz"))
slope = readnii(file.path(imco_images, "beta1.nii.gz"))
predicted = intercept + slope
writenii(predicted, filename=file.path(imco_images,"predictedGMD1"))
message("Predict GMD=1 successful")

# get gmd
gmdPath = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/voxelwiseMaps_gmd/"
gmd = readnii(file.path(gmdPath, paste0(scanid, "_atropos3class_prob02SubjToTemp2mm.nii.gz")))

# not sure what this part does
predicted = intercept + slope*gmd
writenii(predicted, filename=file.path(imco_images, "predictedGMDobs"))
message("Predict GMD + slope successful")

# get Y
if(modality == "cbf"){
	yPath = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf/"
	yImage = readnii(file.path(yPath, paste0(scanid,"_asl_quant_ssT1Std.nii.gz")))
}

if(modality == "alff"){
        yPath = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_alff/"
        yImage = readnii(file.path(yPath,paste0(scanid,"_alffStd.nii.gz")))
}

if(modality == "reho"){
        yPath = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_reho/"
        yImage = readnii(file.path(yPath,paste0(scanid,"_rehoStd.nii.gz")))
}

message("Y image read in successful")

# get rsquared
r2 = readnii(file.path(imco_images, "rsquared.nii.gz"))
mix = r2 * predicted + (1 - r2)*yImage
writenii(mix, filename=file.path(imco_images, "mixture"))
message("Complete")


