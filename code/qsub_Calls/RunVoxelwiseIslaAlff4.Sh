unset PYTHONPATH; unalias python
export PATH=/data/joy/BBL/applications/miniconda3/bin:$PATH
source activate py2k
Rscript /data/jux/BBL/projects/isla/code/voxelwiseWrappers/gam_voxelwise.R -c /data/jux/BBL/projects/isla/data/sandbox/voxelwise_gam_covariates_ISLA_Alff4.rds -o /data/jux/BBL/projects/isla/results/VoxelWrapperModels/imco1/alff4/ -p path -m /data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz -s 0 -i include -u scanid -f "~s(age)+s(age,by=sex)+sex+restRelMeanRMSMotion" -a fdr -n 5 -s 0 -k 10
