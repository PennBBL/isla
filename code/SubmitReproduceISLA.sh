#!/bin/bash

# CBF data to read in
cbfMask=/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz
cbfParticipants=/data/jux/BBL/projects/isla/data/Reproducibility/cbfSample.csv

# ALFF REHO data to read in
restMask=/data/jux/BBL/projects/isla/data/Masks/gm10perc_RestCoverageMask.nii.gz
alffRehoParticipants=/data/jux/BBL/projects/isla/data/Reproducibility/restSample.csv

# Loop through CBF participants and execute
sed 1d $cbfParticipants | while IFS="," read -r bblid scanid; do

	/share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ReproduceISLA.R $bblid $scanid /home/ttapera$cbfMask cbf 3

	/share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ReproduceISLA.R $bblid $scanid /home/ttapera$cbfMask cbf 4	
done

# Loop through ALFF participants and execute
sed 1d $alffRehoParticipants | while IFS="," read -r bblid scanid; do

	/share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ReproduceISLA.R $bblid $scanid /home/ttapera$restMask alff 3

        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ReproduceISLA.R $bblid $scanid /home/ttapera$restMask alff 4

done
# Loop through REHO participants and execute
sed 1d $alffRehoParticipants | while IFS="," read -r bblid scanid; do

        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ReproduceISLA.R $bblid $scanid /home/ttapera$restMask reho 3

        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ReproduceISLA.R $bblid $scanid /home/ttapera$restMask reho 4

done

