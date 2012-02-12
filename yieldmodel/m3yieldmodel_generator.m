function [cropOS] = m3yieldmodel_generator_irrintmodel(input, ...
    modelnumber, LSQflag)

% [cropOS] = reg_m3yieldmodel_generator_irrintmodel(input, ...
%            modelnumber, LSQflag)
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

slopemultvect = [.5 .75 1 1.5 2];
slopemultvectirr = [.33 .66 1 1.33 1.66];

binrwlist = [];
binyieldlist = [];
binarealist = [];

arealist = [];
cropOS = [];
cropOS.statslist = [];
cropOS.betalist = {};
cropOS.xlist = {};
cropOS.r2map = single(nan(4320,2160));
cropOS.modyieldmap = single(nan(4320,2160));
cropOS.bnutlist = [];
cropOS.potyieldlist = [];
cropOS.minyieldlist = [];

% set model choice: VL LM OR VL MBM
switch modelnumber
    case 1
        modelname = 'VL_LM';
        modelnamelong = 'von Liebig logistic model';
    case 2
        modelname = 'VL_MBM';
        modelnamelong = 'von Liebig Mitscherlich-Baule model';
end


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
                [bFitw,resnorm,rw,exitflag,output] = ...
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
    slopeUBall = [slopeUBN slopeUBP slopeUBK];
    slopeLBall = [slopeLBN slopeLBP slopeLBK];
end


% loop through bins
for bin = 1:max(max(input.ClimateMask))
    
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
    
    if ii > 20
        
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
        
        % assign bin-specific values to fitting function
        assign.binyieldceiling = binyieldceiling;
        assign.bnut = bnut;
        assign.alpha = alpha;
        
        [~] = agmgmt_elm_irrintmodel_nutoneirron(0,0,assign);
        [~] = agmgmt_elm_irrintmodel_nuttwoirron(0,0,assign);
        [~] = agmgmt_elm_irrintmodel_nutthreeirron(0,0,assign);
        [~] = agmgmt_mbm_irrintmodel_nutoneirron(0,0,assign);
        [~] = agmgmt_mbm_irrintmodel_nuttwoirron(0,0,assign);
        [~] = agmgmt_mbm_irrintmodel_nutthreeirron(0,0,assign);
        
        % set up explanatory variable and weights
        xtot = [nfert_bin(:) pfert_bin(:) kfert_bin(:) irr_bin(:)];
        w = area_bin ./ mean(area_bin);
        w = w(:);
        y = yield_bin(:);
        
        % calculated weighted average mean yield for the bin for r2
        % calculations
        tmp = yield_bin .* w;
        wavg_yield_bin = mean(tmp) ./ mean(w);
        
        % initialize variables
        stepflag = 0;
        xlist = {};
        aiclist = [];
        rmselist = [];
        bFitwlist = {};
        rwlist = {};
        
        %%% loop through potential models and find the combination of
        %%% explanatory variables that minimizes error.
        counter = 0;
        
        % examine models with irrigation on (1) and off (0)
        for i = 0:1
            
            % examine models with each combination of nutrients
            for c = 1:7
                
                % binary conversion = this gives us 1s and 0 combos of the
                % different nutrient variables
                cb = dec2bin(c);
                % add missing zeros where necessary
                if length(cb) < 3
                    tmp = 3-length(cb);
                    if tmp == 1;
                        cb = ['0' cb];
                    elseif tmp == 2;
                        cb = ['00' cb];
                    end
                end
                
                % grab the appropriate nutrient variables and create
                % slopeUB/LB vectors
                x = [];
                slopeUBvector = [];
                slopeLBvector = [];
                for m = 1:3
                    if str2num(cb(m)) == 1
                        x = [x xtot(:,m)];
                        slopeUBvector = [slopeUBvector slopeUBall(m)];
                        slopeLBvector = [slopeLBvector slopeLBall(m)];
                    end
                end
                
                % record the number of nutrient variables
                if ~isempty(x)
                    numnutvars = length(x(1,:));
                else
                    numnutvars = 0;
                end
                
                % add irrigation variable if i equals 1. add UB/LB values
                % for b_irr (rainfed potential yield)
                if i == 1
                    x = [x xtot(:,4)];
                    slopeUBvector = [slopeUBvector binyieldceiling];
                    slopeLBvector = [slopeLBvector 0];
                end
                slopeUBvector = double(slopeUBvector);
                slopeLBvector = double(slopeLBvector);
                
                % record x variables of interest; add 0 or 1 at the end to
                % indicate irrigation or no irrigation.
                if i == 0
                    cb = [cb '0'];
                elseif i == 1
                    cb = [cb '1'];
                end
                counter = counter + 1;
                xlist{counter} = cb;
                
                % create and run the appropriate model
                switch numnutvars
                    
                    case 1
                        
                        if i == 0
                            
                            switch modelnumber
                                
                                case 1 % VL ELM: 1 nutrient, no irr
                                    
                                    agmgmt = @(b,x) binyieldceiling ...
                                        ./ (1 + exp(bnut - abs(b(1)) ...
                                        .* x(:,1)));
                                    yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = 1:length(slopemultvect)
                                        sm = slope0.*slopemultvect(m);
                                        beta0 = sm;
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
                                            yield_bin-wavg_yield_bin) ...
                                            .*sqrt(w)).^2);
                                    end
                                    [~,yy] = min(mlist);
                                    if length(yy)>1
                                        yy = yy(1);
                                    end
                                    msew = mlist(yy);
                                    rw = rlist{yy};
                                    bFitw = blist{yy};
                                    
                                case 2 % VL MB: 1 nutrient, no irr
                                    
                                    agmgmt = @(b,x) binyieldceiling ...
                                        .* (1 - (alpha .* ...
                                        exp(-abs(b(1)) .* x(:,1))));
                                    yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = 1:length(slopemultvect)
                                        sm = slope0.*slopemultvect(m);
                                        beta0 = sm;
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
                                            yield_bin-wavg_yield_bin) ...
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
                            
                        elseif i == 1
                            
                            switch modelnumber
                                case 1 % VL ELM: 1 nutrient + irr
                                    
                                    yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt_elm_irrintmodel_nutoneirron(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = 1:length(slopemultvect)
                                        sm = slope0.*slopemultvect(m);
                                        ism = b0irr.*slopemultvectirr(m);
                                        beta0 = [sm ism];
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
                                            yield_bin-wavg_yield_bin) ...
                                            .*sqrt(w)).^2);
                                    end
                                    [~,yy] = min(mlist);
                                    if length(yy)>1
                                        yy = yy(1);
                                    end
                                    msew = mlist(yy);
                                    rw = rlist{yy};
                                    bFitw = blist{yy};
                                    
                                case 2 % VL MB: 1 nutrient + irr
                                    
                                    yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt_mbm_irrintmodel_nutoneirron(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = 1:length(slopemultvect)
                                        sm = slope0.*slopemultvect(m);
                                        ism = b0irr.*slopemultvectirr(m);
                                        beta0 = [sm ism ];
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
                                            yield_bin-wavg_yield_bin) ...
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
                        
                    case 2
                        
                        if i == 0
                            
                            switch modelnumber
                                
                                case 1 % VL ELM: 2 nutrients, no irr
                                    
                                    agmgmt = @(b,x) min([(binyieldceiling ...
                                        ./(1 + exp(bnut - abs(b(1)) ...
                                        .* x(:,1)))), ...
                                        (binyieldceiling ...
                                        ./(1 + exp(bnut - abs(b(2)) ...
                                        .* x(:,2))))],[],2);
                                    yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = 1:length(slopemultvect)
                                        sm = slope0.*slopemultvect(m);
                                        beta0 = [sm sm];
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
                                            yield_bin-wavg_yield_bin) ...
                                            .*sqrt(w)).^2);
                                    end
                                    [~,yy] = min(mlist);
                                    if length(yy)>1
                                        yy = yy(1);
                                    end
                                    msew = mlist(yy);
                                    rw = rlist{yy};
                                    bFitw = blist{yy};
                                    
                                case 2 % VL MB: 2 nutrients, no irr
                                    
                                    agmgmt = @(b,x) min([(binyieldceiling ...
                                        .* (1 - (alpha .* ...
                                        exp(-abs(b(1)) .* x(:,1))))), ...
                                        (binyieldceiling ...
                                        .* (1 - (alpha .* ...
                                        exp(-abs(b(2)) .*x(:,2)))))],[],2);
                                    yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = 1:length(slopemultvect)
                                        sm = slope0.*slopemultvect(m);
                                        beta0 = [sm sm];
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
                                            yield_bin-wavg_yield_bin) ...
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
                            
                        elseif i == 1
                            
                            switch modelnumber
                                
                                case 1 % VL ELM: 2 nutrients + irr
                                    
                                    yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt_elm_irrintmodel_nuttwoirron(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = 1:length(slopemultvect)
                                        sm = slope0.*slopemultvect(m);
                                        ism = b0irr.*slopemultvectirr(m);
                                        beta0 = [sm sm ism];
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
                                            yield_bin-wavg_yield_bin) ...
                                            .*sqrt(w)).^2);
                                    end
                                    [~,yy] = min(mlist);
                                    if length(yy)>1
                                        yy = yy(1);
                                    end
                                    msew = mlist(yy);
                                    rw = rlist{yy};
                                    bFitw = blist{yy};
                                    
                                case 2 % VL MB: 2 nutrients + irr
                                    
                                    yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt_mbm_irrintmodel_nuttwoirron(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = 1:length(slopemultvect)
                                        sm = slope0.*slopemultvect(m);
                                        ism = b0irr.*slopemultvectirr(m);
                                        beta0 = [sm sm ism];
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
                                            yield_bin-wavg_yield_bin) ...
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
                        
                    case 3
                        
                        if i == 0
                            
                            switch modelnumber
                                
                                case 1 % VL ELM: 3 nutrients, no irr
                                    
                                    agmgmt = @(b,x) min([(binyieldceiling ...
                                        ./(1 + exp(bnut - abs(b(1)) ...
                                        .* x(:,1)))), ...
                                        (binyieldceiling ...
                                        ./(1 + exp(bnut - abs(b(2)) ...
                                        .* x(:,2)))), ...
                                        (binyieldceiling ...
                                        ./(1 + exp(bnut - abs(b(3)) ...
                                        .* x(:,3))))],[],2);
                                    yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = slopemultvect
                                        sm = slope0.*m;
                                        beta0 = [sm sm sm];
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
                                            yield_bin-wavg_yield_bin) ...
                                            .*sqrt(w)).^2);
                                    end
                                    [~,yy] = min(mlist);
                                    if length(yy)>1
                                        yy = yy(1);
                                    end
                                    msew = mlist(yy);
                                    rw = rlist{yy};
                                    bFitw = blist{yy};
                                    
                                case 2 % VL MB: 3 nutrients, no irr
                                    
                                    agmgmt = @(b,x) min([(binyieldceiling ...
                                        .* (1 - (alpha .* ...
                                        exp(-abs(b(1)) .* x(:,1))))), ...
                                        (binyieldceiling ...
                                        .* (1 - (alpha .* ...
                                        exp(-abs(b(2)) .*x(:,2))))), ...
                                        (binyieldceiling ...
                                        .* (1 - (alpha .* ...
                                        exp(-abs(b(3)) .*x(:,3)))))],[],2);
                                    yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = 1:length(slopemultvect)
                                        sm = slope0.*slopemultvect(m);
                                        beta0 = [sm sm sm];
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
                                            yield_bin-wavg_yield_bin) ...
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
                            
                        elseif i == 1
                            
                            switch modelnumber
                                
                                case 1 % VL ELM: 3 nutrients + irr
                                   
                                    yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt_elm_irrintmodel_nutthreeirron(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = 1:length(slopemultvect)
                                        sm = slope0.*slopemultvect(m);
                                        ism = b0irr.*slopemultvectirr(m);
                                        beta0 = [sm sm sm ism];
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
                                            yield_bin-wavg_yield_bin) ...
                                            .*sqrt(w)).^2);
                                    end
                                    [~,yy] = min(mlist);
                                    if length(yy)>1
                                        yy = yy(1);
                                    end
                                    msew = mlist(yy);
                                    rw = rlist{yy};
                                    bFitw = blist{yy};
                                    
                                case 2 % VL MB: 3 nutrients + irr
                                    
                                   yw = sqrt(w).*yield_bin;
                                    agmgmtw = @(b,x) double(sqrt(w).*...
                                        agmgmt_mbm_irrintmodel_nutthreeirron(b,x));
                                    
                                    % set beta0 and run regression
                                    blist={};rlist={};mlist=[];r2list=[];
                                    for m = 1:length(slopemultvect)
                                        sm = slope0.*slopemultvect(m);
                                        ism = b0irr.*slopemultvectirr(m);
                                        beta0 = [sm sm sm ism];
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
                                            yield_bin-wavg_yield_bin) ...
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
                end
                
                % store variables
                rmselist(counter) = sqrt(msew);
                bFitwlist{counter} = bFitw;
                rwlist{counter} = rw;
                
            end
        end
        
        % find model with smallest error
        [~,jj] = min(rmselist);
        bFitw = bFitwlist{jj};
        rw = rwlist{jj};
        rmse = rmselist(jj);
        cb = xlist{jj};
        cropOS.xlist{bin} = cb;
        
        % save stuff for global r2 calculation
        binrwlist = [binrwlist(:); rw(:)];
        binyieldlist =[binyieldlist(:); yield_bin(:)];
        binarealist = [binarealist(:); area_bin(:)];
        
        
        %%% calcluate and save modY
        
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
        
        
        % now create the right combination of explanatory variables for x
        x = [];
        for m = 1:4
            if str2num(cb(m)) == 1
                x = [x xtot(:,m)];
            end
        end
        
        
       % now calculate modY according to the appropriate model (specified
       % by "numnutvars" and "i"
        
        switch numnutvars
                
            case 1
                
                if i == 0
                    
                    switch modelnumber
                        
                        case 1 % VL ELM: 1 nutrient, no irr
                            
                            modY = binyieldceiling ...
                                ./ (1 + exp(bnut - abs(bFitw(1)) ...
                                .* x(:,1)));
                            cropOS.modyieldmap(ii) = modY;
                            
                        case 2 % VL MB: 1 nutrient, no irr
                            
                            modY = binyieldceiling ...
                                .* (1 - (alpha .* ...
                                exp(-abs(bFitw(1)) .* x(:,1))));
                            cropOS.modyieldmap(ii) = modY;
                            
                    end
                    
                elseif i == 1
                       
                    switch modelnumber
                        
                        case 1 % VL ELM: 1 nutrient + irr
                            
                            modY = ...
                                agmgmt_elm_irrintmodel_nutoneirron(bFitw,x);
                            
                            cropOS.modyieldmap(ii) = modY;
                            
                        case 2 % VL MB: 1 nutrient + irr
                            
                            modY = ...
                                agmgmt_mbm_irrintmodel_nutoneirron(bFitw,x);
                            
                            cropOS.modyieldmap(ii) = modY;
                            
                    end
                end
                
            case 2
                
                if i == 0
                    
                    switch modelnumber
                        
                        case 1 % VL ELM: 2 nutrients, no irr
                            
                            modY = min([(binyieldceiling ...
                                ./(1 + exp(bnut - abs(bFitw(1)) ...
                                .* x(:,1)))), ...
                                (binyieldceiling ...
                                ./(1 + exp(bnut - abs(bFitw(2)) ...
                                .* x(:,2))))],[],2);
                            cropOS.modyieldmap(ii) = modY;
                            
                        case 2 % VL MB: 2 nutrients, no irr
                            
                            modY = min([(binyieldceiling ...
                                .* (1 - (alpha .* ...
                                exp(-abs(bFitw(1)) .* x(:,1))))), ...
                                (binyieldceiling ...
                                .* (1 - (alpha .* ...
                                exp(-abs(bFitw(2)) .*x(:,2)))))],[],2);
                            cropOS.modyieldmap(ii) = modY;
                            
                    end
                    
                elseif i == 1
                    
                    switch modelnumber
                        
                        case 1 % VL ELM: 2 nutrients + irr
                            
                            modY = ...
                                agmgmt_elm_irrintmodel_nuttwoirron(bFitw,x);
                            
                            cropOS.modyieldmap(ii) = modY;
                            
                        case 2 % VL MB: 2 nutrients + irr
                            
                            modY = ...
                                agmgmt_mbm_irrintmodel_nuttwoirron(bFitw,x);
                            
                            cropOS.modyieldmap(ii) = modY;
                            
                    end
                end
                
            case 3
                
                if i == 0
                    
                    switch modelnumber
                        
                        case 1 % VL ELM: 3 nutrients, no irr
                            
                            modY = min([(binyieldceiling ...
                                ./(1 + exp(bnut - abs(bFitw(1)) ...
                                .* x(:,1)))), ...
                                (binyieldceiling ...
                                ./(1 + exp(bnut - abs(bFitw(2)) ...
                                .* x(:,2)))), ...
                                (binyieldceiling ...
                                ./(1 + exp(bnut - abs(bFitw(3)) ...
                                .* x(:,3))))],[],2);
                            cropOS.modyieldmap(ii) = modY;
                            
                        case 2 % VL MB: 3 nutrients, no irr
                            
                            modY = min([(binyieldceiling ...
                                .* (1 - (alpha .* ...
                                exp(-abs(bFitw(1)) .* x(:,1))))), ...
                                (binyieldceiling ...
                                .* (1 - (alpha .* ...
                                exp(-abs(bFitw(2)) .*x(:,2))))), ...
                                (binyieldceiling ...
                                .* (1 - (alpha .* ...
                                exp(-abs(bFitw(3)) .*x(:,3)))))],[],2);
                            cropOS.modyieldmap(ii) = modY;
                            
                    end
                    
                elseif i == 1
                    
                    switch modelnumber
                        
                        case 1 % VL ELM: 3 nutrients + irr
                            
                            modY = ...
                                agmgmt_elm_irrintmodel_nutthreeirron(bFitw,x);

                            cropOS.modyieldmap(ii) = modY;
                            
                        case 2 % VL MB: 3 nutrients + irr
                            
                            modY = ...
                                agmgmt_mbm_irrintmodel_nutthreeirron(bFitw,x);
                            
                            cropOS.modyieldmap(ii) = modY;
                            
                    end
                end
        end
        
        % calculate r2 from regression residuals
        tmp = yield_bin .* w;
        wavg_yield_bin = mean(tmp) ./ mean(w);
        Rsq = 1-sum(rw.^2)./sum(((yield_bin-wavg_yield_bin).*sqrt(w)).^2);
        
        % calculate residuals and r2 from the modeled yield
        tmp = yield_bin .* area_bin;
        wavg_yield_bin = mean(tmp) ./ mean(area_bin);
        rw2 = (yield_bin - modY).*sqrt(w);
        Rsq2 = 1-sum((rw2).^2)./sum(((yield_bin-wavg_yield_bin).*...
            sqrt(w)).^2);
        
        % save stats, r2 map, & calculate area list for the weighted r2
        % for the crop
        arealist(bin)=sum(area_bin);
        cropOS.betalist{bin} = bFitw(:)';
        cropOS.r2map(ii) = Rsq;
        
        % save all stats %%%%%%%%%%%%%%% ADD MSE BACK IN TO THE STATS LIST
        % AND SAVE BELOW
        cropOS.statslist=[cropOS.statslist; Rsq, Rsq2, msew, sqrt(msew)];
        
    else
        
        disp(['Skipping ' input.cropname ' bin #' num2str(bin) ...
            ', only ' num2str(length(ii)) ' grid cells with ' ...
            'management data.'])
    end
end


% calculate average weighted r2 for the crop
w = arealist ./ sum(arealist);
avgr2 = sum(cropOS.statslist(:,1) .* w(:));
cropOS.avgr2 = avgr2;

% calculate weighted avg global yield
ii = find(isfinite(input.CultivatedArea) ... % cells with crop area
    & isfinite(input.Yield) ... % and yield data (should be same)
    & isfinite(input.potentialyield) ... % PY throws out lowest 5% area
    & isfinite(input.irr) ... % and irrigation data
    & isfinite(input.Nfert) & isfinite(input.Pfert) ...
    & isfinite(input.Kfert) ... % and fertilizer data
    & (input.Ndatatype > 0) & (input.Pdatatype > 0) ...
    & (input.Kdatatype > 0)); % discard problematic fert data (Brazil)
yield = double(input.Yield(ii));
area = double(input.CultivatedArea(ii));
tmp = yield .* area;
mean_yieldw = mean(tmp) ./ mean(area);
clear area yield tmp

% calculate a global r2
w = double(input.CultivatedArea(ii));
SSerr = sum(((cropOS.modyieldmap(ii) - double(input.Yield(ii))).*sqrt(w)).^2);
SStot = sum(((double(input.Yield(ii)) - mean_yieldw).*sqrt(w)).^2);
gRsq = 1 - SSerr ./ SStot;
cropOS.r2global = gRsq;

% % calculate a global rmse - need to double check calculation
% tmp = cropOS.modyieldmap(ii) - cropOS.monfredayieldmap(ii);
% normalizedarea = area ./ mean(area);
% normalizederrors = tmp.*normalizedarea;
% rmseglobal = sqrt(mean(normalizederrors.^2));

% put cropOS components into single & add monfreda yield
cropOS.statslist = single(cropOS.statslist);
cropOS.r2map = single(cropOS.r2map);
cropOS.modyieldmap = single(cropOS.modyieldmap);
ii = isfinite(cropOS.modyieldmap);
a = nan(4320,2160);
a(ii) = input.Yield(ii);
cropOS.monfredayieldmap = single(a);
cropOS.areahamap = input.CultivatedArea;

% calculate error map
cropOS.errormap = (cropOS.modyieldmap - cropOS.monfredayieldmap);

% save output structure to matlab files
mkdir('modeloutput');
eval(['cd modeloutput'])
cropOS.cropname = input.cropname;
cropOS.processingdate = date;
cropOS.modelversion = input.modelversion;
csdim = sqrt(double(max(max(input.ClimateMask))));
climspace = [num2str(csdim) 'x' num2str(csdim)];
eval(['save ' input.cropname 'OS_m3yield_' ...
    modelname '_' climspace ' cropOS']);

% output modeled vs observed yield plot
X = double(cropOS.monfredayieldmap(ii));
Y = double(cropOS.modyieldmap(ii));
areas = double(cropOS.areahamap(ii));
maxyield = max(Y);%max(max(X),max(Y));
jj = find(X > maxyield);
X(jj) = [];
Y(jj) = [];
areas(jj) = [];
tmp = maxyield./50;
binedges = 0:tmp:maxyield;
[jp,xbins,ybins]= GenerateJointDist(X,Y,binedges,binedges,areas./1000);
figure;
set(gcf,'renderer','zbuffer');
cs=surface(xbins,ybins,jp.');
axis([0 maxyield 0 maxyield]);
colorbar;
mapp = finemap('nmfireleftskew-white','','');
colormap(mapp);
shading flat
ylabel([cropOS.cropname ' modeled yield (t/ha)']);
xlabel([cropOS.cropname ' M3 yield (t/ha)']);
tmp = colorbar('peer',gca);
set(get(tmp,'ylabel'),'String', 'Mha per joint distribution');
hold on
x = 0:max(max(X),max(Y));
y = x;
plot3(x,y,ones(length(x)).*10000,'color','blue')
% [bFitw,sew_b,msew] =  lscov(X,Y(:),areas(:));
% y = bFitw(1).*x;
% plot3(x,y,ones(length(x)).*10000,'color','red')
title([cropOS.cropname ': modeled vs M3 yields, model ' modelname '_BF']);
OutputFig('Force');


%%% EXPORT MODEL DATA IN CSV %%%
output = {};

output{1,1} = 'climate bin';
for c = 1:100;
    output{c+1,1} = c;
end
output{102,1} = 'global';

output{1,2} = 'min GDD';
for c = 1:100;
    output{c+1,2} = input.CDS(1,c).GDDmin;
end

output{1,3} = 'max GDD';
for c = 1:100;
    output{c+1,3} = input.CDS(1,c).GDDmax;
end

output{1,4} = 'min annual prec';
for c = 1:100;
    output{c+1,4} = input.CDS(1,c).Precmin;
end

output{1,5} = 'max annual prec';
for c = 1:100;
    output{c+1,5} = input.CDS(1,c).Precmax;
end

output{1,6} = 'yield ceiling';
for c = 1:100;
    output{c+1,6} = cropOS.potyieldlist(c);
end
output{102,6} = potyieldglobal;

output{1,7} = 'yield floor';
for c = 1:100;
    output{c+1,7} = cropOS.minyieldlist(c);
end
output{102,7} = minyieldglobal;

output{1,8} = 'explanatory variable list';
for c = 1:length(cropOS.xlist)
    output{c+1,8} = cropOS.xlist{c};
end

output{1,9} = 'b_nut';
for c = 1:length(cropOS.bnutlist);
    output{c+1,9} = cropOS.bnutlist(c);
end
switch modelnumber
    case 1
        output{102,9} = bnutglobal;
    case 2
        output{102,9} = alphaglobal;
end

output{1,10} = 'c_N';
for c = 1:length(cropOS.xlist)
    cb = cropOS.xlist{c};
    if str2num(cb(1)) == 1
        bFitw = cropOS.betalist{c};
        output{c+1,10} = abs(bFitw(1));
    end
end
output{102,10} = slopeGN;

output{1,11} = 'c_P2O5';
for c = 1:length(cropOS.xlist)
    cb = cropOS.xlist{c};
    bFitw = cropOS.betalist{c};
    if str2num(cb(2)) == 1
        othernuts = 0;
        if str2num(cb(1)) == 1
            othernuts = 1;
        end
        switch othernuts
            case 0
                output{c+1,11} = abs(bFitw(1));
            case 1
                output{c+1,11} = abs(bFitw(2));
        end
    end
end
output{102,11} = slopeGP;

output{1,12} = 'c_K2O';
for c = 1:length(cropOS.xlist)
    cb = cropOS.xlist{c};
    bFitw = cropOS.betalist{c};
    if str2num(cb(3)) == 1
        othernuts = 0;
        for k = 1:2
            if str2num(cb(k)) == 1
                othernuts = othernuts + 1;
            end
        end
        switch othernuts
            case 0
                output{c+1,12} = abs(bFitw(1));
            case 1
                output{c+1,12} = abs(bFitw(2));
            case 2
                output{c+1,12} = abs(bFitw(3));
        end
    end
end
output{102,12} = slopeGK;

output{1,13} = 'yc_rf';
for c = 1:length(cropOS.xlist)
    cb = cropOS.xlist{c};
    bFitw = cropOS.betalist{c};
    if str2num(cb(4)) == 1
        othernuts = 0;
        for k = 1:3
            if str2num(cb(k)) == 1
                othernuts = othernuts + 1;
            end
        end
        switch othernuts
            case 0
                output{c+1,13} = bFitw(1);
            case 1
                output{c+1,13} = bFitw(2);
            case 2
                output{c+1,13} = bFitw(3);
            case 3
                output{c+1,13} = bFitw(4);
        end
    end
end

output{1,14} = 'bin_rmse';
output{1,15} = 'bin_r2';
for c = 1:100;
    output{c+1,14} = cropOS.statslist(c,4);
    output{c+1,15} = cropOS.statslist(c,1);
end

output{1,16} = 'model info';
output{2,16} = [input.cropname ' ' modelnamelong ' model'];
switch LSQflag
    case 0
        tmp = 'nlinfit';
    case 1
        tmp = 'lsqcurvefit';
end
output{3,16} = ['optimization done with MATLAB function ' tmp];
output{4,16} = ['processed on ' date];
output{5,16} = ['version ' input.modelversion];
output{6,16} = [input.cropname ' GDD base temp = ' input.GDDBaseTemp];

cell2csv([input.cropname '_m3yieldmodeldata_' modelname '.csv'] ...
    ,output,',');

cd ../

