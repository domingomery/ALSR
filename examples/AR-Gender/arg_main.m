% Demo for gender recognition in AR.
% 
% Protocol: 100 subjects (50 women and 50 men). For gender recognition, 14 
% non-occluded images per subject. In this experiment, the first 25 males 
% and 25 females were used for training and the last 25 males and 25 
% females were used for testing. 
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
% After 3-4 hours (one face image per 10 sec), the performance should be:
%
% ARg: Accuracy =   98.86% (HO: 25x2 subjects for training, 25x2 subjects for testing )
%
% Note: the accuracy can be a little bit different because the visual 
% vocabulary uses k-means with random seeds, ie, the visual vocabulary can 
% be different in each run-
%

clt
% Parameters:
%     mi   mj  w   sub   L  a  sci  err  sim  atm circ Nv 
x = [ 30   20  16   1   10  2  0.4  1    0.7  0.1  1  250]; % 98.86

% Definition of images
f.path           = 'arg_faces/';
f.extension      = 'png';
f.prefix         = 'face';
f.dig_class      = 3;
f.dig_img        = 4;

% Definition of feature extraction
opfx.k          = 2;
opfx.border     = 10;       % number of pixels that are not considered
opfx.height     = 110;      % height of the image
opfx.width      = 90;       % width of the image
opfx.mi         = x(1);     % number of patches in i direction (grid)
opfx.mj         = x(2);     % number of patches in j direction (grid)
opfx.m          = opfx.mi*opfx.mj;
opfx.w          = x(3);     % height and width of the patch (w x w pixels)
opfx.patchsub   = x(4);     % subsampling rate of the pixels of the patch
opfx.uninorm    = 1;        % 1: x=x/norm(x(:)) (for illumination invariant), 0: x=x
opfx.ntrain     = 700;      % number of training images per class
opfx.single     = 1;        % single precision for feature vectors
opfx.circle     = x(11);
opfx            = alsr_LUTgrid(opfx);
opfx            = alsr_LUTcpatches(opfx);


% Definition of classification
opcl.L          = x(5);     % not more than L non-zeros coefficients
opcl.eps        = 0;        % optional, threshold on the squared l2-norm of the residual, 0 by default
opcl.numThreads = -1;       % number of processors/cores to use; the default choice is -1 (it selects all the available CPUs/cores)
opcl.a          = x(6);     % number of neighbours in the near patches
opcl.thsci      = x(7);     % minimal sci allowed
opcl.therr      = x(8);     % maximal error allowed
opcl.thsim      = x(9);     % similarty threshold in dot product
opcl.thatm      = x(10);
opcl.m          = opfx.m;   % number of patches per image
opcl.mi         = opfx.mi;  % number of patches per column
opcl.mj         = opfx.mj;  % number of patches per row
opcl.show       = 0;        % do not display results
opcl.ntrain     = opfx.ntrain;
opcl.k          = opfx.k;
opcl.top_bound  = 0.05;
opcl.bottom_bound = 0.1;
opcl.NV         = x(12);
opcl.tfidf      = 1;
opcl.stopth     = 0.9;
opcl.tuning       = 'arg_tuning';


% Training
jj              = 1:opfx.ntrain;
ix_train        = exp_imgix(1:opfx.k,jj);
[Xtrain,dtrain] = exp_fx('alsr_fxt',f,opfx,ix_train);
opts            = exp_train('alsr_cls',Xtrain,dtrain,opcl);


% Mask
load arg_mask % mask of opfx.mi x opfx.mj elements (30x20)
opts.mask = alsr_facemask;

% Testing
jj             = 701:1050;
ix_test        = exp_imgix(1:opfx.k,jj);
opts.ix_test   = ix_test;
[Xtest,dtest]  = exp_fx('alsr_fxt',f,opfx,opts.ix_test);
ds             = exp_test('alsr_test',Xtest,opts);

% Evaluation
p = Bev_performance(ds,opts.ix_test(:,1));
fprintf('ARg: Accuracy = %7.2f%% (HO: 25x2 subjects for training, 25x2 subjects for testing )\n',p*100)
