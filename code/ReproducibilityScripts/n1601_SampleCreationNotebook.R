#' ---
#' title: "ISLA Sample Creation"
#'---
#'
#' This code recreates the n1601 PNC samples for ISLA coupling. It does this by examining quality assessment files and excluding relevant participants.
#'
#' First, read in the global sample:

#+ echo=TRUE,message=FALSE
require(dplyr, quietly=T)
medical = read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/health/n1601_health_20170421.csv")
t1QA = read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_t1QaData_20170306.csv")
cbfQA = read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/n1601_PcaslQaData_20170403.csv")
restQA = read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/rest/n1601_RestQAData_20170714.csv")
#' 
#'
#' We can join the spreadsheets by BBLID.
#'
#' # For CBF Maps
#'
cbfSample = medical%>%
  left_join(t1QA, by="bblid")%>%
  left_join(cbfQA, by="bblid")
#'
#' We want to remove participants who are positive for low threshold norm `ltnExcludev2`, T1 `t1Exclude`, and cbf `pcaslVoxelwiseExclude`.
#'
cbfSample=cbfSample%>%as_tibble()%>%
  #select variables to filter from
  filter_at(.vars = vars(one_of(c("ltnExcludev2", "t1Exclude", "pcaslVoxelwiseExclude"))),
            #return rows that are not 1 for all of these variables
            .vars_predicate = all_vars(. != 1))%>%
  select(bblid, scanid=scanid.x)
#'
#' The isla/CBF sample should contain 1132 participants.
#'
nrow(cbfSample)
#'
#' # For Reho/Alff Maps
#'
#'
restSample = medical%>%
  left_join(t1QA, by="bblid")%>%
  left_join(restQA, by="bblid")
#'
#' We want to remove participants who are positive for low threshold norm `ltnExcludev2`, T1 `t1Exclude`, and rest `restExcludeVoxelwise`.
#'
restSample=restSample%>%as_tibble()%>%
  #select variables to filter from
  filter_at(.vars = vars(one_of(c("ltnExcludev2", "t1Exclude", "restExcludeVoxelwise"))),
            #return rows that are not 1 for all of these variables
            .vars_predicate = all_vars(. != 1))%>%
  select(bblid, scanid=scanid.x)
#'
#' The isla/Reho-Alff sample should contain 869 participants.
#'
nrow(restSample)

#' Write out the sample:
write.csv(cbfSample, "/data/jux/BBL/projects/isla/data/cbfSample.csv")
write.csv(restSample, "/data/jux/BBL/projects/isla/data/restSample.csv")
