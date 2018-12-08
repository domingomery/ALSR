% ALSR: Accumulative Local Sparse Representation
% =========================================================
%
% alsr_fxt.m : feature extraction
%
% (c) Domingo Mery - PUC (2016)

function [x,xy] = alsr_fxt(I,opfx)

if ~isfield(opfx,'blur')
    opfx.blur = 0;
end

if ~isfield(opfx,'mirror')
    opfx.mirror = 0;
end

if ~isfield(opfx,'tantriggs')
    opfx.tantriggs = 0;
end

if opfx.blur ~= 0
    [N,M] = size(I);
    I0    = imresize(I,opfx.blur);
    I     = imresize(I0,[N M]);
end
    
if opfx.mirror ~= 0
    I     = I(:,end:-1:1);
end

if opfx.tantriggs ~= 0
    I     = tantriggs(I);
end




if ~isfield(opfx,'show')
    opfx.show = 0;
end

if opfx.show == 1
    imshow(I,[])
    drawnow
end
    


x  = single(alsr_readcpatches(I,opfx.ii_grid,opfx.jj_grid,opfx.U,opfx));
xy = [opfx.ii_grid opfx.jj_grid];

if opfx.uninorm == 1 % normalization
    x    = single(Bft_uninorm(x));
    xy   = [xy(:,1)/opfx.height xy(:,2)/opfx.width];
end


function Y = alsr_readcpatches(I,ii,jj,U,options)
% ii: i values of coordinate i of first pixel of all patches
% jj: j values of coordinate j of first pixel of all patches
% I : grayvalue image
% U : Lookup Table of the indices of the patches computed using LUTpatches
h     = size(I,1);
kk    = (jj-1)*h+ii;
Iv    = I(:);
n     = length(kk);
s     = options.patchsub;
zz    = false(options.w,options.w);
zt    = zz;
zt(:) = options.tx;
zz(1:s:end,1:s:end) = zt(1:s:end,1:s:end);
ii    = zz(:);
m     = sum(ii);
Y     = zeros(n,m);
Y(:)  = Iv(U(kk,ii));
