#Input: the neighbourhood size for the regression
args=commandArgs(trailingOnly=TRUE)
nsize=as.numeric(as.character(args[1]))
print(paste0("Running imco with neighbourhood: ",nsize))

#load libraries
packages=c("parrallel", "methods", "stringr", "fslr", "ANTsR", "extrantsr", "rlist", "dplyr", "imco")
lapply(packages, require, character.only=TRUE, quietly=TRUE)
#get participant sample
cbf=read.csv("/home/ttapera/data/jux/BBL/projects/isla/data/Reproducibility/cbfSample.csv")
reho_alff=read.csv("/home/ttapera/data/jux/BBL/projects/isla/data/Reproducibility/restSample.csv")

#read in CBF images for sample
cbfImages = list()
cbfDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf/"
for(scan in 1:nrow(cbf)){
  
  cbfImages[[scan]] = readnii(paste0(cbfDir,cbf[scan, 'scanid'], "_asl_quant_ssT1Std.nii.gz"))
  
}
print("CBF read in successful")

#read in gmd for cbf sample
cbf_gmdImages = list()
gmdDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/voxelwiseMaps_gmd/"

for(scan in 1:nrow(cbf)){
  
  cbf_gmdImages[[scan]] = readnii(paste0(gmdDir,cbf[scan, 'scanid'], "_atropos3class_prob02SubjToTemp2mm.nii.gz"))
}
print("CBF_GMD read in successul")

#read in alff images for sample
alffImages = list()
alffDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_alff/"

for(scan in 1:nrow(reho_alff)){
  
  alffImages[[scan]] = readnii(paste0(alffDir,reho_alff[scan, 'scanid'], "_alffStd.nii.gz"))
}
print("Alff read in successful")

#read in reho images for sample
rehoImages=list()
rehoDir = "/home/ttapera/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_reho/"

for(scan in 1:nrow(reho_alff)){
  
  rehoImages[[scan]] = readnii(paste0(rehoDir,reho_alff[scan, 'scanid'], "_rehoStd.nii.gz"))
}
print("Reho read in successful")

#corresponding gmd for alff and reho
al_re_gmdImages = list()
for(scan in 1:nrow(reho_alff)){
  
  al_re_gmdImages[[scan]] = readnii(paste0(gmdDir,reho_alff[scan, 'scanid'], "_atropos3class_prob02SubjToTemp2mm.nii.gz"))
}
print("Alff/reho GMD read in successful")

#read in the coverage masks
cbfMask = readnii("/home/ttapera/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz")
restMask = readnii("/home/ttapera/data/jux/BBL/projects/isla/data/Masks/gm10perc_RestCoverageMask.nii.gz")
print("mask read in successful")

#run imco
#for CBF
for(participant in 1:nrow(cbf)){
  
  makeDir=paste0("/home/ttapera/data/jux/BBL/projects/isla/results/Reproducibility/CBF/", nsize,"/", cbf[participant,"scanid"])
  system2("mkdir", c("-p",makeDir))
  imco(files=list(cbf_gmdImages[[participant]], cbfImages[[participant]]), brainMask=cbfMask, subMask=NULL, type="regression", ref=1, fwhm=3, thresh=0.005, radius=nsize, reverse=FALSE, verbose=TRUE, retimg=FALSE, outDir=makeDir)
}

#for Alff
for(participant in 1:nrow(cbf)){
  
  makeDir=paste0("/home/ttapera/data/jux/BBL/projects/isla/results/Reproducibility/ALFF/", nsize,"/", reho_alff[participant,"scanid"])
  system2("mkdir", c("-p",makeDir))
  imco(files=list(al_re_gmdImages[[participant]], alffImages[[participant]]), brainMask=restMask, subMask=NULL, type="regression", ref=1, fwhm=3, thresh=0.005, radius=nsize, reverse=FALSE, verbose=TRUE, retimg=FALSE, outDir=makeDir)
}

#for reho
for(participant in 1:nrow(cbf)){
  
  makeDir=paste0("/home/ttapera/data/jux/BBL/projects/isla/results/Reproducibility/Reho/", nsize,"/", reho_alff[participant,"scanid"])
  system2("mkdir", c("-p",makeDir))
  imco(files=list(al_re_gmdImages[[participant]], rehoImages[[participant]]), brainMask=restMask, subMask=NULL, type="regression", ref=1, fwhm=3, thresh=0.005, radius=nsize, reverse=FALSE, verbose=TRUE, retimg=FALSE, outDir=makeDir)
}
