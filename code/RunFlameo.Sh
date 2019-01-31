unset PYTHONPATH; unalias python
export PATH=/data/joy/BBL/applications/miniconda3/bin:$PATH
source activate py2k
flameo --copefile=/data/jux/BBL/projects/isla/data/sandbox/merged_ISLA_CBF_3.nii.gz  --mask=/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/gm10pcalcovemask.nii.gz  --dm=/data/jux/BBL/projects/isla/data/sandbox/covariates.mat --tc=/data/jux/BBL/projects/isla/data/sandbox/contrast.con --cs=/data/jux/BBL/projects/isla/data/sandbox/group.grp --runmode=flame1 --ld=/data/jux/BBL/projects/isla/results/flameo/s_age_s_agebysex_sex_cbfMotion
