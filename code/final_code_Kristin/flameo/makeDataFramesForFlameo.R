library(dplyr)
library(readr)

nsize = 4
type = 'alff'
bm = "Overall_Accuracy"

# Useful directories
pncdir = '/project/taki2/pnc/n1601_dataFreeze2016'
rootdir = '/project/taki2/kristin_imco'
mapdir = file.path(rootdir, paste0('coupling_maps/gmd_', type, '_size', nsize))    
subjects = data.frame('scanid'=as.numeric(list.files(mapdir)))

gmddir = file.path(pncdir, 'neuroimaging/t1struct/voxelwiseMaps_gmd')
gmdend = "_atropos3class_prob02SubjToTemp2mm"
gmdimgs = list.files(gmddir, full.names=TRUE)
gmdids = unlist(lapply(list.files(gmddir), function(x) strsplit(x, '_')[[1]][1]))
gmdDf = data.frame('scanid'=as.numeric(gmdids), 'gmdPaths'=gmdimgs)
gmdDf = left_join(subjects, gmdDf, by='scanid')

if(type=='cbf'){
    ydir = file.path(pncdir, 'neuroimaging/asl/voxelwiseMaps_cbf')
    yend = "_asl_quant_ssT1Std"
    yimgs = list.files(ydir, full.names=TRUE)
    yids = unlist(lapply(list.files(ydir), function(x) strsplit(x, '_')[[1]][1]))
    yDf = data.frame('scanid'=as.numeric(yids), 'yPaths'=yimgs)
    yDf = left_join(gmdDf, yDf, by='scanid')
    motion = read_csv(file.path(rootdir, 'data/n1601_PcaslQaData_20170403.csv'))
    motion = select(motion, scanid, pcaslRelMeanRMSMotion)
}
if(type=='alff'){
    ydir = file.path(pncdir, 'neuroimaging/rest/voxelwiseMaps_alff')
    yend = "_alffStd"
    yimgs = list.files(ydir, full.names=TRUE)
    yids = unlist(lapply(list.files(ydir), function(x) strsplit(x, '_')[[1]][1]))
    yDf = data.frame('scanid'=as.numeric(yids), 'yPaths'=yimgs)
    yDf = left_join(gmdDf, yDf, by='scanid')
    motion = read_csv(file.path(rootdir, 'data/n1601_RestQAData.csv'))
    motion = select(motion, scanid, restRelMeanRMSMotion)
}
if(type=='reho'){
    ydir = file.path(pncdir, 'neuroimaging/rest/voxelwiseMaps_reho')
    yend = "_rehoStd"
    yimgs = list.files(ydir, full.names=TRUE)
    yids = unlist(lapply(list.files(ydir), function(x) strsplit(x, '_')[[1]][1]))
    yDf = data.frame('scanid'=as.numeric(yids), 'yPaths'=yimgs)
    yDf = left_join(gmdDf, yDf, by='scanid')
    motion = read_csv(file.path(rootdir, 'data/n1601_RestQAData.csv'))
    motion = select(motion, scanid, restRelMeanRMSMotion)
}

imcoids = list.files(mapdir)
imcoimgs1 = unlist(lapply(imcoids, function(x) file.path(mapdir, x, 'predictedGMD1.nii.gz')))
imcoimgs2 = unlist(lapply(imcoids, function(x) file.path(mapdir, x, 'predictedGMDobs.nii.gz')))
imcoDf = data.frame('scanid'=as.integer(imcoids), 'imcoPaths1'=imcoimgs1, 'imcoPathsObs'=imcoimgs2)

df = left_join(yDf, imcoDf, by='scanid')

# Demographics for age and sex 
demo = read_csv(file.path(pncdir, 'demographics/demographics_from_20160207_dataRelease_update20161114.csv'))
demo = select(demo, scanid, sex, ageAtGo1Scan)

df = left_join(df, demo, by='scanid')

# Behavioral factors
bfactors = read_csv(file.path(rootdir, 'subject_lists/n1601_cnb_factor_scores_tymoore_20151006.csv'))
bname = which(names(bfactors)==bm)
bfactors = bfactors[,c(2,bname)]

df = left_join(df, bfactors, by='scanid')

# Motion
df = left_join(df, motion, by='scanid')

write.csv(df, file=file.path(rootdir, 'data', paste0('dataForGAM_', type, '_radius', nsize, '.csv')), row.names=FALSE)
