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
	outdir2 = file.path(outdir, 'gmd')
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
	outdir2 = file.path(outdir, 'gmd')
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
	outdir2 = file.path(outdir, 'gmd')
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
    # NON-LINEAR AGE EFFECT WAS NOT SIGNIFICANT
    # form = paste(" ~ Overall_Accuracy + Motion + Sex + Age + s(Age, fx=TRUE, k=", k, ")" )
    # formred = paste(" ~ Overall_Accuracy + Motion + Sex + Age" )
}
if(type=='reho'){
    form = paste(" ~ Overall_Accuracy + Motion + Sex + Age + Sex*Age" )
    formred = paste(" ~ Overall_Accuracy + Motion + Sex + Age" )
    # NON-LINEAR AGE EFFECT WAS NOT SIGNIFICANT
    # form = paste(" ~ Overall_Accuracy + Motion + Sex + Age + s(Age, fx=TRUE, k=", k, ")" )
    # formred = paste(" ~ Overall_Accuracy + Motion + Sex + Age" )
}

# test is the command that was executed
# set run=FALSE to setup flameo run without executing
test = flameo(df$yPaths, dat=df, maskfile=mask, X=form, Xred=formred, voxelev=NULL, outdir=outdir1, run=TRUE)
test = flameo(df$yPaths, dat=df, maskfile=mask, X=form, Xred=formred, voxelev=df$gmdPaths, outdir=outdir2, run=TRUE)

outdir1 = file.path(outdir1, 'randomize/')
system(paste0('mkdir ', outdir1))

rand = randomise(df$yPaths, dat=df, maskfile=mask, X=form, Xred=formred, outdir=outdir1, nperm=5000, thresh=0.01, run=TRUE)
