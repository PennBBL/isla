Steps to reproduce ISLA paper analyses:

- For each R script that gets inputs from command line, there should be an associated .sh script(s) in /bash_scripts that I used to submit the job with the necessary inputs.

# Run IMCo

1. Run /run/runIMCo.R 
- Produces regression parameter images
- Command line options include neighborhood size (run separately with radius 3 and 4)


# Extract feature images

2. Run /extract/extrapolate.R 
- To get predicted CBF images for each subject (GMD=1, and GMD=obs)
- This also creates maps that are mixtures of CBF and ISLA where R^2 is the mixing parameter.
- Can use check.R to make sure all images were created

3. Run /extract/difference_maps.R 
- To get ISLA-CBF for each subject


# Average images

4. Run /means/mean_gmd_cbf_alff_reho.R 
- To get average GMD, CBF, ALFF, REHO across subjects

5. Run /means/mean_imco_maps.R
- To get all average IMCO-derived images across subjects


# Hypothesis testing with FLAMEO (code sources the functions.R script)

5. Run /flameo/makeDataFramesForFlameo.R for each type (cbf, alff, reho) and radius size (3, 4)
- IMPORTANT NOTE: Need to manually change these parameters in script before running (not ideal!)
- This sets up data frames for convenience later.

6. Run /flameo/flameo_isla.R for all types (cbf, alff, reho)
- Tests nonlinear (CBF) or linear (ALFF/REHO) age by sex interaction using ISLA images as outcome.
- IMPORTANT NOTE: I removed two subjects with Overall_Accuracy=NA. Since we are planning to remove this covariate from the models, we do not need to remove those subjects.

7. Run /flameo/flameo_orig.R 
- Tests nonlinear (CBF) or linear (ALFF/REHO) age by sex interaction using original modalities as outcome.

8. Run /flameo/flameo_orig_smooth.R
- Tests nonlinear (CBF) or linear (ALFF/REHO) age by sex interaction using smoothed images as outcome.
- IMPORTANT NOTE: flameo_orig_smooth.R can be edited so that you don't re-compute the smoothed images.




