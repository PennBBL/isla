# 1: source imco scripts
require(R.utils)
sourceDirectory("/data/jux/BBL/projects/coupling/imcoScripts/restCbf/dependencies/")

# 2: remove clashes
rm(antsImageHeaderInfo)
rm(antsImageRead)

# 3: get antsr
require(ANTsR)

# 3: get neurobase
require(neurobase)

# 4: get extrantsr
sourceDirectory("/data/jux/BBL/projects/isla/isla/data/packages/extrantsr")

# 5: set cbf and alff maps
alffNorm = antsImageRead("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_alff/8309_alffStd.nii.gz", dimension = 4)
cbfNorm = antsImageRead("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf/8309_asl_quant_ssT1Std.nii.gz", dimension = 4)
fls = list()
fls[[1]] = alffNorm
fls[[2]] = cbfNorm

# 6: set mask
maskImg = antsImageRead("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/pncTemplate/pnc_template_brain_mask_2mm.nii.gz", dimension=4)

setwd("/data/jux/BBL/projects/isla/")

imco(fls, brainMask=maskImg, subMask = NULL, type="regression", outDir = "./isla/results/", fwhm=1)

## Error in .Call("antsImage_GetNeighborhoodMatrix", image, mask, radius,  : 
##  C symbol name "antsImage_GetNeighborhoodMatrix" not in load table