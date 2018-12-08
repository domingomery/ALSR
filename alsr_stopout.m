% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_stopout.m : Elimination of stop words
%
% (c) Domingo Mery - PUC (2013), ND (2014)

function [Yfilt,ifilt,iw] = alsr_stopout(Y,options)

[Yfilt,ifilt,iw] = Bsq_stopout(Y,options);