function [cropOS] = m3yieldmodel_generator_sf_kf_bs(input, ...
    modelnumber, LSQflag, bootstrapreps)

% [cropOS] = reg_m3yieldmodel_generator_sf_kf_bs(input, ...
%            modelnumber, LSQflag, bootstrapreps)
%
% Model number specifies which functional form to use.
% Model number 1: Von Liebig expanded logistic model
% Model number 2: Von Liebig Mitscherlich-Baule
%
% LSQFlag specifies whether to use LSQCurveFit in the Optimization Toolbox.
% This will allow slope parameters to be constrained to 5x and 1/5x global
% average for each nutrient response. Otherwise parameters will be fit
% using the function NLINFIT in the Statistics Toolbox.
%
% The input structure should contain the following information:
%
%     FiveMinGridCellAreas: [4320x2160 single]
%                 cropname: 'maize'
%                      CDS: [1x100 struct]
%               YGFraction: [4320x2160 single]
%              ClimateMask: [4320x2160 uint16]
%                    Yield: [4320x2160 single]
%           CultivatedArea: [4320x2160 single]
%           potentialyield: [4320x2160 single]
%                 minyield: [4320x2160 single]
%                      irr: [4320x2160 single]
%                      sqi: [4320x2160 single]
%                    Nfert: [4320x2160 double]
%                Ndatatype: [4320x2160 double]
%                    Pfert: [4320x2160 double]
%                Pdatatype: [4320x2160 double]
%                    Kfert: [4320x2160 double]
%                Kdatatype: [4320x2160 double]



%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     SETTINGS     %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

slopemultvect_master = [.5 .75 1 1.5 2];
% slopemultvect = 1;

% set percentiles for confidence intervals
perCI = [0.025 0.05 0.1 0.9 0.95 0.975];

politunitsampleflag = 0;



%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%       MODEL      %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%


% set model choice: VL LM OR VL MBM
switch modelnumber
    case 1
        modelname = 'VL_LM';
        modelnamelong = 'von Liebig logistic model';
    case 2
        modelname = 'VL_MBM';
        modelnamelong = 'von Liebig Mitscherlich-Baule model';
end

% set up bootstrap stuff and load model csv
bootstrapvector = 0:bootstrapreps;
disp(['running yield model with bootstrap, ' ...
    num2str(bootstrapreps) ' samples per bin']);
filestr = [iddstring 'ClimateBinAnalysis/YieldModel/' ...
    input.cropname '_m3yieldmodeldata_' modelname '.csv'];
MS = ReadGenericCSV(filestr);

% initialize raw bootstrap output
outputraw = cell(1+(100.*length(bootstrapvector)),8);
outputraw{1,1} = 'climate bin';
counter = 2;
for c = 1:100;
    for b = 1:length(bootstrapvector)
        outputraw{counter,1} = c;
        counter = counter +1;
    end
end
outputraw{1,2} = 'bootstrap replicate';
counter = 2;
for c = 1:100;
    for b = 1:length(bootstrapvector)
        outputraw{counter,2} = b-1;
        counter = counter +1;
    end
end
outputraw{1,3} = 'explanatory variable list';
outputraw{1,4} = 'c_N';
outputraw{1,5} = 'c_P2O5';
outputraw{1,6} = 'c_K2O';
outputraw{1,7} = 'yc_rf';
outputraw{1,8} = 'b_K2O';
outputraw{1,9} = 'bin_rmse';

% initialize percentile bootstrap output
outputCI = cell(1+(100.*length(perCI)),8);
outputCI{1,1} = 'climate bin';
counter = 2;
for c = 1:100;
    for b = 1:length(perCI)
        outputCI{counter,1} = c;
        counter = counter +1;
    end
end
outputCI{1,2} = 'CI percentile';
counter = 2;
for c = 1:100;
    for b = 1:length(perCI)
        outputCI{counter,2} = perCI(b);
        counter = counter +1;
    end
end
outputCI{1,3} = 'explanatory variable list';
outputCI{1,4} = 'c_N';
outputCI{1,5} = 'c_P2O5';
outputCI{1,6} = 'c_K2O';
outputCI{1,7} = 'yc_rf';
outputCI{1,8} = 'b_K2O';


% find upper and lower bound of acceptable slopes for each nutrient if the
% LSQflag is turned on
if LSQflag == 1
    
    ii = find(isfinite(input.CultivatedArea) ... % cells with crop area
        & isfinite(input.Yield) ... % and yield data (should be same)
        & isfinite(input.potentialyield) ... % PY throws out lowest 5% area
        & isfinite(input.irr) ... % and irrigation data
        & isfinite(input.Nfert) & isfinite(input.Pfert) ...
        & isfinite(input.Kfert) ... % and fertilizer data
        & (input.Ndatatype < 6) & (input.Pdatatype < 6) ...
        & (input.Kdatatype < 6)); % discard problematic fert data (Brazil)
    
    area_bin = double(input.CultivatedArea(ii));
    irr_bin = double(input.irr(ii));
    nfert_bin = double(input.Nfert(ii));
    pfert_bin = double(input.Pfert(ii));
    kfert_bin = double(input.Kfert(ii));
    yield_bin = double(input.Yield(ii));
    
    % calculate median global potential yield and min yield
    potyields = unique(input.potentialyield(isfinite(input.potentialyield)));
    potyieldglobal = median(potyields);
    minyields = unique(input.minyield(isfinite(input.minyield)));
    minyieldglobal = median(minyields);
    
    % calculate bnut for LM using minyield (note: "log" in matlab is
    % actually the natural log "ln") (also note: I may label bnut as
    % something else in the text of the paper)
    bnut = log((potyieldglobal ./ minyieldglobal) - 1);
    bnutglobal = bnut;
    
    % calculate alpha for MBM using minyield
    alpha = 1 - (minyieldglobal ./ potyieldglobal);
    alphaglobal = alpha;
    
    % calculate upper and lower bounds for nutrient response slopes
    for nut = 1:3
        switch nut
            case 1
                x = nfert_bin(:);
            case 2
                x = pfert_bin(:);
            case 3
                x = kfert_bin(:);
        end
        
        w = area_bin ./ mean(area_bin);
        w = w(:);
        y = yield_bin(:);
        
        switch modelnumber
            case 1
                %%% LM
                agmgmt = @(b,x) potyieldglobal ...
                    ./ (1 + exp(bnut - abs(b(1)) ...
                    .* x(:,1)));
            case 2
                %%% MB
                agmgmt = @(b,x) potyieldglobal .* ...
                    (1 - (alpha .* exp(-abs(b(1)) .* x(:,1))));
        end
        
        yw = sqrt(w).*yield_bin;
        agmgmtw = @(b,x) double(sqrt(w).*agmgmt(b,x));
        
        % set beta0 and run regression
        slope0 = 0.01;
        blist={};rlist={};mlist=[];
        for m = [0.1 0.25 0.5 0.75 1 1.5 2 4 10]
            sm = slope0.*m;
            beta0 = sm;
            if LSQflag == 1
                [bFitw,resnorm,rw,exitflag,lsqoutput] = ...
                    lsqcurvefit(agmgmtw,double(beta0),x,yw);
                msew = mean(rw.^2);
            else
                [bFitw,rw,Jw,Sigmaw,msew] = ...
                    nlinfit(x,yw,agmgmtw,beta0);
            end
            blist{length(blist)+1} = abs(bFitw);
            rlist{length(rlist)+1} = rw;
            mlist(length(mlist)+1) = msew;
        end
        [tmp,yy] = min(mlist);
        if length(yy)>1
            yy = yy(1);
        end
        msew = mlist(yy);
        rw = rlist{yy};
        bFitw = blist{yy};
        
        % set upper and lower bounds for slope
        slopeUB = bFitw .* 5;
        slopeLB = bFitw ./ 5;
        
        switch nut
            case 1
                slopeGN = bFitw;
                slopeUBN = slopeUB;
                slopeLBN = slopeLB;
            case 2
                slopeGP = bFitw;
                slopeUBP = slopeUB;
                slopeLBP = slopeLB;
            case 3
                slopeGK = bFitw;
                slopeUBK = slopeUB;
                slopeLBK = slopeLB;
        end
    end
    clear slopeUB slopeLB
    slope0 = mean([slopeGN slopeGP slopeGK]);
    slopeglobalall = [slopeGN slopeGP slopeGK];
    slopeUBall = [slopeUBN slopeUBP slopeUBK];
    slopeLBall = [slopeLBN slopeLBP slopeLBK];
end

% check for cotton
if strmatch(input.cropname,'cotton');
    warning(['Hard-coded to skip bins 61 and 81 b/c yield ceiling = ' ...
        'yield floor for year 2000 data. If updating models check '...
        'to make sure this is still the case!!!!!!!!']);
    binlistvector = [1:60 62:80 82:100];
else
    binlistvector = 1:max(max(input.ClimateMask));
end

% initialize storage variables for the bins
rmselist_bins = zeros(length(binlistvector),length(bootstrapvector));
bFitwlist_bins = cell(length(binlistvector),length(bootstrapvector));

% initialize counters for output
c_raw = 2;
c_CI = 2;

% loop through bins
for bin = binlistvector
    
    % identify grid cells in the bin that meet data requirements:
    ii = find(isfinite(input.CultivatedArea) ... % cells with crop area
        & isfinite(input.Yield) ... % and yield data (should be same)
        & isfinite(input.potentialyield) ... % PY throws out lowest 5% area
        & (input.ClimateMask == bin) ...% and only in the climate bin
        & isfinite(input.irr) ... % and irrigation data
        & isfinite(input.Nfert) & isfinite(input.Pfert) ...
        & isfinite(input.Kfert) ... % and fertilizer data
        & (input.Ndatatype > 0) & (input.Pdatatype > 0) ...
        & (input.Kdatatype > 0)); % discard problematic fert data (Brazil)
    
    % make double & select bin area
    area_bin = double(input.CultivatedArea(ii));
    irr_bin = double(input.irr(ii));
    nfert_bin = double(input.Nfert(ii));
    pfert_bin = double(input.Pfert(ii));
    kfert_bin = double(input.Kfert(ii));
    yield_bin = double(input.Yield(ii));
    
    % identify potential yield in the bin
    binyieldceiling = unique(input.potentialyield(ii));
    cropOS.potyieldlist(bin) = binyieldceiling;
    binyieldfloor = unique(input.minyield(ii));
    cropOS.minyieldlist(bin) = binyieldfloor;
    
    % set the b0irr value; this is the starting value for the b_irr
    % parameter that defines the maximum rainfed yield in the bin
    b0irr = binyieldceiling .* 0.5;
    
    % calculate bnut for ELM using minyield (note: "log" in matlab is
    % actually the natural log "ln") (also note: I may label bnut
    % and/or alpha as something else in the text of the paper)
    bnut = log((binyieldceiling ./ binyieldfloor) - 1);
    
    % calculate alpha for MB using minyield
    alpha = 1 - (binyieldfloor ./ binyieldceiling);
    
    % record bnut or alpha depending on the model
    switch modelnumber
        case 1
            cropOS.bnutlist(bin) = bnut;
        case 2
            cropOS.bnutlist(bin) = alpha;
    end
    
    
    % set up explanatory variable and weights
    xtot = [nfert_bin(:) pfert_bin(:) kfert_bin(:) irr_bin(:)];
    w_allpts = area_bin ./ mean(area_bin);
    w_allpts = w_allpts(:);
    y_allpts = yield_bin(:);
    
    % calculated weighted average mean yield for the bin for r2
    % calculations
    tmp = yield_bin .* w_allpts;
    wavg_yield_bin = mean(tmp) ./ mean(w_allpts);
    
    
    % grab the explanatory variable list for this bin
    cb = num2str(MS.explanatory_variable_list{bin});
    % add missing zeros if necessary
    if length(cb) < 4
        tmp = 4-length(cb);
        if tmp == 1;
            cb = ['0' cb];
        elseif tmp == 2;
            cb = ['00' cb];
        end
    end
    % first find the number of nutrient variables
    numnutvars = 0;
    for m = 1:3
        if str2num(cb(m)) == 1
            numnutvars = numnutvars + 1;
        end
    end
    % then find whether irrigation is on or off
    if str2num(cb(4)) == 1
        i = 1;
    elseif str2num(cb(4)) == 0
        i = 0;
    end
    
    % grab the appropriate nutrient variables and create
    % slopeUB/LB vectors
    x_allpts = [];% i have renamed x to x_allpts because we need to sample
    slopeUBvector = [];
    slopeLBvector = [];
    beta0vector = [];
    for m = 1:3
        if str2num(cb(m)) == 1
            x_allpts = [x_allpts xtot(:,m)];
            slopeUBvector = [slopeUBvector slopeUBall(m)];
            slopeLBvector = [slopeLBvector slopeLBall(m)];
            beta0vector = [beta0vector slopeglobalall(m)];
        end
    end
    
    % record the number of nutrient variables
    if ~isempty(x_allpts)
        numnutvars = length(x_allpts(1,:));
    else
        numnutvars = 0;
    end
    
    % add irrigation variable if i equals 1. add UB/LB values
    % for b_irr (rainfed potential yield)
    if i == 1
        x_allpts = [x_allpts xtot(:,4)];
        slopeUBvector = [slopeUBvector binyieldceiling];
        slopeLBvector = [slopeLBvector binyieldfloor];
        beta0vector = [beta0vector b0irr];
    end
    % add in bnut/alpha if we are including potash - since we
    % want to have a floating potash intercept.
    if str2num(cb(3)) == 1
        switch modelnumber
            case 1
                b0kint = bnut;
                error(['need to figure out UB/LB for ' ...
                    'floating K y-int & logistic model']);
            case 2
                b0kint = alpha;
                slopeUBvector = [slopeUBvector alpha];
                slopeLBvector = [slopeLBvector 0];
        end
    else
        b0kint = [];
    end
    slopeUBvector = double(slopeUBvector);
    slopeLBvector = double(slopeLBvector);
    beta0vector = double(beta0vector);
    
    % assign bin-specific values to IRR SF functions
    assign.binyieldceiling = binyieldceiling;
    assign.bnut = bnut;
    assign.alpha = alpha;
    assign.kfloatflag = 1;
    assign.cb = cb;
    [~] = agmgmt_elm_irrintmodel_nutoneirron_sf(0,0,assign);
    [~] = agmgmt_elm_irrintmodel_nuttwoirron_sf(0,0,assign);
    [~] = agmgmt_elm_irrintmodel_nutthreeirron_sf(0,0,assign);
    [~] = agmgmt_mbm_irrintmodel_nutoneirron_sf(0,0,assign);
    [~] = agmgmt_mbm_irrintmodel_nuttwoirron_sf(0,0,assign);
    [~] = agmgmt_mbm_irrintmodel_nutthreeirron_sf(0,0,assign);
    
    
    % initialize storage variables for the bootstrap runs
    bFitwlist_bsruns = [];
    
    % create x_allpts_w with weights
    x_y_w_allpts = [x_allpts y_allpts w_allpts];
    numcols = length(x_y_w_allpts(1,:));
    
    % loop through bootstrap replicates
    for b = bootstrapvector
        
        % sample x, y, w
        if b == 0
            x = x_allpts;
            y = y_allpts;
            w = w_allpts;
        else
            % take sample for bootstrap
            if politunitsampleflag == 1 % select all points with same x 
                 % vals if one is selected (i.e. same political unit)?
                sampleraw = datasample(x_y_w_allpts,length(x_allpts(:,1)),...
                    'Replace',true,'Weights',w_allpts);
                sample = [];
                for r = 1:length(sampleraw)
                    % identify points with same x_allpts_w characteristics
                    % (except w) - then add all these points in to the
                    % sample - corresponds to a unique political unit
                
                
                end
                cumsumsampleweights = cumsum(sample(:,numcols));%last col=w
                % get sample the right amount of area
                [~, qq] = min(abs(cumsumsampleweights - sum(w_allpts)));
                x = sample(1:qq,:);
                 
            else % sample grid cells normally, in proportion to area
                sample=datasample(x_y_w_allpts, 1*length(x_allpts(:,1)),...
                    'Replace',true,'Weights',w_allpts);
                x = sample(:,1:numcols-2); % first several cols = x vars
                y = sample(:,numcols-1); % y = second to last column
                w = ones(length(sample),1); % w = ones for all b/c weighted during sampling
                
%                 cumsumsampleweights = cumsum(sample(:,numcols));%last col=w
%                 % get sample the right amount of area
%                 [~, qq] = min(abs(cumsumsampleweights - sum(w_allpts)));
%                 x = sample(1:qq,1:numcols-2); % first several cols = x vars
%                 y = sample(1:qq,numcols-1); % y = second to last column
%                 w = sample(1:qq,numcols); % w = last column
            end
        end
        
        % if b == 0, then run through the bootstrapvector to get the best
        % starting value
        if b == 0
            slopemultvect = slopemultvect_master;
        else
            slopemultvect = beststartingvalue_thisbin;
        end
        
        
        % create and run the appropriate model
        switch numnutvars
            
            case 1
                
                if i == 0
                    
                    % VL MB: 1 nutrient, no irr
                    
                    if str2num(cb(3)) == 1
                        agmgmt = @(b,x) binyieldceiling ...
                            .* (1 - (b(2) .* ...
                            exp(-abs(b(1)) .* x(:,1))));
                    else
                        agmgmt = @(b,x) binyieldceiling ...
                            .* (1 - (alpha .* ...
                            exp(-abs(b(1)) .* x(:,1))));
                    end
                    yw = sqrt(w).*y;
                    agmgmtw = @(b,x) double(sqrt(w).*...
                        agmgmt(b,x));
                    
                    % set beta0 and run regression
                    blist={};rlist={};mlist=[];r2list=[];
                    for m = 1:length(slopemultvect)
                        beta0 = beta0vector.*slopemultvect(m);
                        beta0 = [beta0 b0kint];
                        if LSQflag == 1
                            [bFitw,resnorm,rw] = ...
                                lsqcurvefit(agmgmtw, ...
                                double(beta0),x,yw, ...
                                slopeLBvector,slopeUBvector);
                            msew = mean(rw.^2);
                        else
                            [bFitw,rw,Jw,Sigmaw,msew] = ...
                                nlinfit(x,yw,agmgmtw,beta0);
                        end
                        blist{length(blist)+1} = bFitw;
                        rlist{length(rlist)+1} = rw;
                        mlist(length(mlist)+1) = msew;
                        r2list(length(r2list)+1) = ...
                            1-sum(rw.^2)./sum((( ...
                            y-wavg_yield_bin) ...
                            .*sqrt(w)).^2);
                    end
                    [~,yy] = min(mlist);
                    if length(yy)>1
                        yy = yy(1);
                    end
                    msew = mlist(yy);
                    rw = rlist{yy};
                    bFitw = blist{yy};
                    
                elseif i == 1
                    
                    % VL MB: 1 nutrient + irr
                    
                    yw = sqrt(w).*y;
                    agmgmtw = @(b,x) double(sqrt(w).*...
                        agmgmt_mbm_irrintmodel_nutoneirron_sf(b,x));
                    
                    % set beta0 and run regression
                    blist={};rlist={};mlist=[];r2list=[];
                    for m = 1:length(slopemultvect)
                        beta0 = beta0vector.*slopemultvect(m);
                        beta0 = [beta0 b0kint];
                        if LSQflag == 1
                            [bFitw,resnorm,rw] = ...
                                lsqcurvefit(agmgmtw, ...
                                double(beta0),x,yw, ...
                                slopeLBvector,slopeUBvector);
                            msew = mean(rw.^2);
                        else
                            [bFitw,rw,Jw,Sigmaw,msew] = ...
                                nlinfit(x,yw,agmgmtw,beta0);
                        end
                        blist{length(blist)+1} = bFitw;
                        rlist{length(rlist)+1} = rw;
                        mlist(length(mlist)+1) = msew;
                        r2list(length(r2list)+1) = ...
                            1-sum(rw.^2)./sum((( ...
                            y-wavg_yield_bin) ...
                            .*sqrt(w)).^2);
                    end
                    [~,yy] = min(mlist);
                    if length(yy)>1
                        yy = yy(1);
                    end
                    msew = mlist(yy);
                    rw = rlist{yy};
                    bFitw = blist{yy};
                    
                end
                
            case 2
                
                if i == 0
                    
                    % VL MB: 2 nutrients, no irr
                    
                    if str2num(cb(3)) == 1
                        agmgmt = @(b,x) min([(binyieldceiling ...
                            .* (1 - (alpha .* ...
                            exp(-abs(b(1)) .* x(:,1))))), ...
                            (binyieldceiling ...
                            .* (1 - (b(3) .* ...
                            exp(-abs(b(2)) .*x(:,2)))))],[],2);
                    else
                        agmgmt = @(b,x) min([(binyieldceiling ...
                            .* (1 - (alpha .* ...
                            exp(-abs(b(1)) .* x(:,1))))), ...
                            (binyieldceiling ...
                            .* (1 - (alpha .* ...
                            exp(-abs(b(2)) .*x(:,2)))))],[],2);
                    end
                    yw = sqrt(w).*y;
                    agmgmtw = @(b,x) double(sqrt(w).*...
                        agmgmt(b,x));
                    
                    % set beta0 and run regression
                    blist={};rlist={};mlist=[];r2list=[];
                    for m = 1:length(slopemultvect)
                        beta0 = beta0vector.*slopemultvect(m);
                        beta0 = [beta0 b0kint];
                        if LSQflag == 1
                            [bFitw,resnorm,rw] = ...
                                lsqcurvefit(agmgmtw, ...
                                double(beta0),x,yw, ...
                                slopeLBvector,slopeUBvector);
                            msew = mean(rw.^2);
                        else
                            [bFitw,rw,Jw,Sigmaw,msew] = ...
                                nlinfit(x,yw,agmgmtw,beta0);
                        end
                        blist{length(blist)+1} = bFitw;
                        rlist{length(rlist)+1} = rw;
                        mlist(length(mlist)+1) = msew;
                        r2list(length(r2list)+1) = ...
                            1-sum(rw.^2)./sum((( ...
                            y-wavg_yield_bin) ...
                            .*sqrt(w)).^2);
                    end
                    [~,yy] = min(mlist);
                    if length(yy)>1
                        yy = yy(1);
                    end
                    msew = mlist(yy);
                    rw = rlist{yy};
                    bFitw = blist{yy};
                    
                elseif i == 1
                    
                    % VL MB: 2 nutrients + irr
                    
                    yw = sqrt(w).*y;
                    agmgmtw = @(b,x) double(sqrt(w).*...
                        agmgmt_mbm_irrintmodel_nuttwoirron_sf(b,x));
                    
                    % set beta0 and run regression
                    blist={};rlist={};mlist=[];r2list=[];
                    for m = 1:length(slopemultvect)
                        beta0 = beta0vector.*slopemultvect(m);
                        beta0 = [beta0 b0kint];
                        if LSQflag == 1
                            [bFitw,resnorm,rw] = ...
                                lsqcurvefit(agmgmtw, ...
                                double(beta0),x,yw, ...
                                slopeLBvector,slopeUBvector);
                            msew = mean(rw.^2);
                        else
                            [bFitw,rw,Jw,Sigmaw,msew] = ...
                                nlinfit(x,yw,agmgmtw,beta0);
                        end
                        blist{length(blist)+1} = bFitw;
                        rlist{length(rlist)+1} = rw;
                        mlist(length(mlist)+1) = msew;
                        r2list(length(r2list)+1) = ...
                            1-sum(rw.^2)./sum((( ...
                            y-wavg_yield_bin) ...
                            .*sqrt(w)).^2);
                    end
                    [~,yy] = min(mlist);
                    if length(yy)>1
                        yy = yy(1);
                    end
                    msew = mlist(yy);
                    rw = rlist{yy};
                    bFitw = blist{yy};
                    
                end
                
            case 3
                
                if i == 0
                    
                    % VL MB: 3 nutrients, no irr
                    
                    if str2num(cb(3)) == 1
                        agmgmt = @(b,x) min([(binyieldceiling ...
                            .* (1 - (alpha .* ...
                            exp(-abs(b(1)) .* x(:,1))))), ...
                            (binyieldceiling ...
                            .* (1 - (alpha .* ...
                            exp(-abs(b(2)) .*x(:,2))))), ...
                            (binyieldceiling ...
                            .* (1 - (b(4) .* ...
                            exp(-abs(b(3)) .*x(:,3)))))],[],2);
                    else
                        agmgmt = @(b,x) min([(binyieldceiling ...
                            .* (1 - (alpha .* ...
                            exp(-abs(b(1)) .* x(:,1))))), ...
                            (binyieldceiling ...
                            .* (1 - (alpha .* ...
                            exp(-abs(b(2)) .*x(:,2))))), ...
                            (binyieldceiling ...
                            .* (1 - (alpha .* ...
                            exp(-abs(b(3)) .*x(:,3)))))],[],2);
                    end
                    yw = sqrt(w).*y;
                    agmgmtw = @(b,x) double(sqrt(w).*...
                        agmgmt(b,x));
                    
                    % set beta0 and run regression
                    blist={};rlist={};mlist=[];r2list=[];
                    for m = 1:length(slopemultvect)
                        beta0 = beta0vector.*slopemultvect(m);
                        beta0 = [beta0 b0kint];
                        if LSQflag == 1
                            [bFitw,resnorm,rw] = ...
                                lsqcurvefit(agmgmtw, ...
                                double(beta0),x,yw, ...
                                slopeLBvector,slopeUBvector);
                            msew = mean(rw.^2);
                        else
                            [bFitw,rw,Jw,Sigmaw,msew] = ...
                                nlinfit(x,yw,agmgmtw,beta0);
                        end
                        blist{length(blist)+1} = bFitw;
                        rlist{length(rlist)+1} = rw;
                        mlist(length(mlist)+1) = msew;
                        r2list(length(r2list)+1) = ...
                            1-sum(rw.^2)./sum((( ...
                            y-wavg_yield_bin) ...
                            .*sqrt(w)).^2);
                    end
                    [~,yy] = min(mlist);
                    if length(yy)>1
                        yy = yy(1);
                    end
                    msew = mlist(yy);
                    rw = rlist{yy};
                    bFitw = blist{yy};
                    
                    
                elseif i == 1
                    
                    % VL MB: 3 nutrients + irr
                    
                    yw = sqrt(w).*y;
                    agmgmtw = @(b,x) double(sqrt(w).*...
                        agmgmt_mbm_irrintmodel_nutthreeirron_sf(b,x));
                    
                    % set beta0 and run regression
                    blist={};rlist={};mlist=[];r2list=[];
                    for m = 1:length(slopemultvect)
                        beta0 = beta0vector.*slopemultvect(m);
                        beta0 = [beta0 b0kint];
                        if LSQflag == 1
                            [bFitw,resnorm,rw] = ...
                                lsqcurvefit(agmgmtw, ...
                                double(beta0),x,yw, ...
                                slopeLBvector,slopeUBvector);
                            msew = mean(rw.^2);
                        else
                            [bFitw,rw,Jw,Sigmaw,msew] = ...
                                nlinfit(x,yw,agmgmtw,beta0);
                        end
                        blist{length(blist)+1} = bFitw;
                        rlist{length(rlist)+1} = rw;
                        mlist(length(mlist)+1) = msew;
                        r2list(length(r2list)+1) = ...
                            1-sum(rw.^2)./sum((( ...
                            y-wavg_yield_bin) ...
                            .*sqrt(w)).^2);
                    end
                    [~,yy] = min(mlist);
                    if length(yy)>1
                        yy = yy(1);
                    end
                    msew = mlist(yy);
                    rw = rlist{yy};
                    bFitw = blist{yy};
                    
                end
        end
        
        % if this is run 0, save the best starting value
        if b == 0
            beststartingvalue_thisbin = slopemultvect_master(yy);
        end
        
        % save the bFitw values for this bootstrap run if b>0
        if b > 0
            bFitwlist_bsruns(b,:) = bFitw;
        end
        
        % save stuff - raw output
        outputraw{c_raw,2} = b;
        outputraw{c_raw,3} = cb;
        % c_N
        if str2num(cb(1)) == 1
            outputraw{c_raw,4} = abs(bFitw(1));
        end
        % c_P2O5
        if str2num(cb(2)) == 1
            othernuts = 0;
            if str2num(cb(1)) == 1
                othernuts = 1;
            end
            switch othernuts
                case 0
                    outputraw{c_raw,5} = abs(bFitw(1));
                case 1
                    outputraw{c_raw,5} = abs(bFitw(2));
            end
        end
        % c_K2O
        if str2num(cb(3)) == 1
            othernuts = 0;
            for k = 1:2
                if str2num(cb(k)) == 1
                    othernuts = othernuts + 1;
                end
            end
            switch othernuts
                case 0
                    outputraw{c_raw,6} = abs(bFitw(1));
                case 1
                    outputraw{c_raw,6} = abs(bFitw(2));
                case 2
                    outputraw{c_raw,6} = abs(bFitw(3));
            end
        end
        % yc_rf
        if str2num(cb(4)) == 1
            othernuts = 0;
            for k = 1:3
                if str2num(cb(k)) == 1
                    othernuts = othernuts + 1;
                end
            end
            switch othernuts
                case 0
                    outputraw{c_raw,7} = bFitw(1);
                case 1
                    outputraw{c_raw,7} = bFitw(2);
                case 2
                    outputraw{c_raw,7} = bFitw(3);
                case 3
                    outputraw{c_raw,7} = bFitw(4);
            end
        end
        % b_K2O
        if str2num(cb(3)) == 1 % only look up b_K if K2O is an explan var
            numinputs = 0;
            for k = 1:4
                if str2num(cb(k)) == 1
                    numinputs = numinputs + 1;
                end
            end
            switch numinputs
                case 1
                    outputraw{c_raw,8} = bFitw(2);
                case 2
                    outputraw{c_raw,8} = bFitw(3);
                case 3
                    outputraw{c_raw,8} = bFitw(4);
                case 4
                    outputraw{c_raw,8} = bFitw(5);
            end
        end
        % rmse
        outputraw{c_raw,9} = sqrt(msew);
        c_raw = c_raw + 1;

    end
    
    % after going through all bootstrap replicates - look at replicates
    % 1:length(bootstrapvector) and find the percentiles indicated
    outputCI(c_CI:(c_CI+length(perCI)-1),3) = ...
        repmat({cb},length(perCI),1);
    % c_N
    if str2num(cb(1)) == 1
        for p = 1:length(perCI)
            outputCI{c_CI+p-1,4} = ...
                percentile(bFitwlist_bsruns(:,1),perCI(p));
        end
    end
    % c_P2O5
    if str2num(cb(2)) == 1
        othernuts = 0;
        if str2num(cb(1)) == 1
            othernuts = 1;
        end
        switch othernuts
            case 0
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,5} = ...
                        percentile(bFitwlist_bsruns(:,1),perCI(p));
                end
            case 1
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,5} = ...
                        percentile(bFitwlist_bsruns(:,2),perCI(p));
                end
        end
    end
    % c_K2O
    if str2num(cb(3)) == 1
        othernuts = 0;
        for k = 1:2
            if str2num(cb(k)) == 1
                othernuts = othernuts + 1;
            end
        end
        switch othernuts
            case 0
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,6} = ...
                        percentile(bFitwlist_bsruns(:,1),perCI(p));
                end
            case 1
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,6} = ...
                        percentile(bFitwlist_bsruns(:,2),perCI(p));
                end
            case 2
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,6} = ...
                        percentile(bFitwlist_bsruns(:,3),perCI(p));
                end
        end
    end
    % yc_rf
    if str2num(cb(4)) == 1
        othernuts = 0;
        for k = 1:3
            if str2num(cb(k)) == 1
                othernuts = othernuts + 1;
            end
        end
        switch othernuts
            case 0
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,7} = ...
                        percentile(bFitwlist_bsruns(:,1),perCI(p));
                end
            case 1
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,7} = ...
                        percentile(bFitwlist_bsruns(:,2),perCI(p));
                end
            case 2
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,7} = ...
                        percentile(bFitwlist_bsruns(:,3),perCI(p));
                end
            case 3
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,7} = ...
                        percentile(bFitwlist_bsruns(:,4),perCI(p));
                end
        end
    end
    % b_K2O
    if str2num(cb(3)) == 1 % only look up b_K if K2O is an explan var
        numinputs = 0;
        for k = 1:4
            if str2num(cb(k)) == 1
                numinputs = numinputs + 1;
            end
        end
        switch numinputs
            case 1
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,8} = ...
                        percentile(bFitwlist_bsruns(:,2),perCI(p));
                end
            case 2
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,8} = ...
                        percentile(bFitwlist_bsruns(:,3),perCI(p));
                end
            case 3
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,8} = ...
                        percentile(bFitwlist_bsruns(:,4),perCI(p));
                end
            case 4
                for p = 1:length(perCI)
                    outputCI{c_CI+p-1,8} = ...
                        percentile(bFitwlist_bsruns(:,5),perCI(p));
                end
        end
    end
    
    % add to counter
    c_CI = c_CI + length(perCI);
    
end

filename = [input.cropname '_bootstrapCI_rawoutput.csv'];
cell2csv(filename,outputraw,',');
filename = [input.cropname '_bootstrapCI_percentiles.csv'];
cell2csv(filename,outputCI,',');


