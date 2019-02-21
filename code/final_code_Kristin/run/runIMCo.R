library(parallel)
library(methods)
library(stringr)
library(fslr)
library(ANTsR)
library(extrantsr)
library(rlist)
library(dplyr)
library(imco)

# Arguments to get from command line job submit
args = commandArgs(trailingOnly=TRUE)
i = as.numeric(as.character(args[1]))
nsize = as.numeric(as.character(args[2])) # radius for neighborhood
x = as.character(args[3])
y = as.character(args[4])

# Useful directories
rootdir = '/project/taki2/kristin_imco'
datadir = '/project/taki2/pnc/n1601_dataFreeze2016'
maskdir = file.path(rootdir, 'masks')
xdir = file.path(datadir, 'neuroimaging/t1struct')
xend = "_atropos3class_prob02SubjToTemp2mm"

# Different sample/mask used depending on modality
if(y=='cbf'){
	ydir = file.path(datadir, 'neuroimaging/asl')
	yend = "_asl_quant_ssT1Std"	
    # Subject list
	sl = read.csv(file.path(rootdir, 'subject_lists/n1132_cbf_subjList.csv'))
	scanid = sl$scanid[i]
	maskFile = file.path(maskdir, 'gm10perc_PcaslCoverageMask.nii.gz')
	maskImg = readnii(maskFile)
} 
if(y=='alff'){
	ydir = file.path(datadir, 'neuroimaging/rest')
	yend = "_alffStd"
    # Subject list
	sl = read.csv(file.path(rootdir, 'subject_lists/n869_rest_subjList.csv'))
	scanid = sl$scanid[i]
	maskFile = file.path(maskdir, 'gm10perc_RestCoverageMask.nii.gz')
	maskImg = readnii(maskFile)
}
if(y=='reho'){
	ydir = file.path(datadir, 'neuroimaging/rest')
	yend = "_rehoStd"
    # Subject list
	sl = read.csv(file.path(rootdir, 'subject_lists/n869_rest_subjList.csv'))
	scanid = sl$scanid[i]
	maskFile = file.path(maskdir, 'gm10perc_RestCoverageMask.nii.gz')
	maskImg = readnii(maskFile)
}

# Output location
outdir = file.path(rootdir, 'coupling_maps', paste0(x, '_', y, '_size', nsize))
system(paste("mkdir", outdir, sep=" "))

# All .nii.gz files
yFiles = list.files(file.path(ydir, paste0('voxelwiseMaps_', y)))
xFiles = list.files(file.path(xdir, paste0('voxelwiseMaps_', x)))

# Images for IMCo
yName = grep(pattern=paste0(scanid, yend, ".nii.gz"), yFiles)
yFile = yFiles[yName]
xName = grep(pattern=paste0(scanid, xend, ".nii.gz"), xFiles)
xFile = xFiles[xName]
yInFile = file.path(ydir, paste0('voxelwiseMaps_', y), yFile)
xInFile = file.path(xdir, paste0('voxelwiseMaps_', x), xFile)
yRd = readnii(yInFile)
xRd = readnii(xInFile)
# yRd[yRd<0] = 0
# GMD should not be < 0
xRd[xRd<0] = 0

# Prepare list for input to imco main function
fls = list()
fls[[1]] = yRd
fls[[2]] = xRd
makeDir = file.path(outdir, scanid)
system(paste("mkdir", makeDir, sep=" "))

# Radius specification with override FWHM parameter
imco(files=fls, brainMask=maskImg, subMask=NULL, type="regression", ref=1, fwhm=3, thresh=0.005, radius=nsize, reverse=FALSE, verbose=TRUE, retimg=FALSE, outDir=makeDir)

# FOR GEE TESTING:
# test = imco(files=fls, brainMask=maskImg, subMask=NULL, type="gee", ref=1, fwhm=3, thresh=0.005, radius=nsize, reverse=FALSE, verbose=TRUE, retimg=TRUE, outDir=makeDir, propMiss=NULL, corstr='ar1')

