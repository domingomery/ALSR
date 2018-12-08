% ALSR: Accumulative Local Sparse Representation
% =========================================================
%
% alsr_LUTgrid.m : Look up table of the grid
%
% (c) Domingo Mery - PUC (2016)


function opfx = alsr_LUTgrid(opfx)

hp = opfx.height-2*opfx.border;
wp = opfx.width-2*opfx.border;
di = (hp-opfx.w)/(opfx.mi-1);
dj = (wp-opfx.w)/(opfx.mj-1);

i1 = opfx.border+1;
i2 = opfx.height-opfx.w-opfx.border+1;
si = round(i1:di:i2);
ni = length(si);

j1=opfx.border+1;
j2=opfx.width-opfx.w-opfx.border+1;
sj=round(j1:dj:j2);
nj=length(sj);

sii=repmat(si',[1 nj]);
sjj=repmat(sj,[ni 1]);
opfx.ii_grid = sii(:);
opfx.jj_grid = sjj(:);
