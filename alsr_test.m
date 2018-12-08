% ALSR: Accumulative Local Sparse Representation
% =========================================================
%
% alsr_test.m : testing
%
% (c) Domingo Mery - PUC (2016)


function d_cl = alsr_test(Xtest,op)

m = op.m;                               % number of patches per image
nim = size(Xtest,1)/m;                  % number of testing images

if ~isfield(op,'stopth');
    op.stopth = 0.9;
end
if ~isfield(op,'softvote');
    op.softvote = 0;
end
if ~isfield(op,'mask')
    op.mask = ones(op.mi,op.mj);
end
if and(op.NV>0,op.softvote>0)
    %  smgo = (softmax(op.nid_go))'; % very bad
    sgo = sum(op.nid_go);
    xsgo = sgo'*ones(1,op.k);
    smgo = (op.nid_go'./xsgo)*op.k*op.softvote;
    ii = sgo==0;
    smgo(ii,:) = 0;
end

% sparse coding
param_sp.L          = op.L;             % not more than L non-zeros coefficients
param_sp.eps        = op.eps;           % optional, threshold on the squared l2-norm of the residual, 0 by default
param_sp.numThreads = op.numThreads;    % number of processors/cores to use; the default choice is -1 (it selects all the available CPUs/cores)

ft = Bio_statusbar('alsr-testing');
d_cl = zeros(nim,1);
d_gt = zeros(nim,1);

xc = zeros(op.ntrain*op.m,op.k);

fprintf('allocating memory for tuning variables..');
SCIx = zeros(nim*op.m,1);
XSx  = zeros(nim*op.m,op.k);
fprintf('.\n');
q = 0;
x1 = zeros(op.ntrain*op.m,op.k);

for ss=1:nim % for each test image
    ft = Bio_statusbar(ss/nim,ft);
    tic
    
    subject = op.ix_test(ss,1);
    img     = op.ix_test(ss,2);
    
    Xss = single(Xtest(indices(ss,m),:));
    if op.NV > 0
        [Xfilt,ifilt,iw] = alsr_stopout(Xss,op); % removing patches that belong to stoplist
        X0    = zeros(size(Xss));
        X0(ifilt,:) = Xfilt;
        Ytest = single(X0');
    else
        Ytest = single(Xss');
        ifilt = ones(op.m,1);                   % all patches are accepted
    end
    ifilt = ifilt.*op.mask(:);
    
    pp_lut_master = zeros(op.m,op.b2*op.k*op.ntrain);
    ii_lut_master = false(op.m,op.b2*op.k*op.ntrain);
    for i_t = 1:op.m    % for each patch
        pp_lut_master(i_t,:) = repmat(op.LUT(i_t,:),[1 op.k*op.ntrain])+op.dr;
        ii_lut_master(i_t,:) = ~isnan(pp_lut_master(i_t,:));
    end
    xx  = zeros(1,op.k);
    
    
    for i_t = 1:op.m    % for each patch
        q = q+1;
        if ifilt(i_t) == 1
            il       = ii_lut_master(i_t,:)==1;
            pp_lut   = pp_lut_master(i_t,il);
            DD       = op.D(:,pp_lut);
            ytest    = Ytest(:,i_t);
            Xc       = ytest'*DD;
            ic       = find(Xc>op.thsim);
            icl      = pp_lut(ic);
            if ~isempty(ic)
                xicl      = zeros(op.k*op.ntrain*op.m,1); % sum of each contribution
                DD_ic     = DD(:,ic);
                xt        = full(mexOMP(ytest,DD_ic,param_sp));
                xt_pos    = abs(xt);
                xicl(icl) = xt_pos;
                xc(:)     = xicl;
                s         = sum(xc);
                s1        = sum(s);
                scix      = (op.k*max(s)/s1-1)/(op.k-1);
                x1(:)     = xicl;x2 = sum(x1,1);
                SCIx(q)   = scix;
                XSx(q,:)  = x2';
                scix      = SCIx(q);
                x2        = XSx(q,:);
                if scix > op.thsci
                    xj = x2;
                    if op.softvote == 0
                        mx = (xj/max(xj));
                    else
                        mx = (xj/max(xj)).*smgo(iw(i_t),:);
                    end
                    mx(mx<op.thatm) = 0;
                    xx = xx+mx;
                end
            end
        end
    end
    
    xs = xx/sum((xx));
    [ii,jj] = max(xs);
    
    figure(1);bar(xs);axis([1 op.k 0 0.5]);
    title(['max: subject ' num2str(jj)])
    d_cl(ss) = jj;      % classified as
    d_gt(ss) = subject; % ground truth
    t = toc;
    p = Bev_performance(d_cl(1:ss)       ,d_gt(1:ss))*100;
    
    fprintf('%3d) face_%s_%s: gt = %3d cl = %3d p = %6.2f%% SCI*=%7.4f [%7.4f sec]\n',ss,num2fixstr(subject,4),num2fixstr(img,4),d_gt(ss),d_cl(ss),p,ii,t);
    
    drawnow
    %if and(tun == 1,mod(ss,5)==0)
    %    save(op.tuning,'SCIx','ERRx','XSx','DSx')
    %end
    if mod(ss,5)==0
        if isfield(op,'tuning')
            save(op.tuning,'SCIx','XSx')
        end
    end
    
    
end
delete(ft)
if isfield(op,'tuning')
    save(op.tuning,'SCIx','XSx')
end



