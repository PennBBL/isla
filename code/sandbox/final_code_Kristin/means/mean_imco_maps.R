library(methods)
library(fslr)
library(stringr)
library(dplyr)
library(data.table)
library(readr)

args = commandArgs(trailingOnly=TRUE)
nsize = as.numeric(as.character(args[1])) # neighborhood size
type = as.character(args[2]) # cbf, alff, or reho

pncdir = '/project/taki2/pnc/n1601_dataFreeze2016'
rootdir = '/project/taki2/kristin_imco'
mapdir = file.path(rootdir, 'coupling_maps', paste0('gmd_', type, '_size', nsize))    
opdir = file.path(rootdir, 'coupling_maps', paste0('avg_size', nsize))
system(paste0('mkdir ', opdir))

subjects = list.files(mapdir)
fnames = lapply(subjects, function(x){
	if(file.exists(file.path(mapdir, x, 'beta1.nii.gz'))){
		return(file.path(mapdir, x))
	} else{
		return(NA)
	}
})

names1 = c(paste0('mixture_', type, '_isla'), paste0('isla_', type, '_diff'))
names2 = c('rsquared', 'predictedGMD1', 'predictedGMDobs', 'beta1', 'beta0')

getAvg1 = function(name, paths=fnames){
	imgs = lapply(paths, function(x){
		tmp = file.path(x, paste0(name, '.nii.gz'))
		if(file.exists(tmp)){
			return(readnii(tmp))
		} else{
			return(NA)
		}
	})
	checknii = sapply(imgs, is.nifti)
	imgs = imgs[checknii]
	avg = Reduce('+', imgs)/length(imgs)
	writenii(avg, filename=file.path(opdir, paste0('avg_', name)))
}

getAvg2 = function(name, paths=fnames){
	imgs = lapply(paths, function(x){
		tmp = file.path(x, paste0(name, '.nii.gz'))
		if(file.exists(tmp)){
			return(readnii(tmp))
		} else{
			return(NA)
		}
	})
	checknii = sapply(imgs, is.nifti)
	imgs = imgs[checknii]
	avg = Reduce('+', imgs)/length(imgs)
	writenii(avg, filename=file.path(opdir, paste0('avg_', name, '_', type)))
}

lapply(names2, getAvg2)
lapply(names1, getAvg1)




