% ALSR: Accumulative Local Sparse Representation
% =========================================================
%
% alsr_cls.m : training of a classifier, in this case definition of the
% dictionary.
%
% (c) Domingo Mery - PUC (2016)

function opts = alsr_cls(Xtrain,dtrain,opcl)

if ~isfield(opcl,'NV')
    opcl.NV = 0;
end


if opcl.NV>0
   opvoc           = alsr_visualvoc(Xtrain,opcl);
   opcl            = alsr_mergeoptions(opvoc,opcl);
end



opts = opcl;

a  = opcl.a;
b  = 2*a+1;
b2 = b*b;
opts.b2 = b2;
m  = opcl.m;
LUT = zeros(m,b2);
pp = 0;
for p_j = 1:opcl.mj
    sj = p_j-a:p_j+a;
    sjj = repmat(sj,[b 1]);
    tj = sjj(:);
    for p_i = 1:opcl.mi
        si = p_i-a:p_i+a;
        sii = repmat(si',[1 b]);
        ti = sii(:);
        pp = pp+1;
        LUT(pp,:) = (tj-1)*opcl.mi+ti;
    end
end
LUT(LUT<=0) = NaN;
LUT(LUT>m) = NaN;

opts.LUT = LUT;


% dictionary
opts.D = Xtrain';
opts.dtrain = dtrain;

dr = zeros(1,b2*opcl.k*opcl.ntrain);
for i=1:opcl.k*opcl.ntrain
    dr(1,indices(i,b2))=(i-1)*opcl.m;
end
opts.dr = dr;

