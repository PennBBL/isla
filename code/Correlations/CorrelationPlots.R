#' ---
#' title: "GMD Correlation Plots"
#' author: "Tinashe M. Tapera"
#' date: "2018-02-04"
#' ---

#+ setup
suppressPackageStartupMessages({
  library(tidyr, quietly = TRUE)
  library(dplyr, quietly = TRUE)
  library(knitr, quietly = TRUE)
  library(ggplot2, quietly = TRUE)
  library(magrittr, quietly = TRUE)
  library(stringr, quietly = TRUE)
  library(oro.nifti, quietly = TRUE)
  library(purrr, quietly = TRUE)
  library(ggpubr, quietly = TRUE)
  library(fslr, quietly = TRUE)
})
set.seed(1000)
SAMPLE <- TRUE # sample the full data if memory is limited e.g. not in qsub
#' # Introduction
#' Here we visualise the relationship between voxelwise GMD values and CBF, Alff, and Reho in the PNC sample for ISLA. This method uses spatial correlation between two variables. As an example, here we calculate the spatial correlation between one participant's GMD and CBF measures.

gmd_path <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/voxelwiseMaps_gmd")
mask_path <- file.path("/data/jux/BBL/projects/isla/data/Masks/gm10perc_PcaslCoverageMask.nii.gz")
cbf_path <- file.path("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/voxelwiseMaps_cbf")

# one gmd image
gmd_example <-
  list.files(gmd_path,
    pattern = regex("[^tmp.nii.gz]"),
    full.names = TRUE)[1:2] %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  select(scanid, everything())

# the same scanid's cbf image
cbf_example <-
  list.files(cbf_path,
    pattern = regex("[^tmp.nii.gz]"),
    full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  select(scanid, everything()) %>%
  filter(scanid == gmd_example$scanid)

# the mask for this sample
pcasl_mask <- readNIfTI(mask_path)

#' Here's a helper function to read in two images from a participant, parse the voxelwise data, mask it, and return the data as two separate vectors (corresponding to the unraveled voxel matrix for image 1 and image 2 respectively).
read_and_load <- function(img_path1, img_path2, mask_img){

  dat1 <- readNIfTI(img_path1)
  dat1 <- img_data(dat1)
  dat1 <- dat1[mask_img ==1]

  dat2 <- readNIfTI(img_path2)
  dat2 <- img_data(dat2)
  dat2 <- dat2[mask_img ==1]

  data_frame(V1 = dat1, V2 = dat2)
}

df <- left_join(cbf_example, gmd_example, by = "scanid") %>%
  mutate(niftis = map2(
    .x = path.x,
    .y = path.y,
    read_and_load,
    mask_img  = pcasl_mask
    )
  ) %>%
  unnest(niftis)

#' Thus, we have this dataframe:
df %>% select(V1, V2, scanid) %>% dplyr::slice(1:10) %>% kable()

#' Which we can plot like so:
df %>%
  ggplot(aes(x = V1, y = V2)) +
    geom_point(aes(color = scanid), alpha = 0.2) +
    labs(
      x = "CBF",
      y = "GMD",
      title = "Voxelwise GMD & CBF"
    )

#' But as we add more participants, we will need high density plotting methods, which will consequently look like this:
df %>%
  ggplot(aes(x = V1, y = V2))+
  geom_hex() +
  labs(
    x = "CBF",
    y = "GMD",
    title = "Voxelwise GMD & CBF",
    caption = "Spearman Correlation Shown"
  ) +
  stat_cor(method = "spearman")

#' Looks good!
#'
#' # GMD~CBF
#'
#' We specify the sample here:
cbf_sample <- read.csv("/data/jux/BBL/projects/isla/data/cbfSample.csv") %>%
  select(-X) %>%
  { if( SAMPLE ) sample_n(., 50) else .}

#' And read in the images:
gmd_images <-
  list.files(gmd_path,
    pattern = regex("[^tmp.nii.gz]"),
    full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  filter(scanid %in% cbf_sample$scanid) %>%
  select(scanid, everything())

cbf_images <-
  list.files(cbf_path,
    pattern = regex("[^tmp.nii.gz]"),
    full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  filter(scanid %in% cbf_sample$scanid) %>%
  select(scanid, everything())

#' Join paths and get the voxel data:
df <- left_join(cbf_images, gmd_images, by = "scanid") %>%
  mutate(niftis = map2(
    .x = path.x,
    .y = path.y,
    read_and_load,
    mask_img  = pcasl_mask
    )
  ) %>%
  unnest(niftis)

#' And plot:
df %>%
  ggplot(aes(x = V1, y = V2))+
  geom_hex() +
  labs(
    x = "CBF",
    y = "GMD",
    title = "Voxelwise GMD & CBF",
    caption = "Spearman Correlation Shown"
  ) +
  stat_cor(method = "spearman") +
  theme_minimal()

#' # GMD~Alff
#'
#' We specify the sample, image paths, and mask here:
rest_sample <- read.csv("/data/jux/BBL/projects/isla/data/restSample.csv") %>%
  select(-X) %>%
  { if( SAMPLE ) sample_n(., 50) else .}

alff_path <- "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_alff"
mask_path <- file.path("/data/jux/BBL/projects/isla/data/Masks/gm10perc_RestCoverageMask.nii.gz")
rest_mask <- readNIfTI(mask_path)

#' And read in the images:
gmd_images <-
  list.files(gmd_path,
    pattern = regex("[^tmp.nii.gz]"),
    full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  filter(scanid %in% rest_sample$scanid) %>%
  select(scanid, everything())

alff_images <-
  list.files(alff_path,
    pattern = regex("[^tmp.nii.gz]"),
    full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  filter(scanid %in% rest_sample$scanid) %>%
  select(scanid, everything())

#' Join paths and get the voxel data:
df <- left_join(alff_images, gmd_images, by = "scanid") %>%
  mutate(niftis = map2(
    .x = path.x,
    .y = path.y,
    read_and_load,
    mask_img  = rest_mask
    )
  ) %>%
  unnest(niftis)

#' And plot:
df %>%
  ggplot(aes(x = V1, y = V2))+
  geom_hex() +
  labs(
    x = "Alff",
    y = "GMD",
    title = "Voxelwise GMD & Alff",
    caption = "Spearman Correlation Shown"
  ) +
  stat_cor(method = "spearman") +
  theme_minimal()

#' # GMD~Reho
#'
#' Sample and mask are already specified, we just need the path to `reho` images:
reho_path <- "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_reho"

#' And read in the images (`gmd` is already specified):
reho_images <-
  list.files(reho_path,
    pattern = regex("[^tmp.nii.gz]"),
    full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  filter(scanid %in% rest_sample$scanid) %>%
  select(scanid, everything())

#' Join paths and get the voxel data:
df <- left_join(reho_images, gmd_images, by = "scanid") %>%
  mutate(niftis = map2(
    .x = path.x,
    .y = path.y,
    read_and_load,
    mask_img  = rest_mask
    )
  ) %>%
  unnest(niftis)

#' And plot:
df %>%
  ggplot(aes(x = V1, y = V2))+
  geom_hex() +
  labs(
    x = "Reho",
    y = "GMD",
    title = "Voxelwise GMD & Reho",
    caption = "Spearman Correlation Shown"
  ) +
  stat_cor(method = "spearman") +
  theme_minimal()

#' Done!
---
#' Session info:
print(R.version.string)
print(paste("Updated:", format(Sys.time(), "%Y-%m-%d")))
