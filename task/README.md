1. Generating design matrices
	1) VioDiffCon_VarConfig.m: Configuring variables
	2) gen_repSeq.m: Generating the repetition sequence for the exposure phase.
	3) VioDiffCon_expand_mat.m: Generating the design matrices based on "out_mat/repSeqMat_subjNum_runNum.mat", which are created in gen_repSeq.m.

2. Running the study
	1) VioDiffCon_learning.m: Running the session 1 exposure phase (e.g., AB-AB-AB-AX-B-AX-B) based on "out_mat/learning_mat_subjNum.mat", which is created in VioDiffCon_expand_mat.m. The run_session_one.m script loops through six runs of the learning phase task.
	2) run_session_two.m runs all session 2 tasks, including: VioDiffCon_postScenes.m, VioDiffCon_familiarization.m, VioDiffCon_reward.m, VioDiffCon_decision.m, VioDiffCon_postFaces.m. 

3. Localizer task
	1) localizer_FSO_VarConfig.m: Configuring variables
	2) localizer_FSO_mat.m: Generating the design matrices for the localizer
	3) localizer_FSO.m: Running the localizer

4. Folder information
	1) +common folder: Contains commonly used codes (e.g., screen configuration, getting response etc.)
	2) out_mat: Contains design matrices (some example design matrices included here)
	3) output: Before running these scripts, you will need to create some output sub-directories. For example, you may want an output directory to save data files generated when testing the scripts (e.g., 'output_debug') and another output directory to save data files when running the actual experiment (e.g., 'output_skyra'). Whatever you name your output directories, you can update this in VioDiffCon_VarConfig.m and localizer_FSO_VarConfig.m.
	4) stim: Contains stimuli for the main experiment
	5) stim_loc: Contains stimuli for the localizer

Note: For the stimuli, we have only included the directory structure here. You can either add your own images following the category structure or contact emcdevitt[at]princeton.edu to request access to the stimuli used in this experiment.
