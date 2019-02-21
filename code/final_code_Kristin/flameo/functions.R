library(mgcv)
library(RNifti)
### FLAMEO OLS WRAPPER ###
# filelist and dat should be in the same order
# filelist can be a 4d nifti image
# use full directories for input images and outdir
# X and Xred can be formulas (as characters) or design matrices
flameo = function(filelist=NULL, dat=NULL, maskfile=NULL, X=NULL, Xred=NULL, voxelev=NULL, outdir=NULL, run=TRUE){
	dir.create(outdir, showWarnings=FALSE)
	mergednifti=file.path(outdir, 'merged.nii.gz')
	covnifti=file.path(outdir, 'covar.nii.gz')
	# if filelist is 1 file assume it is a merged nifti
	if(length(filelist)==1){
		mergednifti=filelist
	}
	# merge images
	if(!file.exists(mergednifti)){
		mergeimages(filelist, mergednifti)
	}
	# voxelwise covariate. Only written for one 4d image
	if(!is.null(voxelev)){
		if(length(voxelev)==1){
			covnifti=voxelev
		}
		# merge covariate images
		if(!file.exists(covnifti)){
			mergeimages(voxelev, covnifti)
		}
	}
	## DESIGN AND CONTRASTS ##
	# design file
	if( is.character(X)){
		X = getdesign(X, dat)
	}
	n = nrow(X)
	p = ncol(X)
	# load reduced model if
	if(is.character(Xred)){
		Xred = getdesign(Xred, dat)
	}
	if(!is.null(Xred)){
		p2 = p - ncol(Xred)
	}
	# if there is a voxelwise covariate enlarge design matrices by 1
	if(!is.null(voxelev)){
		p=p+1
		# last column doesn't matter and isn't read by flameo (but has to be there)
		X=cbind(X, 1:n)
	}
	# the voxelwise covariate will be in the last column
	matfile = file.path(outdir, 'design.mat')
	cat('/NumWaves\t', ncol(X), '\n/NumPoints\t', nrow(X), '\n/PPheights\t', paste(apply(X, 2, function(x) abs(diff(range(x))) ), collapse='\t'), '\n\n/Matrix\n', sep='', file=matfile)
	write.table(X, append=TRUE, file=matfile, row.names=FALSE, col.names=FALSE)

	# contrast file
	confile1 = file.path(outdir, 'design.con') # for f-test
	# perform all t-tests
	cons = diag(p)
	cat('/ContrastName1\t temp\n/ContrastName2\t\n/NumWaves\t', ncol(X), '\n/NumPoints\t', nrow(cons), '\n/PPheights\t', paste(rep(1,ncol(cons)), collapse='\t'), '\n/RequiredEffect\t1\t1\n\n/Matrix\n', sep='', file=confile1)
	write.table(cons, append=TRUE, file=confile1, row.names=FALSE, col.names=FALSE)

	# fts file
	if(!is.null(Xred)){
		ftsfile = file.path(outdir, 'design.fts')
		fts = matrix(0, nrow=1, ncol=nrow(cons)) # ftest of all contrasts
		# which variables to ftest
		fts[ which(! colnames(X) %in% colnames(Xred) )] = 1
		fts[length(fts)] = 0
		cat('/NumWaves\t', nrow(cons), '\n/NumContrasts\t', 1, '\n\n/Matrix\n', sep='', file=ftsfile)
		write.table(fts, append=TRUE, file=ftsfile, row.names=FALSE, col.names=FALSE)
	}

	# make group file. Assumes homoskedastic variance
	grpfile = file.path(outdir, "design.grp")
	cat('/NumWaves\t1\n/NumPoints\t', nrow(dat), '\n/Matrix\n', file=grpfile)
	write.table(rep(1,nrow(dat)), append=TRUE, file=grpfile, row.names=FALSE, col.names=FALSE)

	# F-test
	cmd = paste("flameo --cope=", mergednifti, " --dm=design.mat --tc=design.con --cs=design.grp --runmode=ols", sep="")
	# add mask if available
	if(!is.null(maskfile)){
		cmd = paste(cmd, " --mask=", maskfile, sep="")
	}
	# do f-tests if reduced design was passed
	if(!is.null(Xred)){
		cmd = paste(cmd, "--fc=design.fts")
	}
	# add voxel-wise covariate if passed
	if(!is.null(voxelev)){
		cmd = paste(cmd,  " --ven=", p, " --vef=", covnifti, sep="")
	}

		if(run){
			here = getwd()
			setwd(outdir)
			system(cmd)
			# cleanup
			system('mv logdir/* ./; rm -rf logdir' )
			setwd(here)
		}
		return(cmd)
}


### RANDOMISE WRAPPER ###
randomise = function(filelist=NULL, dat=NULL, maskfile=NULL, X=NULL, Xred=NULL, outdir=NULL, nperm=500, thresh=0.01, run=TRUE){
	outdirdir = dirname(outdir)
	mergednifti=file.path(outdirdir, 'merged.nii.gz')
	if(length(filelist)==1){
		mergednifti=filelist
	}
	# merge images
	if(!file.exists(mergednifti)){
		mergeimages(filelist, mergednifti)
	}
	## DESIGN AND CONTRASTS ##
	# design file
	if( is.character(X)){
		X = getdesign(X, dat)
	}
	n = nrow(X)
	p = ncol(X)
	# load reduced model if
	if(is.character(Xred)){
		Xred = getdesign(Xred, dat)
	}
	if(!is.null(Xred)){
		p2 = p - ncol(Xred)
	}
	# If there is only 1 column then do a one-sample t-test
	if(p>1){
		p2 = p - ncol(Xred)
		matfile = paste(outdir, 'design.mat', sep='_')
		cat('/NumWaves\t', ncol(X), '\n/NumPoints\t', nrow(X), '\n/PPheights\t', paste(apply(X, 2, function(x) abs(diff(range(x))) ), collapse='\t'), '\n\n/Matrix\n', sep='', file=matfile)
		write.table(X, append=TRUE, file=matfile, row.names=FALSE, col.names=FALSE)

		# contrast file
		confile1 = paste(outdir, 'design.con', sep='_') # for f-test
		cons = matrix(0, nrow=p2, ncol=ncol(X))
		cons[ cbind(1:(p2), which(! colnames(X) %in% colnames(Xred) ) ) ] = 1
		cat('/ContrastName1\t temp\n/ContrastName2\t\n/NumWaves\t', ncol(X), '\n/NumPoints\t', nrow(cons), '\n/PPheights\t', paste(rep(1,ncol(cons)), collapse='\t'), '\n/RequiredEffect\t1\t1\n\n/Matrix\n', sep='', file=confile1)
		write.table(cons, append=TRUE, file=confile1, row.names=FALSE, col.names=FALSE)

		# fts file
		ftsfile = paste(outdir, 'design.fts', sep='_')
		fts = matrix(1, nrow=1, ncol=nrow(cons)) # ftest of all contrasts
		cat('/NumWaves\t', nrow(cons), '\n/NumContrasts\t', 1, '\n\n/Matrix\n', sep='', file=ftsfile)
		write.table(fts, append=TRUE, file=ftsfile, row.names=FALSE, col.names=FALSE)

		# t distribution is two tailed, F is one tailed. -x outputs voxelwise statistics -N outputs null distribution text files
		# F-test
		if(!is.null(maskfile)){
			fcmd = paste('randomise -i', mergednifti, '-m', maskfile, '-o', outdir, '-d', matfile, '-t', confile1, '-f', ftsfile, '--fonly -F', qf( (1-thresh),df1=p2, df2=(n-p) ), '-x -N -T -n', nperm, '--uncorrp' )
		} else {
			fcmd = paste('randomise -i', mergednifti, '-o', outdir, '-d', matfile, '-t', confile1, '-f', ftsfile, '--fonly -F', qf( (1-thresh),df1=p2, df2=(n-p) ), '-x -N -T -n', nperm, '--uncorrp' )
		}

	} else {
		if(!is.null(maskfile)){
			fcmd = paste('randomise -i', mergednifti, '-m', maskfile, '-o', outdir , '-1 -c', qt( (1-thresh),df=(n-1) ), '-x -N -T -n', nperm, '--uncorrp' )
		} else {
			fcmd = paste('randomise -i', mergednifti, '-o', outdir, '-1 -c', qt( (1-thresh),df=(n-1) ), '-x -N -T -n', nperm, '--uncorrp' )
		}
	}
		# CLEANUP
		#unlink(file.path(outdir, 'randomise_fstat1.nii.gz') )
		#unlink(file.path(outdir, 'randomise_tstat1.nii.gz') )
		# randomise saves everything-- just return the commands
		if(run){
			system(fcmd)
		}
		return(fcmd)
}

# This compiles the results of the randomise analyses after running on the grid
randomisecompile = function(tcorp, fcorp, sigfile, mask, alpha=0.05){
	sig = readNIfTI(sigfile)@.Data 
	sig = sig[ mask@.Data==1]
	tpmap = readNIfTI(tcorp)
	tpmap = tpmap[ mask@.Data==1]
	tpmap = 1-tpmap
	fpmap = readNIfTI(fcorp)
	fpmap = fpmap[ mask@.Data==1]
	fpmap = 1-fpmap
	# t.tests true and false positives
	trs.tp = mean(tpmap[which(sig>1)]<alpha)
	trs.fp = mean(tpmap[which(sig==0)]<alpha)
	# f.tests true and false positives
	frs.tp = mean(fpmap[which(sig>1)]<alpha)
	frs.fp = mean(fpmap[which(sig==0)]<alpha)
	c(tfp=trs.fp, ffp=frs.fp, ttp=trs.tp, ftp=frs.tp)
}

normalCI = function(vec, alpha){
	mean(vec) + c(-1, 1) * qnorm(1-alpha/2) * sd(vec)/sqrt(length(vec))
}

# updates an Rdata file
resave <- function(..., list = character(), file) {
  list <- union(list, as.character(substitute((...)))[-1L])
  e <- new.env()
  if(file.exists(file)){
    load(file, e)
  }
  # Copies objects from global environment
  # Assumes they all exist
  for(n in list) assign(n, get(n, .GlobalEnv), e)
  save(list = ls(e), envir = e, file = file)
}

addsignal = function(filelist=NULL, mergednifti=NULL, form=NULL, data=NULL){
	# merge images
	tempfiledir = tempdir()
	tempfilelist = file.path(tempfiledir, basename(filelist))

	# figure out which variable isn't real data
	vars = all.vars(as.formula(form))
	nullvar = vars[ which(!vars %in% names(dat))]
	# column names for null indices
	X = getdesign(form)
	nullinds = grep(nullvar, colnames(X))
	covar=X[,nullinds] 
	
	# assumes the coefficient for all null vectors is the same
	consts = rowSums(covar)
	cmds = paste('fslmaths', sigfile, '-mul', consts, '-add', filelist, tempfilelist, '-odt double')
	cat('adding signal to images\n')
	sapply(cmds, system)
	# merge images
	mergeimages(tempfilelist, mergednifti)
}

# merges a list of images using fslmerge
mergeimages = function(filelist=NULL, mergednifti=NULL){
		txt = tempfile( tmpdir="./")
		cat('merging images\n')
		cmd = paste('fslmerge -t', mergednifti, paste(filelist, collapse=' '))
		cat(cmd, file=txt)
		# for some reason I can't apply system to this command directly
		# I think due to limitations on the string length system can take
		# Instead, I cat to a txt file, and then use system to evaluate the
		# text file
		mergt = system.time(trash <- system(paste("$(cat", txt, ")") ) )[3]
		unlink(txt)
		cat('merge time:', (mergt)/60, 'minutes\n')
}

getdesign = function(form=NULL, data=NULL){
	# if it looks like a gam formula (and smells like a gam formula, then ...)
	if(grepl("s\\(", form)){
		# 1:n because you need to give gam an outcome to easily get the design matrix
		n = nrow(data)
		lmfull = paste("1:n", form)
		lmfull = model.matrix(gam(as.formula(lmfull), data=data) )

	# else it's a linear model
	} else {
		lmfull = model.matrix(as.formula(form), data=data)
	}
	return(lmfull)
}

