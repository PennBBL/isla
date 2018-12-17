---
title: "Reproduce Individual ISLA Maps"
output: html_document
---

This document shows how to reproduce ISLA maps for a small sample of participants. The following is just a walk through of the code; to execute it, a working version of the `imco` package is necessary, which currently only works on *singularity*.

# 1. Using Singularity To Run `imco()`

We submit each participant's data to a singularity instance to run the `imco()` function. This is done with the script `SubmitReproduceISLA.sh`, which loops through the participants' lists in `/data/jux/BBL/projects/isla/results/Reproducibility/`, and runs the singularity instance for each with the script `ReproduceISLA.R`. The parameters are dependant on the modality and neighborhood size, as well as the corresponding modality mask. For example:

```
# Read in the data
cbfMask=/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz
cbfParticipants=/data/jux/BBL/projects/isla/data/Reproducibility/cbfSample.csv

# Loop through CBF participants and execute
sed 1d $cbfParticipants | while IFS="," read -r bblid scanid; do

        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ReproduceISLA.R $bblid $scanid /home/ttapera$cbfMask cbf 3

        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ReproduceISLA.R $bblid $scanid /home/ttapera$cbfMask cbf 4
done
```

The output of this step is the first set of maps `beta0.nii.gz`,`beta1.nii.gz`, and `rsquared.nii.gz` in `.../isla/results/Reproducibility/*/*/*/*/reproduced/`.

# 2. Extrapolating Maps

Using the script `SubmitReproduceExtrapolate.sh`, we loop through all of the results from the previous step and extrapolate the maps with the script `ReproduceExtrapolate.R`. This script uses the path to the input file to determine the parameters and runs extrapolation, adding the results once again to `.../isla/results/Reproducibility/*/*/*/*/reproduced/`

# 3. Calculating Difference Maps

Finally, we use the script `SubmitReproduceDifferenceMaps.sh` to run `ReproduceDifferenceMaps.R`, which loops through all of our prior results and calculates the difference between the final Y image and the mask. The results are again written to `.../isla/results/Reproducibility/*/*/*/*/reproduced/`

