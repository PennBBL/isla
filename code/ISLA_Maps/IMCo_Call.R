#Inputs: bblid
#	 scanid
#	 mask_location
#	 full width half max fwhm
#	 modality

args=commandArgs(trailingOnly=TRUE)
bblid=as.numeric(as.character(args[1]))
scanid=as.numeric(as.character(args[2]))
mask=as.character(args[3])
fwhm=as.numeric(as.character(args[5]))
modality=as.character(args[4])
print(paste0("Running imco with fwhm: ", fwhm, ", BBLID: ", bblid, ", ScanID: ", scanid, ", Mask: ", mask))

#load libraries
packages=c("parrallel", "methods", "stringr", "fslr", "ANTsR", "extrantsr", "rlist", "dplyr", "imco")
lapply(packages, require, character.only=TRUE, quietly=TRUE)

#read in CBF images for sample
if(modality=="cbf"){
	cbfDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf/"
  img_suffix = "_asl_quant_ssT1Std.nii.gz"
	Y_image = readnii(paste0(cbfDir,scanid, img_suffix))
	Y_image = fslmaths(Y_image, opts = c("-thr", 0), verbose = FALSE)
	print("CBF read in successfully")
}

#read in ALFF images for sample
if(modality=="alff"){
        alffDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_alff/"
        img_suffix = "_alffStd.nii.gz"
        Y_image = readnii(paste0(alffDir,scanid, img_suffix))
        Y_image = fslmaths(Y_image, opts = c("-thr", 0), verbose = FALSE)
	print("ALFF read in successfully")
}

#read in Reho images for sample
if(modality=="reho"){
        rehoDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_reho/"
        img_suffix = "_rehoStd.nii.gz"
        Y_image = readnii(paste0(rehoDir,scanid, img_suffix))
        Y_image = fslmaths(Y_image, opts = c("-thr", 0), verbose = FALSE)
	print("Reho read in successfulyl")
}

#read in gmd for cbf sample
gmdDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/voxelwiseMaps_gmd/"
X_image = readnii(paste0(gmdDir,scanid, "_atropos3class_prob02SubjToTemp2mm.nii.gz"))
X_image = fslmaths(X_image, opts = c("-thr", 0), verbose = FALSE)
print("GMD read in successully")

#read in coverage mask
mask=readnii(mask)
print("mask read in successfully")

#run imco
makeDir=paste0("/home/ttapera/data/jux/BBL/projects/isla/data/imco1.6/gmd_", modality, "/", bblid, "/")
system2("mkdir", c("-p",makeDir))
imco(files=list(Y_image,X_image), brainMask=mask, subMask=NULL, type="regression", ref=1, fwhm=fwhm, thresh=0.005, radius=NULL, reverse=FALSE, verbose=TRUE, retimg=FALSE, outDir=makeDir)
