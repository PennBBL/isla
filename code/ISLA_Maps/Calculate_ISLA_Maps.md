
# Calculating ISLA Maps with IMCo

*By Tinashe M. Tapera*

*Updated 1 February 2019*


```bash
echo Last run `date`
```

    Last run Fri Feb 1 17:56:54 EST 2019


This document shows how to create ISLA images from the PNC datafreeze images. The following is just a walk through of the code; to execute it, a working version of the `imco` package is necessary, which currently only works on *singularity*.

First, gather the data and run `imco()`, which you can find in [this script](). The sample selection criteria can be examined [here](https://github.com/PennBBL/isla/blob/master/code/ReproducibilityScripts/n1601_SampleCreationNotebook.md).


```bash
# the value we're correlating with GMD
modality=cbf

# find the mask and the participant sample
cbfMask=/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz
cbfParticipants=/data/jux/BBL/projects/isla/data/cbfSample.csv

head $cbfParticipants
```

    "","bblid","scanid"
    "1",80812,2646
    "2",80607,2647
    "3",80249,2648
    "4",80854,2675
    "5",81826,2682
    "6",82232,2706
    "7",80575,2725
    "8",80425,2726
    "9",81287,2738


You can test your call to IMCo with a single participant:


```bash
bblid=81287
scanid=2738
output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid

# the size of the local kernel
size=3

/share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$cbfMask $modality $size
echo Done!
```

    During startup - Warning messages:
    1: Setting LC_CTYPE failed, using "C" 
    2: Setting LC_COLLATE failed, using "C" 
    3: Setting LC_TIME failed, using "C" 
    4: Setting LC_MESSAGES failed, using "C" 
    5: Setting LC_MONETARY failed, using "C" 
    6: Setting LC_PAPER failed, using "C" 
    7: Setting LC_MEASUREMENT failed, using "C" 
    [1] "Running imco with neighbourhood: 3,\nBBLID: 81287\nScanID: 2738,\nMask: /home/ttapera/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz"
    oro.nifti 0.9.1
    
    Attaching package: 'ANTsRCore'
    
    The following objects are masked from 'package:oro.nifti':
    
        origin, origin<-
    
    The following object is masked from 'package:stats':
    
        var
    
    The following objects are masked from 'package:base':
    
        all, any, apply, max, min, prod, range, sum
    
    
    Attaching package: 'extrantsr'
    
    The following objects are masked from 'package:ANTsRCore':
    
        origin, origin<-
    
    The following objects are masked from 'package:oro.nifti':
    
        origin, origin<-
    
    
    Attaching package: 'dplyr'
    
    The following object is masked from 'package:oro.nifti':
    
        slice
    
    The following objects are masked from 'package:stats':
    
        filter, lag
    
    The following objects are masked from 'package:base':
    
        intersect, setdiff, setequal, union
    
    [[1]]
    [1] FALSE
    
    [[2]]
    [1] TRUE
    
    [[3]]
    [1] TRUE
    
    [[4]]
    [1] TRUE
    
    [[5]]
    [1] TRUE
    
    [[6]]
    [1] TRUE
    
    [[7]]
    [1] TRUE
    
    [[8]]
    [1] TRUE
    
    [[9]]
    [1] TRUE
    
    There were 50 or more warnings (use warnings() to see the first 50)
    [1] "CBF read in successfully"
    [1] "GMD read in successully"
    [1] "mask read in successfully"
    # Extracting neighborhood data 
    # Computing weighted regressions 
    NULL
    Done!


Next, we extrapolate the maps using the script `Extrapolate.R`:


```bash
Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrapolate.R $output_images $bblid $scanid $modality
```

    Loading required package: oro.nifti
    oro.nifti 0.9.9
    
    Attaching package: ‘dplyr’
    
    The following object is masked from ‘package:oro.nifti’:
    
        slice
    
    The following objects are masked from ‘package:stats’:
    
        filter, lag
    
    The following objects are masked from ‘package:base’:
    
        intersect, setdiff, setequal, union
    
    Predict GMD=1 successful
    Predict GMD + slope successful
    Y image read in successful
    Complete


Lastly, we calculate the difference maps using `Calculate_Diff_Map.R`, which takes the same inputs:


```bash
Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Calculate_Diff_Map.R $output_images $bblid $scanid $modality
```

    Loading required package: oro.nifti
    oro.nifti 0.9.9
    Loading required package: neurobase
    
    Attaching package: ‘dplyr’
    
    The following objects are masked from ‘package:data.table’:
    
        between, first, last
    
    The following object is masked from ‘package:oro.nifti’:
    
        slice
    
    The following objects are masked from ‘package:stats’:
    
        filter, lag
    
    The following objects are masked from ‘package:base’:
    
        intersect, setdiff, setequal, union
    
    Isla read in successful
    Y image read in successful
    Complete


Now, for each of the images created, we want to modify the names such that they are compliant with our naming conventions. This is `{scanid}_imageName_vox{size}.nii.gz`, and for this we use the script `TidyRename.R`:


```bash
# note that the $modality flag has been replaced with the voxel size
Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/TidyRename.R $output_images $bblid $scanid $size
```

    
    Attaching package: ‘dplyr’
    
    The following objects are masked from ‘package:stats’:
    
        filter, lag
    
    The following objects are masked from ‘package:base’:
    
        intersect, setdiff, setequal, union
    
    [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE
    Files renamed successfully



```bash
echo $output_images
ls $output_images
```

    /data/jux/BBL/projects/isla/data/imco1/gmd_cbf/81287
    [0m[38;5;9m2738_beta0_vox3.nii.gz[0m      [38;5;9m2738_predictedGMD1_vox3.nii.gz[0m
    [38;5;9m2738_beta1_vox3.nii.gz[0m      [38;5;9m2738_predictedGMDobs_vox3.nii.gz[0m
    [38;5;9m2738_isla_diff_vox3.nii.gz[0m  [38;5;9m2738_rsquared_vox3.nii.gz[0m
    [38;5;9m2738_mixture_vox3.nii.gz[0m
    [m

(I think there's an error in the encoding of printed tabs when this is converted to .md)

I decided to wrap these three steps into one `Rscript`, `Extrap_Diff_Tidy.R`, because the process is bottlenecked by jumping in and out of R session. You can call it like so:


```bash
modality=cbf
bblid=81287
scanid=2738
output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid

# the size of the local kernel
size=3

/share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$cbfMask $modality $size
Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size

# the size of the local kernel
size=4

/share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$cbfMask $modality $size
Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size
```

    During startup - Warning messages:
    1: Setting LC_CTYPE failed, using "C" 
    2: Setting LC_COLLATE failed, using "C" 
    3: Setting LC_TIME failed, using "C" 
    4: Setting LC_MESSAGES failed, using "C" 
    5: Setting LC_MONETARY failed, using "C" 
    6: Setting LC_PAPER failed, using "C" 
    7: Setting LC_MEASUREMENT failed, using "C" 
    [1] "Running imco with neighbourhood: 3,\nBBLID: 81287\nScanID: 2738,\nMask: /home/ttapera/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz"
    oro.nifti 0.9.1
    
    Attaching package: 'ANTsRCore'
    
    The following objects are masked from 'package:oro.nifti':
    
        origin, origin<-
    
    The following object is masked from 'package:stats':
    
        var
    
    The following objects are masked from 'package:base':
    
        all, any, apply, max, min, prod, range, sum
    
    
    Attaching package: 'extrantsr'
    
    The following objects are masked from 'package:ANTsRCore':
    
        origin, origin<-
    
    The following objects are masked from 'package:oro.nifti':
    
        origin, origin<-
    
    
    Attaching package: 'dplyr'
    
    The following object is masked from 'package:oro.nifti':
    
        slice
    
    The following objects are masked from 'package:stats':
    
        filter, lag
    
    The following objects are masked from 'package:base':
    
        intersect, setdiff, setequal, union
    
    [[1]]
    [1] FALSE
    
    [[2]]
    [1] TRUE
    
    [[3]]
    [1] TRUE
    
    [[4]]
    [1] TRUE
    
    [[5]]
    [1] TRUE
    
    [[6]]
    [1] TRUE
    
    [[7]]
    [1] TRUE
    
    [[8]]
    [1] TRUE
    
    [[9]]
    [1] TRUE
    
    There were 50 or more warnings (use warnings() to see the first 50)
    [1] "CBF read in successfully"
    [1] "GMD read in successully"
    [1] "mask read in successfully"
    # Extracting neighborhood data 
    # Computing weighted regressions 
    NULL
    Loading required package: oro.nifti
    oro.nifti 0.9.9
    
    Attaching package: ‘dplyr’
    
    The following object is masked from ‘package:oro.nifti’:
    
        slice
    
    The following objects are masked from ‘package:stats’:
    
        filter, lag
    
    The following objects are masked from ‘package:base’:
    
        intersect, setdiff, setequal, union
    
    # Extrapolating...
    Predict GMD=1 successful
    Predict GMD + slope successful
    Y image read in successful
    Extrapolate Map Complete
    # Calculating Difference map...
    Isla read in successful
    Complete
    # Renaming...
    [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE
    Files named successfully
    ISLA IMAGES CALCULATED
    During startup - Warning messages:
    1: Setting LC_CTYPE failed, using "C" 
    2: Setting LC_COLLATE failed, using "C" 
    3: Setting LC_TIME failed, using "C" 
    4: Setting LC_MESSAGES failed, using "C" 
    5: Setting LC_MONETARY failed, using "C" 
    6: Setting LC_PAPER failed, using "C" 
    7: Setting LC_MEASUREMENT failed, using "C" 
    [1] "Running imco with neighbourhood: 4,\nBBLID: 81287\nScanID: 2738,\nMask: /home/ttapera/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz"
    oro.nifti 0.9.1
    
    Attaching package: 'ANTsRCore'
    
    The following objects are masked from 'package:oro.nifti':
    
        origin, origin<-
    
    The following object is masked from 'package:stats':
    
        var
    
    The following objects are masked from 'package:base':
    
        all, any, apply, max, min, prod, range, sum
    
    
    Attaching package: 'extrantsr'
    
    The following objects are masked from 'package:ANTsRCore':
    
        origin, origin<-
    
    The following objects are masked from 'package:oro.nifti':
    
        origin, origin<-
    
    
    Attaching package: 'dplyr'
    
    The following object is masked from 'package:oro.nifti':
    
        slice
    
    The following objects are masked from 'package:stats':
    
        filter, lag
    
    The following objects are masked from 'package:base':
    
        intersect, setdiff, setequal, union
    
    [[1]]
    [1] FALSE
    
    [[2]]
    [1] TRUE
    
    [[3]]
    [1] TRUE
    
    [[4]]
    [1] TRUE
    
    [[5]]
    [1] TRUE
    
    [[6]]
    [1] TRUE
    
    [[7]]
    [1] TRUE
    
    [[8]]
    [1] TRUE
    
    [[9]]
    [1] TRUE
    
    There were 50 or more warnings (use warnings() to see the first 50)
    [1] "CBF read in successfully"
    [1] "GMD read in successully"
    [1] "mask read in successfully"
    # Extracting neighborhood data 
    # Computing weighted regressions 
    NULL
    Loading required package: oro.nifti
    oro.nifti 0.9.9
    
    Attaching package: ‘dplyr’
    
    The following object is masked from ‘package:oro.nifti’:
    
        slice
    
    The following objects are masked from ‘package:stats’:
    
        filter, lag
    
    The following objects are masked from ‘package:base’:
    
        intersect, setdiff, setequal, union
    
    # Extrapolating...
    Predict GMD=1 successful
    Predict GMD + slope successful
    Y image read in successful
    Extrapolate Map Complete
    # Calculating Difference map...
    Isla read in successful
    Complete
    # Renaming...
    [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE
    Files named successfully
    ISLA IMAGES CALCULATED



```bash
ls /data/jux/BBL/projects/isla/data/imco1/gmd_cbf/81287
```

    [0m[38;5;9m2738_beta0_vox3.nii.gz[0m      [38;5;9m2738_mixture_vox4.nii.gz[0m
    [38;5;9m2738_beta0_vox4.nii.gz[0m      [38;5;9m2738_predictedGMD1_vox3.nii.gz[0m
    [38;5;9m2738_beta1_vox3.nii.gz[0m      [38;5;9m2738_predictedGMD1_vox4.nii.gz[0m
    [38;5;9m2738_beta1_vox4.nii.gz[0m      [38;5;9m2738_predictedGMDobs_vox3.nii.gz[0m
    [38;5;9m2738_isla_diff_vox3.nii.gz[0m  [38;5;9m2738_predictedGMDobs_vox4.nii.gz[0m
    [38;5;9m2738_isla_diff_vox4.nii.gz[0m  [38;5;9m2738_rsquared_vox3.nii.gz[0m
    [38;5;9m2738_mixture_vox3.nii.gz[0m    [38;5;9m2738_rsquared_vox4.nii.gz[0m
    [m

The final `qsub` call is in `/data/jux/BBL/projects/isla/code/qsub_Calls/ComputeISLAMaps.sh`, which loops over the samples like so:


```bash
##### CBF ####
echo CBF.....
modality=cbf

# Read in the data
cbfMask=/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz
cbfParticipants=/data/jux/BBL/projects/isla/data/Reproducibility/cbfSample.csv

#### SIZE ####
size=3
 Loop through CBF participants and execute
sed 1d $cbfParticipants | while IFS="," read -r row bblid scanid; do

        output_images=/data/jux/BBL/projects/isla/data/imco1/gmd_$modality/$bblid
        /share/apps/singularity/2.5.1/bin/singularity exec -B /data:/home/ttapera/data /data/joy/BBL/applications/bids_apps/imco1.simg Rscript /home/ttapera/data/jux/BBL/projects/isla/code/ISLA_Maps/IMCo_Call.R $bblid $scanid /home/ttapera$cbfMask $modality $size
        Rscript /data/jux/BBL/projects/isla/code/ISLA_Maps/Extrap_Diff_Tidy.R $output_images $bblid $scanid $modality $size

done
```
