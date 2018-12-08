% Demo for face expression recognition in Oulu-CASIA
% 
% Protocol: Six different facial expressions (surprise, happiness, sadness, 
% anger, fear and dis- gust) under normal illumination from 80 subjects (59 
% males and 21 females) ranging from 23 to 58 years in age. The dataset 
% contains 480 sequences: the first 9 images of each sequence are not 
% considered, the first 40 individuals are taken as training subset and the 
% rest as testing. 
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
% - INface_tool     > https://la.mathworks.com/matlabcentral/fileexchange/26523-the-inface-toolbox-v2-0-for-illumination-invariant-face-recognition
%
% After 3 hours (one face image per 3-4 sec), the performance should be:
%
%  Oulu+: Accuracy =   68.16% (6 emotions using HO) 
%


clt
subtest = 1;
subtrain = 6;
x = [...
    %   mi   mj  w   sub   L  a  sci  err  sim  atm circ Nv  Mirror   Tantriggs
        24   20  20   3    3  3  0.1  1.0  0.9  0.2 1    0   0        1 % 66.20 con subtrain = 6
    ];

pmax = 0;
kmax = 0;


ntest =   [ 1070        1081        1113        1143        1123        1096];
ix_test = [];
for j=1:6
    nj = (594:ntest(j))';
    n = length(nj);
    ix_test = [ix_test;j*ones(n,1) nj]; %#ok<AGROW>
end

ix_test = ix_test(1:subtest:end,:);

nx = size(x,1);

p = zeros(nx,1);
kk = 0;
k=1;
kk = kk+1;
ii = 1:subtrain:593;
nii = length(ii);

ix_train = exp_imgix(1:6,ii);

% Definition of images
f.path           = 'oul_faces/';
f.extension      = 'png';
f.prefix         = 'face';
f.dig_class      = 3;
f.dig_img        = 5;

% Definition of feature extraction
opfx.k          = 6;
opfx.border     = 1;        % number of pixels that are not considered
opfx.height     = 110;      % height of the image
opfx.width      = 90;       % width of the image
opfx.mi         = x(k,1);   % number of patches in i direction (grid)
opfx.mj         = x(k,2);   % number of patches in j direction (grid)
opfx.m          = opfx.mi*opfx.mj;
opfx.w          = x(k,3);   % height and width of the patch (w x w pixels)
opfx.patchsub   = x(k,4);   % subsampling rate of the pixels of the patch
opfx.uninorm    = 1;        % 1: x=x/norm(x(k,:)) (for illumination invariant), 0: x=x
opfx.ntrain     = nii;      % number of training images per class
opfx.single     = 1;        % single precision for feature vectors
opfx.circle     = x(k,11);
opfx            = alsr_LUTgrid(opfx);
opfx            = alsr_LUTcpatches(opfx);
mirror          = x(k,13);
opfx.tantriggs  = x(k,14);


% Definition of classification
opcl.L          = x(k,5);   % not more than L non-zeros coefficients
opcl.eps        = 0;        % optional, threshold on the squared l2-norm of the residual, 0 by default
opcl.numThreads = -1;       % number of processors/cores to use; the default choice is -1 (it selects all the available CPUs/cores)
opcl.a          = x(k,6);   % number of neighbours in the near patches
opcl.thsci      = x(k,7);   % minimal sci allowed
opcl.therr      = x(k,8);   % maximal error allowed
opcl.thsim      = x(k,9);   % similarty threshold in dot product
opcl.thatm      = x(k,10);
opcl.m          = opfx.m;   % number of patches per image
opcl.mi         = opfx.mi;  % number of patches per column
opcl.mj         = opfx.mj;  % number of patches per row
opcl.show       = 0;        % do not display results
opcl.ntrain     = opfx.ntrain;
opcl.k          = opfx.k;
opcl.top_bound  = 0.05; % 0.05;
opcl.bottom_bound = 0.1; % 0.1;
opcl.NV         = x(k,12);
opcl.tfidf      = 1;
opcl.stopth     = 0.9;
opcl.subvoc     = 2;
opcl.tuning     = 'oul_tuning';


% Training
if mirror == 1
    opfx.mirror       = 0;
    [Xtrain1,dtrain1] = exp_fx('alsr_fxt',f,opfx,ix_train);
    opfx.mirror       = 1;
    [Xtrain2,dtrain2] = exp_fx('alsr_fxt',f,opfx,ix_train);
    Xtrain            = [Xtrain1;Xtrain2];
    dtrain            = [dtrain1;dtrain2];
else
    opfx.mirror       = 0;
    [Xtrain,dtrain] = exp_fx('alsr_fxt',f,opfx,ix_train);
end
opts              = exp_train('alsr_cls',Xtrain,dtrain,opcl);


% Mask
load oul_mask % mask of opfx.mi x opfx.mj elements (24x20)
opts.mask = alsr_facemask;

% Testing
opts.ix_test   = ix_test;
[Xtest,dtest]  = exp_fx('alsr_fxt',f,opfx,opts.ix_test);
ds             = exp_test('alsr_test',Xtest,opts);


% Evaluation
pm             = Bev_performance(ds,ix_test(:,1));
% p(kk) = pm;
% save k_pro2.txt p -ascii
% if pm>pmax
%     pmax = pm;
%     kmax = kk;
%     save kmax_pro2.txt pmax kmax -ascii
% end
fprintf('%3d) Oulu+: Accuracy = %7.2f%% (6 emotions using HO) \n',kk,pm*100)

