GMD Correlation Plots
================
Tinashe M. Tapera
2018-02-04

``` r
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
```

Introduction
============

Here we visualise the relationship between voxelwise GMD values and CBF, Alff, and Reho in the PNC sample for ISLA. This method uses spatial correlation between two variables. As an example, here we calculate the spatial correlation between one participant's GMD and CBF measures.

``` r
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
```

Here's a helper function to read in two images from a participant, parse the voxelwise data, mask it, and return the data as two separate vectors (corresponding to the unraveled voxel matrix for image 1 and image 2 respectively).

``` r
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
```

Thus, we have this dataframe:

``` r
df %>% select(V1, V2, scanid) %>% dplyr::slice(1:10) %>% kable()
```

|        V1|         V2| scanid |
|---------:|----------:|:-------|
|  62.30502|  0.5212537| 2632   |
|  64.30900|  0.4469181| 2632   |
|  47.89041|  0.7689906| 2632   |
|  65.06439|  0.6920645| 2632   |
|  63.04266|  0.5696578| 2632   |
|  48.06977|  0.4684488| 2632   |
|  34.84156|  0.4330546| 2632   |
|  43.26994|  0.7330206| 2632   |
|  55.80533|  0.5681143| 2632   |
|  58.27440|  0.4699323| 2632   |

Which we can plot like so:

``` r
df %>%
  ggplot(aes(x = V1, y = V2)) +
    geom_point(aes(color = scanid), alpha = 0.2) +
    labs(
      x = "CBF",
      y = "GMD",
      title = "Voxelwise GMD & CBF"
    )
```

![](CorrelationPlots_files/figure-markdown_github/unnamed-chunk-4-1.png)

But as we add more participants, we will need high density plotting methods, which will consequently look like this:

``` r
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
```

    ## Loading required package: methods

![](CorrelationPlots_files/figure-markdown_github/unnamed-chunk-5-1.png)

Looks good!

GMD~CBF
=======

We specify the sample here:

``` r
cbf_sample <- read.csv("/data/jux/BBL/projects/isla/data/cbfSample.csv") %>%
  select(-X) %>%
  { if( SAMPLE ) sample_n(., 5) else .}
```

And read in the images:

``` r
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
```

Join paths and get the voxel data:

``` r
df <- left_join(cbf_images, gmd_images, by = "scanid") %>%
  mutate(niftis = map2(
    .x = path.x,
    .y = path.y,
    read_and_load,
    mask_img  = pcasl_mask
    )
  ) %>%
  unnest(niftis)
```

And plot:

``` r
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
```

![](CorrelationPlots_files/figure-markdown_github/unnamed-chunk-9-1.png)

GMD~Alff
========

We specify the sample, image paths, and mask here:

``` r
rest_sample <- read.csv("/data/jux/BBL/projects/isla/data/restSample.csv") %>%
  select(-X) %>%
  { if( SAMPLE ) sample_n(., 5) else .}

alff_path <- "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_alff"
mask_path <- file.path("/data/jux/BBL/projects/isla/data/Masks/gm10perc_RestCoverageMask.nii.gz")
rest_mask <- readNIfTI(mask_path)
```

And read in the images:

``` r
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
```

Join paths and get the voxel data:

``` r
df <- left_join(alff_images, gmd_images, by = "scanid") %>%
  mutate(niftis = map2(
    .x = path.x,
    .y = path.y,
    read_and_load,
    mask_img  = rest_mask
    )
  ) %>%
  unnest(niftis)
```

And plot:

``` r
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
```

![](CorrelationPlots_files/figure-markdown_github/unnamed-chunk-13-1.png)

GMD~Reho
========

Sample and mask are already specified, we just need the path to `reho` images:

``` r
reho_path <- "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/voxelwiseMaps_reho"
```

And read in the images (`gmd` is already specified):

``` r
reho_images <-
  list.files(reho_path,
    pattern = regex("[^tmp.nii.gz]"),
    full.names = TRUE) %>%
  tibble(path = .) %>%
  mutate(scanid = str_extract(path, "(?<=/)[:digit:]{4,}")) %>%
  filter(scanid %in% rest_sample$scanid) %>%
  select(scanid, everything())
```

Join paths and get the voxel data:

``` r
df <- left_join(reho_images, gmd_images, by = "scanid") %>%
  mutate(niftis = map2(
    .x = path.x,
    .y = path.y,
    read_and_load,
    mask_img  = rest_mask
    )
  ) %>%
  unnest(niftis)
```

And plot:

``` r
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
```

![](CorrelationPlots_files/figure-markdown_github/unnamed-chunk-17-1.png)

Done!

Session info:

``` r
print(R.version.string)
```

    ## [1] "R version 3.4.1 (2017-06-30)"

``` r
print(paste("Updated:", format(Sys.time(), "%Y-%m-%d")))
```

    ## [1] "Updated: 2019-02-07"
