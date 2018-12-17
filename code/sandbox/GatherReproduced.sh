#!/bin/bash

# this script finds the images from the recent PMACS data upload so they can be compared to the reproduced sample

reproduced=/data/jux/BBL/projects/isla/results/Reproducibility/
original=/data/jux/BBL/projects/isla/data/coupling_maps_PMACS
for x in /data/jux/BBL/projects/isla/results/Reproducibility/*/*/*/*; do


	bblid=$(echo $x | cut -d '/' -f9)
	scanid=$(echo $x | cut -d '/' -f10)
	nsize=$(echo $x | cut -d '/' -f11)
	modality=$(echo $x | cut -d '/' -f12)
	
	originalImg=$original/gmd_${modality}_size$nsize/$scanid
	
	mkdir -p $x/reproduced
	mkdir -p $x/original

	find . | egrep ".nii" | xargs mv $x/reproduced/
	find . | egrep ".nii" | xargs cp $x/original/
done
