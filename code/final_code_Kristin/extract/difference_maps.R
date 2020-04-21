library(methods)
library(fslr)
library(stringr)
library(dplyr)
library(data.table)
library(readr)

pncdir = '/project/taki2/pnc/n1601_dataFreeze2016'
rootdir = '/project/taki2/kristin_imco'
# Brainmask
maskdir = file.path(rootdir, 'masks')

run = function(nsize, type){
	imcodir = file.path(rootdir, 'coupling_maps', paste0('gmd_', type, '_size', nsize))
	subjects = list.files(imcodir)

	lapply(subjects, function(x){
		islafile = file.path(imcodir, x, 'predictedGMD1.nii.gz')
		if(file.exists(islafile)){
			isla = readnii(islafile)
			if(type=='cbf'){
				maskFile = file.path(maskdir, 'gm10perc_PcaslCoverageMask.nii.gz')
				maskImg = readnii(maskFile)
				yfile = file.path(pncdir, 'neuroimaging/asl/voxelwiseMaps_cbf', paste0(x, '_asl_quant_ssT1Std.nii.gz'))
			}
			if(type=='alff'){
				maskFile = file.path(maskdir, 'gm10perc_RestCoverageMask.nii.gz')
				maskImg = readnii(maskFile)
				yfile = file.path(pncdir, 'neuroimaging/rest/voxelwiseMaps_alff', paste0(x, '_alffStd.nii.gz'))
			}
			if(type=='reho'){
				maskFile = file.path(maskdir, 'gm10perc_RestCoverageMask.nii.gz')
				maskImg = readnii(maskFile)
				yfile = file.path(pncdir, 'neuroimaging/rest/voxelwiseMaps_reho', paste0(x, '_rehoStd.nii.gz'))
			}
			yy = readnii(yfile)
			diff = isla - yy
			diff = diff*maskImg
			writenii(diff, filename=file.path(imcodir, x, paste0('isla_', type, '_diff')))
		}
	})
}

run(4, 'cbf')
run(3, 'cbf')
run(4, 'alff')
run(3, 'alff')
run(4, 'reho')
run(3, 'reho')

