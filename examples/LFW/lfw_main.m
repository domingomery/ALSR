% Demo for face recognition in LFWa.
% 
% Protocol: The gallery has 143 subjects with at least 11 images per 
% subject (10 for training, the rest for testing). There are 1430 images 
% for training and 2744 for testing.
%
% See details in:
%
% Mery, D.; and Banerjee, S. Recognition of Faces and Facial Attributes 
% using Accumulative Local Sparse Representations. In International 
% Conference on Acoustics, Speech, and Signal Processing (ICASSP 2018), 
% 2018. Calgary, Canada, 15-20,Apr.
%
% Paper: http://dmery.sitios.ing.uc.cl/Prints/Conferences/International/2018-ICASSP.pdf
%
% (c) 2018 - Domingo Mery and Sandipan Banerjee
%
% This code needs the following toolboxes:
% - VLFeat          > http://www.vlfeat.org
% - SPAMS           > http://spams-devel.gforge.inria.fr
% - Balu            > http://dmery.ing.puc.cl/index.php/balu
% - ALSR            > http://dmery.sitios.ing.uc.cl/alsr_toolbox.zip
% - Experimental    > http://dmery.sitios.ing.uc.cl/exp_toolbox.zip
%
% After 10-12 hours (one face image per 15 sec), the performance should be:
%
% LFWa: Accuracy in 2744 images =   80.79% (143 subjects (10 images training) using HO)
%
clt

% Testing images
test_images      = 1:2744;   % images to be tested, for all images use 1:2744
rand_test        = 1;        % 1: all testing images are randonly selected
                             % 0: all testing images are sequentially
                             % selected, 0 and 1 achieve the same results

% Definition of images
f.path           = 'lfw_faces/';
f.extension      = 'png';
f.prefix         = 'face';
f.dig_class      = 4;
f.dig_img        = 4;

% Definition of feature extraction
opfx.k          = 143;
opfx.border     = 10;     % number of pixels that are not considered
opfx.height     = 110;    % height of the image
opfx.width      = 90;     % width of the image
opfx.mi         = 25;     % number of patches in i direction (grid)
opfx.mj         = 20;     % number of patches in j direction (grid)
opfx.m          = opfx.mi*opfx.mj; % total number of patches per image
opfx.w          = 32;     % height and width of the patch (w x w pixels)
opfx.patchsub   = 2;      % subsampling rate of the pixels of the patch
opfx.uninorm    = 1;      % 1: x=x/norm(x(:)) (for illumination invariant), 0: x=x
opfx.ntrain     = 10;     % number of training images per subject
opfx.single     = 1;      % single precision for feature vectors
opfx.circle     = 0;      % 0: square patches 1: circle patches
opfx            = alsr_LUTgrid(opfx);
opfx            = alsr_LUTcpatches(opfx);

% Definition of classification
opcl.L          = 40;      % not more than L non-zeros coefficients
opcl.eps        = 0;       % optional, threshold on the squared l2-norm of the residual, 0 by default
opcl.numThreads = -1;      % number of processors/cores to use; the default choice is -1 (it selects all the available CPUs/cores)
opcl.a          = 1;       % number of neighbours in the near patches
opcl.thsci      = 0.1;     % minimal sci allowed
opcl.therr      = 1;       % maximal error allowed
opcl.thsim      = 0.55;    % similarty threshold in dot product
opcl.thatm      = 0.1;
opcl.m          = opfx.m;  % number of patches per image
opcl.mi         = opfx.mi; % number of patches per column
opcl.mj         = opfx.mj; % number of patches per row
opcl.show       = 0;       % do not display results
opcl.ntrain     = opfx.ntrain;
opcl.k          = opfx.k;
opcl.tuning     = 'lfw_tuning';
opcl.softvote   = 0;       % 1 means soft vote of the patches
opcl.NV         = 0;       % number of words of the visual vocabulary



% Training
ix_train        = exp_imgix(1:opfx.k,1:opfx.ntrain);
[Xtrain,dtrain] = exp_fx('alsr_fxt',f,opfx,ix_train);
opts            = exp_train('alsr_cls',Xtrain,dtrain,opcl);

% Testing
ix               = load('lfw_data'); % testing images 
if rand_test == 1
   opts.ix_test  = ix.faces_rand(test_images,:);
else
   opts.ix_test  = ix.faces(test_images,:);
end

% Mask
load lfw_mask % mask of opfx.mi x opfx.mj elements (25x20)
opts.mask = alsr_facemask;

[Xtest,dtest]    = exp_fx('alsr_fxt',f,opfx,opts.ix_test);
ds               = exp_test('alsr_test',Xtest,opts);

% Evaluation
p = Bev_performance(ds,opts.ix_test(:,1));

fprintf('LFWa: Accuracy in %d images = %7.2f%% (143 subjects (10 images training) using HO)\n',length(test_images),p*100)

