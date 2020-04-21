library(methods)
library(fslr)
library(stringr)
library(dplyr)
library(data.table)
library(readr)

args = commandArgs(trailingOnly=TRUE)
nsize = as.numeric(as.character(args[1])) # neighborhood size

pncdir = '/project/taki2/pnc/n1601_dataFreeze2016'
rootdir = '/project/taki2/kristin_imco'

maskdir = file.path(rootdir, 'masks')
cbffile = file.path(maskdir, 'gm10perc_PcaslCoverageMask.nii.gz')
restfile = file.path(maskdir, 'gm10perc_RestCoverageMask.nii.gz')
cbfmask = readnii(cbffile)
restmask = readnii(restfile)

cbfdir = file.path(rootdir, 'coupling_maps', paste0('gmd_cbf_size', nsize))    
alffdir = file.path(rootdir, 'coupling_maps', paste0('gmd_alff_size', nsize))    
rehodir = file.path(rootdir, 'coupling_maps', paste0('gmd_reho_size', nsize))    
opdir = file.path(rootdir, 'coupling_maps', paste0('avg_size', nsize))
system(paste0('mkdir ', opdir))


subjCbf = list.files(cbfdir)
subjAlff = list.files(alffdir)
subjReho = list.files(rehodir)
nCbf = length(subjCbf)
nAlff = length(subjAlff)
nReho = length(subjReho)

# Average GMD and CBF
cbfdir = file.path(pncdir, 'neuroimaging/asl')
cbfdir = file.path(cbfdir, 'voxelwiseMaps_cbf')
alffdir = file.path(pncdir, 'neuroimaging/rest')
alffdir = file.path(alffdir, 'voxelwiseMaps_alff')
rehodir = file.path(pncdir, 'neuroimaging/rest')
rehodir = file.path(rehodir, 'voxelwiseMaps_reho')
gmddir = file.path(pncdir, 'neuroimaging/t1struct')
gmddir = file.path(gmddir, 'voxelwiseMaps_gmd')

cbfpaths = lapply(subjCbf, function(x) return(file.path(cbfdir, paste0(x, '_asl_quant_ssT1Std.nii.gz'))))
gmdCbfPaths = lapply(subjCbf, function(x) return(file.path(gmddir, paste0(x, '_atropos3class_prob02SubjToTemp2mm.nii.gz'))))

alffpaths = lapply(subjAlff, function(x) return(file.path(alffdir, paste0(x, '_alffStd.nii.gz'))))
gmdAlffPaths = lapply(subjAlff, function(x) return(file.path(gmddir, paste0(x, '_atropos3class_prob02SubjToTemp2mm.nii.gz'))))

rehopaths = lapply(subjReho, function(x) return(file.path(rehodir, paste0(x, '_rehoStd.nii.gz'))))
gmdRehoPaths = lapply(subjReho, function(x) return(file.path(gmddir, paste0(x, '_atropos3class_prob02SubjToTemp2mm.nii.gz'))))

getAvg = function(paths){
	imgs = lapply(paths, function(x){
		if(file.exists(x)){
			return(readnii(x))
		} else{
			return(NA)
		}
	})
	return(imgs)
}
#############################
# CBF
#############################
gmdCbfNiis = getAvg(gmdCbfPaths)
keep = sapply(gmdCbfNiis, is.nifti)
gmdCbfNiis = gmdCbfNiis[keep]
gmdCbfAvg = Reduce('+', gmdCbfNiis)/length(gmdCbfNiis)
gmdCbfAvg = gmdCbfAvg*cbfmask
writenii(gmdCbfAvg, filename=file.path(opdir, 'avgGMD_cbfAnalysis'))

cbfNiis = getAvg(cbfpaths)
keep = sapply(cbfNiis, is.nifti)
cbfNiis = cbfNiis[keep]
cbfAvg = Reduce('+', cbfNiis)/length(cbfNiis)
cbfAvg = cbfAvg*cbfmask
writenii(cbfAvg, filename=file.path(opdir, 'avgCBF'))

#############################
# ALFF
#############################
gmdAlffNiis = getAvg(gmdAlffPaths)
keep = sapply(gmdAlffNiis, is.nifti)
gmdAlffNiis = gmdAlffNiis[keep]
gmdAlffAvg = Reduce('+', gmdAlffNiis)/length(gmdAlffNiis)
gmdAlffAvg = gmdAlffAvg*restmask
writenii(gmdAlffAvg, filename=file.path(opdir, 'avgGMD_alffAnalysis'))

alffNiis = getAvg(alffpaths)
keep = sapply(alffNiis, is.nifti)
alffNiis = alffNiis[keep]
alffAvg = Reduce('+', alffNiis)/length(alffNiis)
alffAvg = alffAvg*restmask
writenii(alffAvg, filename=file.path(opdir, 'avgALFF'))

#############################
# REHO
#############################
gmdRehoNiis = getAvg(gmdRehoPaths)
keep = sapply(gmdRehoNiis, is.nifti)
gmdRehoNiis = gmdRehoNiis[keep]
gmdRehoAvg = Reduce('+', gmdRehoNiis)/length(gmdRehoNiis)
gmdRehoAvg = gmdRehoAvg*restmask
writenii(gmdRehoAvg, filename=file.path(opdir, 'avgGMD_rehoAnalysis'))

rehoNiis = getAvg(rehopaths)
keep = sapply(rehoNiis, is.nifti)
rehoNiis = rehoNiis[keep]
rehoAvg = Reduce('+', rehoNiis)/length(rehoNiis)
rehoAvg = rehoAvg*restmask
writenii(rehoAvg, filename=file.path(opdir, 'avgREHO'))


#############################
# Smoothed
#############################
# getSmooth = function(paths){
# 	imgs = lapply(gmdCbfPaths, function(x){
# 		if(file.exists(x)){
# 			nii = readnii(x)
# 			snii = 
# 			return(snii)
# 		} else{
# 			return(NA)
# 		}
# 	})
# }


