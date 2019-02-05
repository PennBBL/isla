#!/bin/bash

######################################################
# spatial correlation between two images img1 and img2
# mask is neceesary. it can be whole brain mask, submask 
# or greymatter mask but img1,img2 and mask must have 
#similar orientation. 
# usage: spatialcorr.sh img1 img2 mask"
######################################################
img1=$1
img2=$2
mask=$3

M1=`fslstats $img1 -k $mask -m`
M2=`fslstats $img2 -k $mask -m`

demeaned1=/tmp/dm1.nii.gz
demeaned2=/tmp/dm2.nii.gz
demeaned_prod=/tmp/dm_prod.nii.gz
fslmaths $img1 -sub $M1 -mas $mask $demeaned1 -odt float
fslmaths $img2 -sub $M2 -mas $mask $demeaned2 -odt float
fslmaths $demeaned1 -mul $demeaned2 $demeaned_prod
num=`fslstats $demeaned_prod -k $mask -m`

demeaned1sqr=/tmp/dm12.nii.gz
demeaned2sqr=/tmp/dm22.nii.gz
fslmaths $demeaned1 -sqr $demeaned1sqr
fslmaths $demeaned2 -sqr $demeaned2sqr
den1=`fslstats $demeaned1sqr -k $mask -m`
den2=`fslstats $demeaned2sqr -k $mask -m`
denprod=`echo "scale=4; sqrt($den1*$den2)" | bc -l`

rcro=`echo "scale=4; $num/$denprod" | bc -l`
rm -rf /tmp/dm12.nii.gz
rm -rf /tmp/dm22.nii.gz
rm -rf /tmp/dm1.nii.gz
rm -rf /tmp/dm2.nii.gz
rm -rf /tmp/dm_prod.nii.gz
echo $rcro
