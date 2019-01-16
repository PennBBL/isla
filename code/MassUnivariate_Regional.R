#' ---
#' title: "Multivariate ROI-based `gam()`"
#' author: "Tinashe M. Tapera"
#' date: "2018-01-15"
#' output: html_document
#' ---

#' Here we demonstrate the multivariate ROI-based `gam()` for `CBF ~ s(age, by=sex)`. First, for raw CBF data, and then, for ISLA-corrected CBF data.

#+ setup, echo=FALSE
require(mgcv)
require(ggplot2)
require(visreg)
#require(RLRsim)
require(dplyr)
require(purrr)
require(tidyr)
require(broom)
require(readr)
set.seed(1000)

#' First, gather the data and join the demographics. We also create an *ordered factor* for sex.

cbf <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/n1601_jlfAntsCTIntersectionPcaslValues_20170403.csv") %>%
  as_tibble()
demographics <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/demographics/n1601_demographics_go1_20161212.csv") %>%
  as_tibble()

df <- demographics %>% left_join(cbf)

df <- df %>%
  mutate(sex = as.ordered(as.factor(sex)),
         age = ageAtScan1 / 12)

#' Now, we run the model. We use tidyverse-style gathering, nesting, mapping, and tidy output.

nested <- df %>%
  gather(var, val, starts_with("pca")) %>%
  group_by(var) %>%
  nest()

my_gam <- function(data_in){

  g <- gam(val ~ s(age, by=sex), data=data_in)
  g$data <- data_in
  return(g)

}

models <- nested %>%
  mutate(model = map(.x = data, .f = my_gam)) %>%
  mutate(results = map(model, tidy))

#' Observing the results of one the models:
# pull the model object for visualisation later
# example of single ROI
models %>%
  sample_n(1) %>%
  assign("roi", ., envir = .GlobalEnv) %>%
  pull(model) %>%
  .[[1]] %>%
  visreg(., "age", plot = TRUE, gg = TRUE)+
  labs(title = paste("ROI:", roi$var))

# write an rds of models to results directory if on CHEAD and accessible
# note: this will need to be reopened as a tibble using readr::
# as it contains list columns
output <- file.path("/data/jux/BBL/projects/isla/results/")

if(dir.exists(output)) {

  rds_name <- paste("Univar_ROI", Sys.Date(), sep = "_") %>%
    paste(., ".rds", sep = "")

  save_rds(models, file = paste0(output, rds_name))
}

str(models)
