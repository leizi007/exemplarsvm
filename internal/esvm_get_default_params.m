function params = esvm_get_default_params
% Return the default Exemplar-SVM detection/training parameters
% Copyright (C) 2011-12 by Tomasz Malisiewicz
% All rights reserved. 
%
% This file is part of the Exemplar-SVM library and is made
% available under the terms of the MIT license (see COPYING file).
% Project homepage: https://github.com/quantombone/exemplarsvm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sliding window detection parameters 
%(using during training and testing)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Turn on image flips for detection/training. If enabled, processing
%happes on each image as well as its left-right flipped version.
params.detect_add_flip = 1;

%Levels-per-octave defines how many levels between 2x sizes in pyramid
%(denser pyramids will have more windows and thus be slower for
%detection/training)
params.detect_levels_per_octave = 10;

%By default dont save feature vectors of detections (training turns
%this on automatically)
params.detect_save_features = 0;

%Default detection threshold (negative margin makes most sense for
%SVM-trained detectors).  Only keep detections for detection/training
%that fall above this threshold.
params.detect_keep_threshold = -1;

%Maximum #windows per template (per image) to keep.  In
%DalalTriggs, there is only one template which represents a
%category, and in ExemplarSVMs there are N templates
params.detect_max_windows_per_exemplar = 100;

%Determines if NMS (Non-maximum suppression) should be used to
%prune highly overlapping, redundant, detections.
%If less than 1.0, then we apply nms to detections so that we don't have
%too many redundant windows [defaults to 0.5]
params.detect_exemplar_nms_os_threshold = 0.5;

%How much we pad the pyramid (to let detections fall outside the image)
params.detect_pyramid_padding = 5;

%The maximum scale to consdider in the feature pyramid
params.detect_max_scale = 1.0;

%The minimum scale to consider in the feature pyramid
params.detect_min_scale = .01;

%Only keep detections that have sufficient overlap with the input's
%global bounding box.  If greater than 0, then we only keep detections
%that have this OS or greater with the entire input image.
params.detect_min_scene_os = 0.0;

% Choose the number of images to process in each chunk for detection.
% This parameters tells us how many images each core will process at
% at time before saving results.  A higher number of images per chunk
% means there will be less constant access to hard disk by separate
% processes than if images per chunk was 1.  This is a caching
% parameter and plays no effect on the learning if everything is
% processed on a single machine.
params.detect_images_per_chunk = 4;

% Determines when we switch from doing per-exemplar convolutions to
% doing the block method (which pre-computes the large matrix of
% descriptors for every single window in the image).
% NOTE: If the number of specified models is greater than 20, use the
% BLOCK-based method
params.max_models_before_block_method = 20;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Training/Mining parameters %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%For training, use .5 the resolution of images
params.train_max_scale = 0.5;

%For training, do not do NMS
params.train_exemplar_nms_os_threshold = 1.0;

%The maximum number of negatives to keep in the cache while training.
params.train_max_negatives_in_cache = 2000;

%Maximum global number of mining iterations, where an iteration is
%when queue fills with max_windows_before_svm detections or
%max_windows_before_svm images have been processed
params.train_max_mine_iterations = 100;

%Maximum TOTAL number of images to mine from the mining queue
params.train_max_mined_images = 2500;

%Maximum number of negatives to mine before SVM kicks in (this
%defines one iteration of learning)
params.train_max_windows_per_iteration = 1000;

%Maximum number of images with a detection before one iteration of
%learning completes
params.train_max_images_per_iteration = 400;

%NOTE: I don't think these fields are being used since I set the
%global detection threshold to -1.
%when mining, we keep the N negative support vectors as well as
%some more beyond the -1 threshold (alpha*N), but no more than
%1000, where alpha is the "keep nsv multiplier"
params.train_keep_nsv_multiplier = 3;

%ICCV11 constant for SVM learning is .01
params.train_svm_c = .01; %% regularize more with .0001;

%The constant which tells us the weight in front of the positives
%during SVM learning
params.train_positives_constant = 50;

%NOTE: I'm not sure in which sections should this be defined.  By
%default, NN mode is turned off and we assume per-exemplar SVMs
params.nnmode = '';

%By default, we use an SVM, dfun flag means we perform learning in
%distance to mean space and thus learn a distance function
%NOTE: this feature is commented out in lots of places, so it
%probably doesn't work as intended
params.dfun = 0;

%The svm update equation
params.training_function = @esvm_update_svm;

%Mining Queue mode can be one of:
% {'onepass','cycle-violators','front-violators'}
%
% onepass: a single pass through the mining queue
% cycle-violators: discard non-firing images, and place violators
%     (images with detections) at the end of the mining queue
% front-violators: same as above but place violators at front of
% queue
% The last two modes require a termination condition such as
% (train_max_mined_images) so that learning doesn't loop
% indefinitely
params.queue_mode = 'onepass';

% % NOTE: this stuff is experimental and currently disabled (see
% % do_svm.m). The goal was to perform dimensionality reduction
% % before the learning process.
% % If non-zero, perform learning in dominant-gradient space
% params.DOMINANT_GRADIENT_PROJECTION = 0;
% % The dimensionality of the local max-gradient descriptor
% params.DOMINANT_GRADIENT_PROJECTION_K = 2;
% % If enabled, do PCA on training data right before SVM (this
% % automatically converts the result to a descriptor in the RAW feature
% % space)
% params.DO_PCA = 0;
% % The degree of the PCA.
% params.PCA_K = 300;
% % If enabled, only do PCA from the positives (so the subspace is what
% % spans the positive examples)
% params.A_FROM_POSITIVES = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cross-Validation(Calibration) parameters %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%By default perform calibration with matrix method
params.calibration_platt = 0;

%The default calibration threshold (will prune away all windows
%that score below this number)
params.calibration_threshold = -1;

%By default perform calibration with matrix method
params.calibration_matrix = 1;

%The M-matrix estimation parameters
params.calibration_matrix_count_thresh = .5;
params.calibration_matrix_neighbor_thresh = .5;

%If enabled, use M-matrix calibration, but then propagate results
%onto best local "raw" exemplar-based detection
params.calibration_matrix_propagate_onto_raw = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Intialization parameters %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Set feature-computation function function
init_params.features = @esvm_hog;
init_params.sbin = 8;
init_params.goal_ncells = 100;
init_params.MAXDIM = 12;
init_params.init_function = @esvm_initialize_goalsize_exemplar;

params.init_params = init_params;
params.model_type = 'exemplar';

%Initialize loading/saving directories to being empty (turned off)
params.localdir = '';

% For dalal triggs, we need an update threshold (we only keep
% detections which have above this overlap with a ground-truth region)
params.latent_os_thresh = 0.7;
params.latent_iterations = 2;
params.dt_initialize_with_flips = 0;

%experimental flag which lets us perturb assignments during the
%latent update step
params.latent_perturb_assignment_iterations = 0;

%Information about where we mine images from
params.mine_from_negatives = 1;
params.mine_from_positives = 0;

% If enabled, skips objects durning mining when mining from positives
params.mine_skip_positive_objects = 1;

% Skips any object which overlaps with GT by more than this amount
params.mine_skip_positive_objects_os = .2;

%The threshold for evaluation
params.evaluation_minoverlap = .5;

%If display flag is enabled, then we will show lots of things
params.display = 0;

%If enabled, we display detections during applyModel
params.display_detections = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saving and Output parameters %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%If enabled, we dump learning into results directory
params.dump_images = 0;

%if enabled, we dump the last image of learning only
params.dump_last_image = 1;