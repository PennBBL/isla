unset PYTHONPATH; unalias python
export PATH=/data/joy/BBL/applications/miniconda3/bin:$PATH
source activate py2k
Rscript /data/jux/BBL/projects/isla/code/voxelwiseWrappers/gam_voxelwise.R -c /data/jux/BBL/projects/isla/data/sandbox/voxelwise_gam_covariates.rds -o /data/jux/BBL/projects/isla/results/ -p path -m /data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/gm10pcalcovemask.nii.gz -s 0 -i include -u scanid -f "~s(age)+s(age,by=sex)+sex+pcaslRelMeanRMSMotion" -a fdr -n 5 -s 0 -k 10
