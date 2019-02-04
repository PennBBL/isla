library(methods)
library(fslr)
library(readr)
library(stringr)
library(data.table)
library(dplyr)

# extract the arguments from the arg string
args=commandArgs(trailingOnly=TRUE)

imco_images=as.character(args[1])
bblid=as.character(args[2]) #not necessary in this script but here for consistency
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

maskDir="/data/jux/BBL/projects/isla/data/Masks/"

#read in isla image
islaImage = readnii(file.path(imco_images,"predictedGMD1.nii.gz"))
message("Isla read in successful")

# get Y
if(modality == "cbf"){
	yPath = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf/"
	yImage = readnii(paste0(yPath,scanid,"_asl_quant_ssT1Std.nii.gz"))
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

# get 
diff = islaImage - yImage
diff = diff * mask

writenii(diff, filename=file.path(imco_images, "isla_diff"))
message("Complete")

