#Inputs: bblid
#	 scanid
#	 mask_location
#	 neighborhood_size

args=commandArgs(trailingOnly=TRUE)
bblid=as.numeric(as.character(args[1]))
scanid=as.numeric(as.character(args[2]))
mask=as.character(args[3])
nsize=as.numeric(as.character(args[5]))
modality=as.character(args[4])
print(paste0("Running imco with neighbourhood: ", nsize, ",\nBBLID: ", bblid, "\nScanID: ", scanid, ",\nMask: ", mask))

#load libraries
packages=c("parrallel", "methods", "stringr", "fslr", "ANTsR", "extrantsr", "rlist", "dplyr", "imco")
lapply(packages, require, character.only=TRUE, quietly=TRUE)

#read in CBF images for sample
if(modality=="cbf"){
	cbfDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf/"
	Y_image = readnii(paste0(cbfDir,scanid, "_asl_quant_ssT1Std.nii.gz"))
	print("CBF read in successfully")
}

#read in ALFF images for sample
if(modality=="alff"){
        alffDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_alff/"
        Y_image = readnii(paste0(alffDir,scanid, "_alffStd.nii.gz"))
        print("ALFF read in successfully")
}

#read in Reho images for sample
if(modality=="reho"){
        rehoDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_reho/"
        Y_image = readnii(paste0(rehoDir,scanid, "_rehoStd.nii.gz"))
        print("Reho read in successfulyl")
}

#read in gmd for cbf sample
gmdDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/voxelwiseMaps_gmd/"
X_image = readnii(paste0(gmdDir,scanid, "_atropos3class_prob02SubjToTemp2mm.nii.gz"))
print("GMD read in successully")

#read in coverage mask
mask=readnii(mask)
print("mask read in successfully")

#run imco
makeDir=paste0("/home/ttapera/data/jux/BBL/projects/isla/results/Reproducibility/", bblid, "/", scanid, "/", nsize, "/", modality, "/", "reproduced", "/")
system2("mkdir", c("-p",makeDir))
imco(files=list(Y_image,X_image), brainMask=mask, subMask=NULL, type="regression", ref=1, fwhm=3, thresh=0.005, radius=nsize, reverse=FALSE, verbose=TRUE, retimg=FALSE, outDir=makeDir)
