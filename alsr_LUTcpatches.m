% ALSR: Accumulative Local Sparse Representation
% =========================================================
%
% alsr_LUTcpatches.m : indices of all pixels of all patches of size axb in an
% image of size hxw a patch is defined from pixel (i,j) of the image to
% pixel (i+a-1,j+b-1)
%
% (c) Domingo Mery - PUC (2016)

function opfx = alsr_LUTcpatches(opfx)

h = opfx.height;
w = opfx.width;
a = opfx.w;
b = opfx.w;

if ~isfield(opfx,'circle');
    opfx.circle = 0;
end

if opfx.circle == 1
    x = zeros(a,b);
    a2 = a/2;
    for i=1:a
        for j=1:a
            if sqrt((i-a2)^2+(j-a2)^2)<a2
                x(i,j)  = 1;
            end
        end
    end
else
    x = ones(a,b);
end
opfx.tx = x(:)==1;

opfx.U = zeros(w*h,a*b);
for i=1:h-a+1
    for j=1:w-b+1
        no = (j-1)*h+i;
        t = zeros(a,b);
        for k=0:b-1
            t(:,k+1) = (no:no+a-1)'+k*h;
        end
        opfx.U(no,:) = t(:)';
    end
end
