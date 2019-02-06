
# Parallelising ISLA Map Calculation

Instead of waiting ages for a series job we will parallelise the process with an SGE task array.

We'll run cbf, alff, and reho as separate scripts, firstly. Each script will run both size parameters 3 & 4, but the SGE task array will operate on the BBLID and ScanID variables. For example, for the CBF script:


```bash
echo CBF.....
modality=cbf

# Read in the data
cbfMask=/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz
cbfParticipants=/data/jux/BBL/projects/isla/data/cbfSample.csv

for x in `seq 1 3`;
do
    # the lines below uses awk to assign the value of a csv to the variable
    bblid=$(awk -F, -v "line=$x" 'NR==line+1 {print $2}' $cbfParticipants)
    scanid=$(awk -F, -v "line=$x" 'NR==line+1 {print $3}' $cbfParticipants)
    
    size=3
    output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid
    echo
    echo /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$cbfMask $modality $size
    echo Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size

    echo

    size=4
    output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid
    echo /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$cbfMask $modality $size
    echo Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size
    echo ---
done
```

    CBF.....
    
    /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R 80812 2646 /home/ttapera/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz cbf 3
    Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R /data/jux/BBL/projects/isla/data/imco1/gmd_cbf/80812 80812 2646 cbf 3
    
    /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R 80812 2646 /home/ttapera/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz cbf 4
    Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R /data/jux/BBL/projects/isla/data/imco1/gmd_cbf/80812 80812 2646 cbf 4
    ---
    
    /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R 80607 2647 /home/ttapera/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz cbf 3
    Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R /data/jux/BBL/projects/isla/data/imco1/gmd_cbf/80607 80607 2647 cbf 3
    
    /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R 80607 2647 /home/ttapera/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz cbf 4
    Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R /data/jux/BBL/projects/isla/data/imco1/gmd_cbf/80607 80607 2647 cbf 4
    ---
    
    /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R 80249 2648 /home/ttapera/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz cbf 3
    Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R /data/jux/BBL/projects/isla/data/imco1/gmd_cbf/80249 80249 2648 cbf 3
    
    /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R 80249 2648 /home/ttapera/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz cbf 4
    Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R /data/jux/BBL/projects/isla/data/imco1/gmd_cbf/80249 80249 2648 cbf 4
    ---


Above, we've managed to use `awk` to assign the values from a csv to the variable. In this case, `x` comes from the sequence loop. Using an SGE task array, we can replace `x` with the `SGE_TASK_ID` variable, and loop the script using the flag `-t` in the preamble. We also have to skip the first line of the loop since there is a header.

```
NOT RUN

#!/bin/bash
#$ -t 2:4

echo CBF.....
modality=cbf

# Read in the data
cbfMask=/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz

# the line below uses awk to assign the value of a csv to the variable
bblid=$(awk -F, -v "line=$SGE_TASK_ID" 'NR==line+1 {print $2}' /data/jux/BBL/projects/isla/data/cbfSample.csv)
scanid=$(awk -F, -v "line=$SGE_TASK_ID" 'NR==line+1 {print $3}' /data/jux/BBL/projects/isla/data/cbfSample.csv)

size=3
output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid
echo
echo /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$cbfMask $modality $size
echo Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size

echo

size=4
output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid
echo /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$cbfMask $modality $size
echo Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size
echo ---
```
