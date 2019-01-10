# How to Recreate ISLA Masks

*By Tinashe M. Tapera*

*Updated 20 December 2018*

In order to run `imco()` models, we need to be able to recreate the brain masks used previously. Hence, this document walks through the basic steps of recreating the mask.

## Step 1: Threshold & Binarize

The first step is to take the existing PNC brain grey matter mask and apply a threshold for the signal; this threshold is the cutoff point with which we discretize/binarize the volume. This creates a volume where values above threshold are 0, and values below threshold are 1. This is done in `fslmaths` in the shell with the following command:

```
fslmaths /data/joy/BBL/studies/pnc/template/priors/prior_002_2mm.nii.gz  -thr 0.1 -bin  PNCgreymatter
```

The output nifti is the last argument

## Step 2: Multiply The Coverage Mask By the Binarized Mask

In this step, we grab the binarized grey matter mask and multiply it by the coverage mask. For CBF, this is the PCASL mask, and for Alff/Reho it's the Resting state mask. Again, we use `fslmaths` to accomplish this:

```
# for cbf

fslmaths PNCgreymatter -mul /data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/n1601_PcaslCoverageMask.nii.gz  gm10perc_PcaslCoverageMask.nii.gz
```

```
# for alff and reho

fslmaths PNCgreymatter -mul /data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/n1601_RestCoverageMask_20170509.nii.gz  gm10perc_RestCoverageMask.nii.gz
```

The output nifti is the last argument. I ran these scripts in the pre-existing directory `/data/jux/BBL/projects/isla/data/Masks`, and that's where all references to Masks in this project come from.

------------
