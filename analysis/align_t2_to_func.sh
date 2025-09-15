#! /bin/bash

module load fsl/6.0.4

source globals.sh #data_dir, bids_dir, deriv_dir, scripts_dir

set -e #stop immediately when error occurs

#inputs:
subj=$1
SUBJ_DIR=sub-$subj

echo "Now aligning t2 to func for $SUBJ_DIR"

#directories:
FIRSTLEVEL_DIR=$deriv_dir/firstlevel
outDir=$FIRSTLEVEL_DIR/$SUBJ_DIR/flirt_t2_to_func_v4

# make new directory for t1_to_t2 registration
if [ ! -d "$outDir" ]
then
  mkdir $outDir
fi

# files:
T1=$deriv_dir/fmriprep/$SUBJ_DIR/anat/${SUBJ_DIR}_desc-preproc_T1w.nii.gz
T1_brainmask=$deriv_dir/fmriprep/$SUBJ_DIR/anat/${SUBJ_DIR}_desc-brain_mask.nii.gz
T2=$bids_dir/$SUBJ_DIR/ses-01/anat/${SUBJ_DIR}_ses-01_T2w.nii.gz
bold_ref=$deriv_dir/fmriprep/$SUBJ_DIR/ses-01/func/${SUBJ_DIR}_ses-01_task-study_run-01_space-T1w_boldref.nii.gz

# Register T2 to T1 image

# brain extraction using fmriprep brain mask
T1_brain=$outDir/${SUBJ_DIR}_T1wbrain.nii.gz

fslmaths $T1 \
-mul $T1_brainmask \
$T1_brain

# T2 to T1 registration: compute transformation matrix using mutual information
flirt -in $T2 \
-ref $T1_brain \
-dof 6 -cost mutualinfo \
-omat $outDir/t2_to_t1.mat \
-out $outDir/${SUBJ_DIR}_T2w_to_T1w.nii.gz

# compute inverse transformation (T1 to T2)
convert_xfm -omat $outDir/t1_to_t2.mat -inverse $outDir/t2_to_t1.mat  

# Compute func to T1w transformation 
# they are already aligned, this will create the transformation matrix and the sampling - because they are not in the same resolution or FOV)
# NOTE: using brain-extracted T1w or not shouldn't make a difference
flirt -in $bold_ref \
-ref $T1 \
-dof 6 \
-applyxfm -usesqform \
-omat $outDir/func_to_t1.mat \
-out $outDir/${SUBJ_DIR}_func_to_T1w.nii.gz

# compute inverse transformation (T1 to func)
convert_xfm -omat $outDir/t1_to_func.mat -inverse $outDir/func_to_t1.mat
echo "checking func_to_t1 transformation"
cat $outDir/func_to_t1.mat

# Concatenate two transformations to go from T2 -> T1 -> func
# note that the transform after the -concat is treated as the second transformation in the concatenation
convert_xfm -concat $outDir/t1_to_func.mat -omat $outDir/t2_to_func.mat $outDir/t2_to_t1.mat

# Apply transformation to original T2 image
flirt -in $T2 \
-ref $bold_ref \
-out $outDir/${SUBJ_DIR}_T2w_to_func.nii.gz \
-applyxfm -init $outDir/t2_to_func.mat \
-interp trilinear

# # Apply transformation to a mask (for testing purposes)
# sampleMask=$FIRSTLEVEL_DIR/$SUBJ_DIR/rois_ashs/t2space/${SUBJ_DIR}_left_CA1.nii.gz
# flirt -in $sampleMask \
# -ref $bold_ref \
# -out $outDir/${SUBJ_DIR}_t2_to_func_left_CA1_example.nii.gz \
# -applyxfm -init $outDir/t2_to_func.mat \
# -interp trilinear
# # binarize example mask
# fslmaths $outDir/${SUBJ_DIR}_t2_to_func_left_CA1_example.nii.gz -thr 0.5 -bin $outDir/${SUBJ_DIR}_t2_to_func_left_CA1_example.nii.gz

# To visually check registrations
echo "check alignment"
fsleyes $T1 $bold_ref $outDir/${SUBJ_DIR}_T2w_to_T1w.nii.gz $outDir/${SUBJ_DIR}_func_to_T1w.nii.gz $outDir/${SUBJ_DIR}_T2w_to_func.nii.gz
# $outDir/${SUBJ_DIR}_t2_to_func_left_CA1_example.nii.gz (you can also add this to the line above if this file exists)

echo "$SUBJ_DIR complete"




