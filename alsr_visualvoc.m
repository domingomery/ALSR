% ALSR: Accumulative Local Sparse Representation
% =========================================================
%
% alsr_visualvoc.m : Visual vocabulary, stopl-list and tfidf
%
% (c) Domingo Mery - PUC (2016)
%
% From Spyrou et al 2010:
% "... most of the cmmon visual words, i.e., those with smallest iDF values,
% are not descriminative and their abscence would facilitate the retrieval
% process. On the other hand, the rarest visual words are in most of the
% cases as result of noise and may distract the retrieval process. To
% overcome those problems, a stop list is created that includes the most
% and the least frequent visual words of the image collection."
%
% From Sivic & Zisserman (2003):
% "Using a stop list the most frequent visual words that occur in almost all
% images are supressed. The top 5% (of the frequency of visual words over
% all the keyframes) and bottom 10% are stopped."

function opvoc = alsr_visualvoc(X,options)

k    = options.k;      % number of subjects
n    = options.ntrain; % number of images per subject
% docu = options.docu;   % one document = one subject (1), or one image (2)

docu = 1;
if isfield(options,'docu');
    docu = options.docu;
end

sv = 1;
if isfield(options,'subvoc'); % subsampling of X
    sv = options.subvoc;
end

m    = options.m/sv;     % number of patches per image

if (m-fix(m))>0
    error('options.m must be multiple of options.sv');
end


if ~isfield(options,'top_bound')
    options.top_bound = 0.05;
end

if ~isfield(options,'bottom_bound')
    options.bottom_bound = 0.1;
end

if ~isfield(options,'tfidf')
    options.tfidf = 1;
end

if ~isfield(options,'stopth')
    options.stopth = 0.9;
end

if docu == 1
    N = k;             % number of documents
    M = m*n;           % number of patches per document
else
    N = k*n;           % number of documents
    M = m;             % number of patches per document
end
fprintf('Computing visual vocabulary of %d words from %d samples of dimension %d...\n',options.NV,size(X(1:sv:end,:),1),size(X,2));
opvoc.ixn    = Bds_labels(M*ones(N,1));
options.ixn  = Bds_labels(M*ones(N,1));
opvoc        = Bsq_visualvoc(X(1:sv:end,:),options);

