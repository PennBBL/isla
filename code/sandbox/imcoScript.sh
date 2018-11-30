#!/bin/bash

input="$1"

sed 1d $input | while IFS=, read -r col1 col2
do
	
	cp "/data/jux/BBL/studies/pnc/pncDataFreeze20170905/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf/${col2}_asl_quant_ssT1Std.nii.gz" /home/ttapera/singularity_temp_files/inputs
	cp "/data/jux/BBL/studies/pnc/pncDataFreeze20170905/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_alff/${col2}_alffStd.nii.gz" /home/ttapera/singularity_temp_files/inputs
	cp "/data/jux/BBL/studies/pnc/pncDataFreeze20170905/n1601_dataFreeze/neuroimaging/pncTemplate/pnc_template_brain_mask_2mm.nii.gz" /home/ttapera/singularity_temp_files/inputs

	mkdir /home/ttapera/singularity_temp_files/outputs/${col2}

	echo "library(ANTsR)
library(imco)

cbfNorm = antsImageRead(\"/home/ttapera/singularity_temp_files/inputs/${col2}_asl_quant_ssT1Std.nii.gz\")
alffNorm = antsImageRead(\"/home/ttapera/singularity_temp_files/inputs/${col2}_alffStd.nii.gz\")
maskImg = antsImageRead(\"/home/ttapera/singularity_temp_files/inputs/pnc_template_brain_mask_2mm.nii.gz\")

fls = list()
fls[[1]] = alffNorm
fls[[2]] = cbfNorm

imco(files = fls, brainMask = maskImg,subMask=NULL, type=\"regression\", ref=1, fwhm=2, reverse=FALSE, verbose=TRUE, retimg=FALSE,outDir=\"/home/ttapera/singularity_temp_files/outputs/${col2}/\")" > /home/ttapera/Run_isla.R

	echo "/share/apps/singularity/2.5.1/bin/singularity exec /data/joy/BBL/applications/bids_apps/imco.simg Rscript Run_isla.R" > file.sh

	qsub file.sh

done