##### CBF ####
echo CBF.....
modality=cbf

# Read in the data
cbfMask=/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz
cbfParticipants=/data/jux/BBL/projects/isla/data/Reproducibility/cbfSample.csv

#### SIZE ####
size=3
# Loop through CBF participants and execute
sed 1d $cbfParticipants | while IFS="," read -r bblid scanid; do
	
	output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid
        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$cbfMask $modality $size
	Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size

done

#### SIZE ####
size=4
# Loop through CBF participants and execute
sed 1d $cbfParticipants | while IFS="," read -r bblid scanid; do

        output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid
        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$cbfMask $modality $size
        Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size

done

##### Alff ####
echo ALFF.......
modality=alff

# Read in the data
restMask=/data/jux/BBL/projects/isla/data/Masks/gm10perc_RestCoverageMask.nii.gz
restParticipants=/data/jux/BBL/projects/isla/data/Reproducibility/restSample.csv

#### SIZE ####
size=3
# Loop through alff participants and execute
sed 1d $restParticipants | while IFS="," read -r bblid scanid; do

        output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid
        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$restMask $modality $size
        Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size

done

#### SIZE ####
size=4
# Loop through alff participants and execute
sed 1d $restParticipants | while IFS="," read -r bblid scanid; do

        output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid
        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$restMask $modality $size
        Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size

done

##### Reho ####
echo Reho.......
modality=reho

# Read in the data
restMask=/data/jux/BBL/projects/isla/data/Masks/gm10perc_RestCoverageMask.nii.gz
restParticipants=/data/jux/BBL/projects/isla/data/Reproducibility/restSample.csv

#### SIZE ####
size=3
# Loop through reho participants and execute
sed 1d $restParticipants | while IFS="," read -r bblid scanid; do

        output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid
        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$restMask $modality $size
        Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size

done

#### SIZE ####
size=4
# Loop through reho participants and execute
sed 1d $restParticipants | while IFS="," read -r bblid scanid; do

        output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid
        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$restMask $modality $size
        Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size

done
