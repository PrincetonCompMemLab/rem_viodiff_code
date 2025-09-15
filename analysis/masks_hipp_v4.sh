#! /bin/bash 

module load fsl/6.0.4

source globals.sh #data_dir, bids_dir, deriv_dir, scripts_dir

set -e #stop immediately when error occurs

#inputs:
subj=$1
SUBJ_DIR=sub-$subj

#directories:
FIRSTLEVEL_DIR=$deriv_dir/firstlevel
ASHS_DIR=$deriv_dir/ashs
REG_DIR=$FIRSTLEVEL_DIR/$SUBJ_DIR/flirt_t2_to_func_v4
outDir_t2=$FIRSTLEVEL_DIR/$SUBJ_DIR/rois_ashs/t2space_v4
outDir_t1=$FIRSTLEVEL_DIR/$SUBJ_DIR/rois_ashs/t1space_v4

# make directories if they don't exist
if [ ! -d "$outDir_t1" ]
then
  mkdir $outDir_t1
  mkdir $outDir_t1/temp
  mkdir $outDir_t1/threshold-50
  mkdir $outDir_t1/threshold-75
  mkdir $outDir_t1/threshold-90
fi

if [ ! -d "$outDir_t2" ]
then
  mkdir $outDir_t2
fi

if [ ! -d "$outDir_t1/threshold-40" ]
then
  mkdir $outDir_t1/threshold-40
fi

#files:
T1=$DERIV_DIR/fmriprep/$SUBJ_DIR/anat/${SUBJ_DIR}_desc-preproc_T1w.nii.gz
bold_ref=$deriv_dir/fmriprep/$SUBJ_DIR/ses-01/func/${SUBJ_DIR}_ses-01_task-study_run-01_space-T1w_boldref.nii.gz

echo "Now making masks for $SUBJ_DIR..."
# Extract labels for hippocampal subfields and cortical MTL

# Labels from ASHS:
# 1: CA1
# 2: CA2+3
# 3: DG
# 4: ERC
# 5: PHC
# 6: PRC
# 7: SUB

# array of ROIs, and array of code labels of equal length
ROIS=("CA1" "CA2+3" "DG" "ERC" "PHC" "PRC" "SUB")
NUMS=(1 2 3 4 5 6 7)
HEMIS="left right"

# in each hemisphere (left and right) separately:
# 1. pull out labels associated with each ROI and make a mask in t2 space
# 2. while still in t2 space, combine some ROIs (CA23+DG, hippocampus, cortical MTL)

for hemi in $HEMIS
do
	fileList=""
  	echo "subsetting ashs segmentation"
  	for ((i=0;i<${#ROIS[@]};++i))
  	do
    	outfile=$outDir_t2/${SUBJ_DIR}_${hemi}_${ROIS[i]}.nii.gz
  
      # threshold this hemispheres segmentation based on label
    	fslmaths $ASHS_DIR/$SUBJ_DIR/final/*_${hemi}_lfseg_corr_usegray.nii.gz  -uthr ${NUMS[i]} -thr ${NUMS[i]} $outfile
    	fslmaths $outfile -bin $outfile #binarize -- convert roi label to 1
  	done

    echo "combining CA2+3 and DG"
    CA23DG=$outDir_t2/${SUBJ_DIR}_${hemi}_CA2+3+DG.nii.gz
    fslmaths $outDir_t2/${SUBJ_DIR}_${hemi}_CA2+3.nii.gz -add $outDir_t2/${SUBJ_DIR}_${hemi}_DG.nii.gz $CA23DG
    fslmaths $CA23DG -bin $CA23DG

    echo "making hippocampal mask" #adding CA2+3+DG, CA1 and SUB
    HIPP=$outDir_t2/${SUBJ_DIR}_${hemi}_hipp.nii.gz
    fslmaths $outDir_t2/${SUBJ_DIR}_${hemi}_CA2+3+DG.nii.gz -add $outDir_t2/${SUBJ_DIR}_${hemi}_CA1.nii.gz -add $outDir_t2/${SUBJ_DIR}_${hemi}_SUB.nii.gz $HIPP
    fslmaths $HIPP -bin $HIPP

    echo "making cortical MTL mask" #adding ERC + PHC + PRC
    CORTICAL=$outDir_t2/${SUBJ_DIR}_${hemi}_corticalMTL.nii.gz
    fslmaths $outDir_t2/${SUBJ_DIR}_${hemi}_ERC.nii.gz -add $outDir_t2/${SUBJ_DIR}_${hemi}_PHC.nii.gz -add $outDir_t2/${SUBJ_DIR}_${hemi}_PRC.nii.gz $CORTICAL
    fslmaths $CORTICAL -bin $CORTICAL
done

# For each ROI in each hemisphere:
# 1. apply t2_to_func transformation matrix (made using align_t2_to_func.sh script)
# 2. binarize to make t1 space, 1.5mm resolution masks
# 3. place resulting mask in temp folder because they haven't been checked for overlap yet

ROIS=("CA1 CA2+3 DG ERC PHC PRC SUB CA2+3+DG hipp corticalMTL")
HEMIS="left right"

echo "downsampling"

for roi in $ROIS
do
  for hemi in $HEMIS
  do
    # Align to t1space and downsample to epi resolution 
    infile=$outDir_t2/${SUBJ_DIR}_${hemi}_${roi}.nii.gz
    outfile=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_${roi}_1.5mm.nii.gz #place in temp folder (before removing overlap)
    outfile_10=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_${roi}_1.5mm_thresh-10.nii.gz
    outfile_40=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_${roi}_1.5mm_thresh-40.nii.gz
    outfile_50=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_${roi}_1.5mm_thresh-50.nii.gz
    outfile_75=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_${roi}_1.5mm_thresh-75.nii.gz
    outfile_90=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_${roi}_1.5mm_thresh-90.nii.gz

    flirt -in $infile \
    -ref $bold_ref \
    -out $outfile \
    -applyxfm -init $REG_DIR/t2_to_func.mat \
    -interp trilinear
    
    #fslmaths $outfile -thr 0.1 -bin $outfile_10 #binarize
    # fslmaths $outfile -thr 0.4 -bin $outfile_40 #binarize
    fslmaths $outfile -thr 0.5 -bin $outfile_50 #binarize
    # fslmaths $outfile -thr 0.75 -bin $outfile_75
    # fslmaths $outfile -thr 0.9 -bin $outfile_90
  done
done

# In each hemisphere separately, and for each threshold, check for overlap between ROIs:

HEMIS="left right"
#THRESHOLDS="50 75 90"
THRESHOLDS="50"

echo "checking for overlap between ROIs"

for hemi in $HEMIS
do
  for thresh in $THRESHOLDS
  do

  # define files
  CA1=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_CA1_1.5mm_thresh-${thresh}.nii.gz
  CA23=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_CA2+3_1.5mm_thresh-${thresh}.nii.gz
  DG=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_DG_1.5mm_thresh-${thresh}.nii.gz
  CA23DG=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_CA2+3+DG_1.5mm_thresh-${thresh}.nii.gz
  ERC=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_ERC_1.5mm_thresh-${thresh}.nii.gz
  PHC=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_PHC_1.5mm_thresh-${thresh}.nii.gz
  PRC=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_PRC_1.5mm_thresh-${thresh}.nii.gz
  SUB=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_SUB_1.5mm_thresh-${thresh}.nii.gz 
  HIPP=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_hipp_1.5mm_thresh-${thresh}.nii.gz
  corticalMTL=$outDir_t1/temp/${SUBJ_DIR}_${hemi}_corticalMTL_1.5mm_thresh-${thresh}.nii.gz

  #check for overlap between all ROIs
  #note, this does not care about overlap between CA23 and DG since those subfields were already combined
  fslmaths \
    $CA1 \
    -add $CA23DG \
    -add $ERC \
    -add $PHC \
    -add $PRC \
    -add $SUB \
    $outDir_t1/temp/${SUBJ_DIR}_${hemi}_all-rois_1.5mm_thresh-${thresh}.nii.gz
  
  fslmaths $outDir_t1/temp/${SUBJ_DIR}_${hemi}_all-rois_1.5mm_thresh-${thresh}.nii.gz -thr 2 -bin $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap_1.5mm_thresh-${thresh}.nii.gz

  # print number of overlapping voxels and their volume in cubic millimeters
  echo "$SUBJ_DIR $hemi threshold $thresh number of overlapping voxels and volume in cubic mm for all ROIs"
  fslstats $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap_1.5mm_thresh-${thresh}.nii.gz -V

  #subtract overlapping voxels from each ROI and put resulting mask in main t1 folder
  fslmaths \
    $CA1 \
    -sub $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap_1.5mm_thresh-${thresh}.nii.gz \
    -thr 0 -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_CA1_1.5mm.nii.gz

  fslmaths \
    $CA23DG \
    -sub $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap_1.5mm_thresh-${thresh}.nii.gz \
    -thr 0 -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_CA2+3+DG_1.5mm.nii.gz

  fslmaths \
    $ERC \
    -sub $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap_1.5mm_thresh-${thresh}.nii.gz \
    -thr 0 -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_ERC_1.5mm.nii.gz

  fslmaths \
    $PHC \
    -sub $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap_1.5mm_thresh-${thresh}.nii.gz \
    -thr 0 -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_PHC_1.5mm.nii.gz

  fslmaths \
    $PRC \
    -sub $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap_1.5mm_thresh-${thresh}.nii.gz \
    -thr 0 -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_PRC_1.5mm.nii.gz

  fslmaths \
    $SUB \
    -sub $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap_1.5mm_thresh-${thresh}.nii.gz \
    -thr 0 -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_SUB_1.5mm.nii.gz

  #check for overlap between hipp and corticalMTL
  fslmaths \
    $HIPP \
    -add $corticalMTL \
    $outDir_t1/temp/${SUBJ_DIR}_${hemi}_hipp+corticalMTL_1.5mm_thresh-${thresh}.nii.gz
    
  fslmaths $outDir_t1/temp/${SUBJ_DIR}_${hemi}_hipp+corticalMTL_1.5mm_thresh-${thresh}.nii.gz -thr 2 -bin $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap-hipp+corticalMTL_1.5mm_thresh-${thresh}.nii.gz

  # print number of overlapping voxels and their volume in cubic millimeters
  echo "$SUBJ_DIR $hemi threshold $thresh number of overlapping voxels and volume in cubic mm for hipp and corticalMTL"
  fslstats $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap-hipp+corticalMTL_1.5mm_thresh-${thresh}.nii.gz -V

  #subtract overlapping voxels from hipp and corticalMTL masks
  fslmaths \
    $HIPP \
    -sub $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap-hipp+corticalMTL_1.5mm_thresh-${thresh}.nii.gz \
    -thr 0 -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_hipp_1.5mm.nii.gz

  fslmaths \
    $corticalMTL \
    -sub $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap-hipp+corticalMTL_1.5mm_thresh-${thresh}.nii.gz \
    -thr 0 -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_corticalMTL_1.5mm.nii.gz

  #check for overlap between CA2+3 and DG 
  fslmaths \
    $CA23 \
    -add $DG \
    $outDir_t1/temp/${SUBJ_DIR}_${hemi}_CA23+DG_1.5mm_thresh-${thresh}.nii.gz
    
  fslmaths $outDir_t1/temp/${SUBJ_DIR}_${hemi}_CA23+DG_1.5mm_thresh-${thresh}.nii.gz -thr 2 -bin $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap-CA23-DG_1.5mm_thresh-${thresh}.nii.gz

  # print number of overlapping voxels and their volume in cubic millimeters
  echo "$SUBJ_DIR $hemi threshold $thresh number of overlapping voxels and volume in cubic mm for CA2+3 and DG"
  fslstats $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap-CA23-DG_1.5mm_thresh-${thresh}.nii.gz -V

  #subtract overlapping voxels from CA2+3 and DG masks
  fslmaths \
    $CA23 \
    -sub $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap-CA23-DG_1.5mm_thresh-${thresh}.nii.gz \
    -thr 0 -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_CA2+3_1.5mm.nii.gz

  fslmaths \
    $DG \
    -sub $outDir_t1/temp/${SUBJ_DIR}_${hemi}_overlap-CA23-DG_1.5mm_thresh-${thresh}.nii.gz \
    -thr 0 -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_DG_1.5mm.nii.gz

  #add CA2/3 and DG together; now we can compare adding CA2/3 and DG in t2space versus adding together in t1space
  fslmaths \
    $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_CA2+3_1.5mm.nii.gz \
    -add $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_DG_1.5mm.nii.gz \
    -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_${hemi}_CA2+3+DG_1.5mm_combined-after-resampling.nii.gz
  done
done

# Last step - for each ROI, combine left and right hemisphere to make a bilateral mask
# Do this for t2 space masks and t1 space masks

echo "combining hemispheres"

ROIS=("CA1 CA2+3 DG ERC PHC PRC SUB CA2+3+DG hipp corticalMTL")
#THRESHOLDS="50 75 90"
THRESHOLDS="40"

for roi in $ROIS
do
  # t2space: add left hemisphere to right hemisphere
  fslmaths $outDir_t2/${SUBJ_DIR}_left_${roi}.nii.gz -add $outDir_t2/${SUBJ_DIR}_right_${roi}.nii.gz $outDir_t2/${SUBJ_DIR}_bilateral_${roi}.nii.gz
  fslmaths $outDir_t2/${SUBJ_DIR}_bilateral_${roi}.nii.gz -bin $outDir_t2/${SUBJ_DIR}_bilateral_${roi}.nii.gz
  
  for thresh in $THRESHOLDS
  do
    #t1space: add left hemisphere to right hemisphere
    fslmaths $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_left_${roi}_1.5mm.nii.gz -add $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_right_${roi}_1.5mm.nii.gz $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_bilateral_${roi}_1.5mm.nii.gz
    fslmaths $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_bilateral_${roi}_1.5mm.nii.gz -bin $outDir_t1/threshold-${thresh}/${SUBJ_DIR}_bilateral_${roi}_1.5mm.nii.gz
  done
done