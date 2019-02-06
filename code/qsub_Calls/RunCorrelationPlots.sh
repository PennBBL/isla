unset PYTHONPATH; unalias python
export PATH=/data/joy/BBL/applications/miniconda3/bin:$PATH
source activate py2k

Rscript -e "rmarkdown::render('/data/jux/BBL/projects/isla/code/Correlations/CorrelationPlots.R', rmarkdown::github_document(html_preview = FALSE, df_print = 'kable'), clean = TRUE)"
