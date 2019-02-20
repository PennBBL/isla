#!/bin/bash
#$ -t 2:870

echo Calculating Alff Maps
modality=alff

# Read in the data
restMask=/data/jux/BBL/projects/isla/data/Masks/gm10perc_RestCoverageMask.nii.gz

# the line below uses awk to assign the value of a csv to the variable
bblid=$(awk -F, -v "line=$SGE_TASK_ID" 'NR==line+1 {print $2}' /data/jux/BBL/projects/isla/data/restSample.csv)
scanid=$(awk -F, -v "line=$SGE_TASK_ID" 'NR==line+1 {print $3}' /data/jux/BBL/projects/isla/data/restSample.csv)

size=4 #now fwhm
output_images=/data/jux/BBL/projects/isla/data/imco1.6/gmd_$modality/$bblid
/share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.6.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$restMask $modality $size
Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size
echo ----------------------
