library(methods)
library(neurobase)
library(stringr)
library(parallel)

args = commandArgs(trailingOnly=TRUE)
id = as.numeric(as.character(args[1]))
nsize = as.numeric(as.character(args[2])) # neighborhood size
type = as.character(args[3]) # alff OR cbf OR reho

rootdir = '/project/taki2/kristin_imco/coupling_maps'
dir = file.path(rootdir, paste0('gmd_', type, '_size', nsize))	

dirN = list.files(dir)
subDir = file.path(dir, dirN[id])

# Make GMD=1 predicted value map 
intercept = list.files(subDir, pattern="beta0.nii.gz", full.names=TRUE)
slope = list.files(subDir, pattern="beta1.nii.gz", full.names=TRUE)
interceptNii = readnii(intercept)
slopeNii = readnii(slope)
predicted = interceptNii + slopeNii
writenii(predicted, filename=file.path(subDir, "predictedGMD1"))

datadir = '/project/taki2/pnc/n1601_dataFreeze2016'
gmddir = file.path(datadir, 'neuroimaging/t1struct')
gmdend = "_atropos3class_prob02SubjToTemp2mm"
gmdFile = file.path(gmddir, 'voxelwiseMaps_gmd', paste0(dirN[id], gmdend, '.nii.gz'))
gmd = readnii(gmdFile)

predicted = interceptNii + slopeNii*gmd
writenii(predicted, filename=file.path(subDir, "predictedGMDobs"))

# CBF/ISLA mixture based on R^2
datadir = '/project/taki2/pnc/n1601_dataFreeze2016'
if(type=='cbf'){
	ydir = file.path(datadir, 'neuroimaging/asl')
	yend = "_asl_quant_ssT1Std.nii.gz"
	yFile = file.path(ydir, 'voxelwiseMaps_cbf', paste0(dirN[id], yend))
	yy = readnii(yFile)
}
if(type=='alff'){
	ydir = file.path(datadir, 'neuroimaging/rest')
	yend = "_alffStd.nii.gz"
	yFile = file.path(ydir, 'voxelwiseMaps_alff', paste0(dirN[id], yend))
	yy = readnii(yFile)
}
if(type=='reho'){
	ydir = file.path(datadir, 'neuroimaging/rest')
	yend = "_rehoStd.nii.gz"
	yFile = file.path(ydir, 'voxelwiseMaps_reho', paste0(dirN[id], yend))
	yy = readnii(yFile)
}

r2 = list.files(subDir, pattern="rsquared.nii.gz", full.names=TRUE)
r2nii = readnii(r2)
mix = r2nii*predicted + (1-r2nii)*yy
writenii(mix, filename=file.path(subDir, paste0('mixture_', type, '_isla')))
