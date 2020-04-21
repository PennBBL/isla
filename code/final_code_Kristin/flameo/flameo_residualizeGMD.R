# example code for flameo wrapper
# rm(list=ls())
library(fslr)
library(neurobase)

args = commandArgs(trailingOnly=TRUE)
type = as.character(args[1])

rootdir = '/project/taki2/kristin_imco'
codedir = file.path(rootdir, 'code')
source(file.path(codedir, 'functions.R'))

if(type=='cbf'){
	outdir=file.path(rootdir, 'flameo_final', type)
	system(paste0('mkdir ', outdir))
	outdir1 = file.path(outdir, 'nogmd')
	system(paste0('mkdir ', outdir1))
	outdir2 = file.path(outdir, 'gmd_adjusted')
	system(paste0('mkdir ', outdir2))
	outdir1=file.path(outdir1, 'cbf')
	system(paste0('mkdir ', outdir1))
	outdir2=file.path(outdir2, 'cbf')
	system(paste0('mkdir ', outdir2))
}
if(type=='alff'){
	outdir=file.path(rootdir, 'flameo_final', type)
	system(paste0('mkdir ', outdir))
	outdir1 = file.path(outdir, 'nogmd')
	system(paste0('mkdir ', outdir1))
	outdir2 = file.path(outdir, 'gmd_adjusted')
	system(paste0('mkdir ', outdir2))
	outdir1=file.path(outdir1, 'alff')
	system(paste0('mkdir ', outdir1))
	outdir2=file.path(outdir2, 'alff')
	system(paste0('mkdir ', outdir2))
}
if(type=='reho'){
	outdir=file.path(rootdir, 'flameo_final', type)
	system(paste0('mkdir ', outdir))
	outdir1 = file.path(outdir, 'nogmd')
	system(paste0('mkdir ', outdir1))
	outdir2 = file.path(outdir, 'gmd_adjusted')
	system(paste0('mkdir ', outdir2))
	outdir1=file.path(outdir1, 'reho')
	system(paste0('mkdir ', outdir1))
	outdir2=file.path(outdir2, 'reho')
	system(paste0('mkdir ', outdir2))
}

# Brainmask
maskdir = file.path(rootdir, 'masks')
if(type=='cbf'){
    mask = file.path(maskdir, 'gm10perc_PcaslCoverageMask.nii.gz')
} else{
    mask = file.path(maskdir, 'gm10perc_RestCoverageMask.nii.gz')
}

# data
df = read.csv(file.path(rootdir, 'data', paste0('/dataForGAM_', type, '_radius3', '.csv')))
df$Sex = factor(df$sex, ordered=TRUE)
df$Age = df$ageAtGo1Scan
if(type=='cbf'){
    df$Motion = df$pcaslRelMeanRMSMotion
} else{
    df$Motion = df$restRelMeanRMSMotion
}

# NOTE: ONE SUBJECT HAS NA FOR OVERALL_ACCURACY
rmNA = apply(df, 1, function(x) any(is.na(x)))
df = df[!rmNA,]

# number of knots
k=10
if(type=='cbf'){
    form = paste(" ~ Overall_Accuracy + Motion + Sex + Age + s(Age, fx=TRUE, k=", k, ") + s(Age, fx=TRUE, by=Sex, k=", k, ")" )
    formred = paste(" ~ Overall_Accuracy + Motion + Sex + Age + s(Age, fx=TRUE, k=", k, ")" )
}
if(type=='alff'){
    form = paste(" ~ Overall_Accuracy + Motion + Sex + Age + Sex*Age" )
    formred = paste(" ~ Overall_Accuracy + Motion + Sex + Age" )
}
if(type=='reho'){
    form = paste(" ~ Overall_Accuracy + Motion + Sex + Age + Sex*Age" )
    formred = paste(" ~ Overall_Accuracy + Motion + Sex + Age" )
}

test = flameo(df$yPaths, dat=df, maskfile=mask, X=form, voxelev=df$gmdPaths, outdir=outdir2, run=TRUE)

# Subtract out the GMD term from each image
gmdImgs = lapply(as.character(df$gmdPaths), readnii)
yImgs = lapply(as.character(df$yPaths), readnii)
if(type=='reho' | type=='alff'){
	gmdPE = readnii(file.path(outdir2, 'pe7.nii.gz'))
}
if(type=='cbf'){
	np = 5 + 2*(k-1) + 1 
	gmdPE = readnii(file.path(outdir2, paste0('pe', np, '.nii.gz')))
}
ni = length(gmdImgs)
outout = file.path(outdir2, 'resids/')
system(paste0('mkdir ', outout))
resids = lapply(1:ni, function(x){
	name = paste0(df$scanid[x])
	y = yImgs[[x]] - gmdImgs[[x]]*gmdPE
	y[mask==0] = 0
	writenii(y, filename=file.path(outout, name))
	return(y)
})

outdir2 = file.path(outdir2, 'randomize/')
system(paste0('mkdir ', outdir2))

residImgs = unlist(lapply(1:ni, function(x){
	name = file.path(outout, paste0(df$scanid[x], '.nii.gz'))
}))

rand = randomise(residImgs, dat=df, maskfile=mask, X=form, Xred=formred, outdir=outdir2, nperm=5000, thresh=0.01, run=TRUE)

outdir2 = file.path(outdir2, 'fit/')
system(paste0('mkdir ', outdir2))

test = flameo(residImgs, dat=df, maskfile=mask, X=form, voxelev=NULL, outdir=outdir2, run=TRUE)







