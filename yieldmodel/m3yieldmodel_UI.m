function [modyield] = m3yieldmodel_UI(cropname, datamask, ...
    climatemask, nfert, pfert, kfert, avgpercirr, modelnumber, ...
    errorflag, errormap, globalslopeflag)

% [modyield] = m3yieldmodel_UI(cropname, datamask, ...
%     climatemask, nfert, pfert, kfert, avgpercirr, modelnumber, ...
%     errorflag, errormap, globalslopeflag)
%
% m3yieldmodel_UI will return a modeled yield map based on crop and
% management characteristics.
% 
% v1.0 functional March 2011. Written by Nathan Mueller.
% v1.1 3.23.2011 - added capability to utilize spatial modeling errors
%      (residuals)
%
% model options:
%    modelnumber 1 = Von Liebig logistic model
%    modelnumber 2 = Von Liebig Mitscherlich Baule model
%
% errorflag:
%    errorflag = 1 indicates to use error correction where possible
%    errorflag = 0 no error correction will be used
%    *note* - Errors are observed - modeled yields from the model output.
%    These may account for site-specific variation in seeds, soils, etc.
%    When the errorflag is turned on, this code will use the errors but max
%    out and minimize any yields at the 98th and 2nd percentiles,
%    respectively. This will avoid the situation where you end up modeling
%    a negative yield.
%
% globalslopeflag: options = 1 or 0 (can also use fewer arguments to
%    automatically be set to 0. If the globalslopeflag = 1, the model will
%    force a predictive response for all nutrients (NPK), even in bins
%    where we have not calculated a bin-specific response for a particular
%    nutrient. 
%    

if nargin < 11
    globalslopeflag = 0;
end

% set model choice: VL ELM OR VL MB
switch modelnumber
    case 1
        modelname = 'VL_LM';
    case 2
        modelname = 'VL_MBM';
end

% load yield model output
filestr = [iddstring 'ClimateBinAnalysis/YieldModel/' ...
    cropname '_m3yieldmodeldata_' modelname '.csv'];
MS = ReadGenericCSV(filestr);
disp(['running m3yieldmodel_UI for ' cropname ' using a ' modelname ...
    ' model'])

% check for error flag - if this flag is turned on the function will use
% model errors (residuals) to the output of the function
if errorflag == 1
    disp(['errorflag = 1, will use spatial residuals (error) to adjust '...
        'model output. Maximum yields will be 98th percentile yields, '...
        'minimum yields will be set to 2nd percentile yields.'])
    potpercentstr = '98';
    minpercentstr = '2';
    climspace = '10x10';
    FNS.ClimateSpaceRev = 'P';
    FNS.ClimateSpaceN=10;
    FNS.WetFlag='prec';
    OutputDirBase=[iddstring 'ClimateBinAnalysis/YieldGap'];
    FNS.CropNames = cropname;
    FNS.PercentileForMaxYield=potpercentstr;
    FileName=YieldGapFunctionFileNames_CropName(FNS,OutputDirBase);
    load(FileName);
    maxyield = OS.potentialyield;
    FNS.PercentileForMaxYield=minpercentstr;
    FileName=YieldGapFunctionFileNames_CropName(FNS,OutputDirBase);
    load(FileName);
    minyield = OS.potentialyield;
elseif errorflag == 0
    disp(['errorflag = 0, not using spatial residuals when ' ...
        'calculating yields'])
end
    
% initialize modyield output
modyield = nan(4320,2160);

% cycle through the bins and calculate modeled yields
for bin = 1:100
    
    if bin == 1
        disp(['working on ' cropname ' bins 1-24'])
    elseif bin == 25
        disp(['working on ' cropname ' bins 25-49'])
    elseif bin == 50
        disp(['working on ' cropname ' bins 50-74'])
    elseif bin == 75
        disp(['working on ' cropname ' bins 75-100'])
    end
    
    ii = find((datamask == 1) & (climatemask == bin) ...
        & isfinite(nfert) & isfinite(pfert) & isfinite(kfert));
    
    % make double & select bin area
    irr_bin = double(avgpercirr(ii));
    nfert_bin = double(nfert(ii));
    pfert_bin = double(pfert(ii));
    kfert_bin = double(kfert(ii));
    
    % identify potential and min yields in the bin
    potyieldbin = MS.potential_yield(bin);
    minyieldbin = MS.minimum_yield(bin);
    
    % get b_nut (aka alpha for MB model)
    bnut = MS.b_nut(bin);
    if modelnumber == 2
        alpha = bnut;
    end
    
    % grab the explanatory variable list
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
    % if globalslopeflag = 1, force cb = 1 for NPK
    if globalslopeflag == 1
        if str2num(cb(4)) == 1
            cb = '1111';
        elseif str2num(cb(4)) == 0
            cb = '1110';
        else
            error('problem adjusting for globalslope parameters');
        end
    end
    
    % create "bFitw" - a list of the correct parameters for the model
    bFitw = [];
    tmp = MS.c_N{bin};
    if ~isempty(tmp)
        tmp = str2num(tmp);
        bFitw = [bFitw tmp];
    elseif globalslopeflag == 1 && isempty(tmp)
        tmp = str2num(MS.c_N{101});
        bFitw = [bFitw tmp];
    end
    tmp = MS.c_P2O5{bin};
    if ~isempty(tmp)
        tmp = str2num(tmp);
        bFitw = [bFitw tmp];
    elseif globalslopeflag == 1 && isempty(tmp)
        tmp = str2num(MS.c_P2O5{101});
        bFitw = [bFitw tmp];
    end
    tmp = MS.c_K2O{bin};
    if ~isempty(tmp)
        tmp = str2num(tmp);
        bFitw = [bFitw tmp];
    elseif globalslopeflag == 1 && isempty(tmp)
        tmp = str2num(MS.c_K2O{101});
        bFitw = [bFitw tmp];
    end
    tmp = MS.b_irr{bin};
    if ~isempty(tmp)
        tmp = str2num(tmp);
        bFitw = [bFitw tmp];
    end
    tmp = MS.c_irr{bin};
    if ~isempty(tmp)
        tmp = str2num(tmp);
        bFitw = [bFitw tmp];
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
    
    % now create the right combination of explanatory variables for x
    xtot = [nfert_bin pfert_bin kfert_bin irr_bin];
    x = [];
    for m = 1:4
        if str2num(cb(m)) == 1
            x = [x xtot(:,m)];
        end
    end
    
    % now calculate modY according to the appropriate model (specified
    % by "numnutvars" and "i"
    
    switch numnutvars
        
        case 0
            
            if i == 0
                
                % 0 nutrients and no irr: use weighted mean
                
                tmp = ones(length(yield_bin),1);
                modY = wavg_yield_bin.*tmp;
                cropOS.modyieldmap(ii) = modY;
                
            elseif i == 1
                
                switch modelnumber
                    
                    case 1 % VL ELM: 0 nutrients + irr
                        
                        modY = potyieldbin ...
                            ./ (1 + exp(bFitw(1) - abs(bFitw(2)) ...
                            .* x(:,1)));
                        cropOS.modyieldmap(ii) = modY;
                        
                    case 2 % VL MB: 0 nutrients + irr
                        
                        modY = potyieldbin ...
                            .* (1 - (abs(bFitw(1)) .* ...
                            exp(-abs(bFitw(2)) .* x(:,1))));
                        cropOS.modyieldmap(ii) = modY;
                        
                end
            end
            
        case 1
            
            if i == 0
                
                switch modelnumber
                    
                    case 1 % VL ELM: 1 nutrient, no irr
                        
                        modY = potyieldbin ...
                            ./ (1 + exp(bnut - abs(bFitw(1)) ...
                            .* x(:,1)));
                        cropOS.modyieldmap(ii) = modY;
                        
                    case 2 % VL MB: 1 nutrient, no irr
                        
                        modY = potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(1)) .* x(:,1))));
                        cropOS.modyieldmap(ii) = modY;
                        
                end
                
            elseif i == 1
                
                switch modelnumber
                    
                    case 1 % VL ELM: 1 nutrient + irr
                        
                        modY = min([(potyieldbin ...
                            ./(1 + exp(bnut - abs(bFitw(1)) ...
                            .* x(:,1)))), ...
                            (potyieldbin ...
                            ./(1 + exp(bFitw(2) - abs(bFitw(3)) ...
                            .* x(:,2))))],[],2);
                        cropOS.modyieldmap(ii) = modY;
                        
                    case 2 % VL MB: 1 nutrient + irr
                        
                        modY = min([(potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(1)) .* x(:,1))))), ...
                            (potyieldbin ...
                            .* (1 - (abs(bFitw(2)) .* ...
                            exp(-abs(bFitw(3)) .*x(:,2)))))],[],2);
                        cropOS.modyieldmap(ii) = modY;
                        
                end
            end
            
        case 2
            
            if i == 0
                
                switch modelnumber
                    
                    case 1 % VL ELM: 2 nutrients, no irr
                        
                        modY = min([(potyieldbin ...
                            ./(1 + exp(bnut - abs(bFitw(1)) ...
                            .* x(:,1)))), ...
                            (potyieldbin ...
                            ./(1 + exp(bnut - abs(bFitw(2)) ...
                            .* x(:,2))))],[],2);
                        cropOS.modyieldmap(ii) = modY;
                        
                    case 2 % VL MB: 2 nutrients, no irr
                        
                        modY = min([(potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(1)) .* x(:,1))))), ...
                            (potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(2)) .*x(:,2)))))],[],2);
                        cropOS.modyieldmap(ii) = modY;
                        
                end
                
            elseif i == 1
                
                switch modelnumber
                    
                    case 1 % VL ELM: 2 nutrients + irr
                        
                        modY = min([(potyieldbin ...
                            ./(1 + exp(bnut - abs(bFitw(1)) ...
                            .* x(:,1)))), ...
                            (potyieldbin ...
                            ./(1 + exp(bnut - abs(bFitw(2)) ...
                            .* x(:,2)))), ...
                            (potyieldbin ...
                            ./(1 + exp(bFitw(3) - abs(bFitw(4)) ...
                            .* x(:,3))))],[],2);
                        cropOS.modyieldmap(ii) = modY;
                        
                    case 2 % VL MB: 2 nutrients + irr
                        
                        modY = min([(potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(1)) .* x(:,1))))), ...
                            (potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(2)) .*x(:,2))))), ...
                            (potyieldbin ...
                            .* (1 - (abs(bFitw(3) .* ...
                            exp(-abs(bFitw(4)).*x(:,3))))))],[],2);
                        cropOS.modyieldmap(ii) = modY;
                        
                end
            end
            
        case 3
            
            if i == 0
                
                switch modelnumber
                    
                    case 1 % VL ELM: 3 nutrients, no irr
                        
                        modY = min([(potyieldbin ...
                            ./(1 + exp(bnut - abs(bFitw(1)) ...
                            .* x(:,1)))), ...
                            (potyieldbin ...
                            ./(1 + exp(bnut - abs(bFitw(2)) ...
                            .* x(:,2)))), ...
                            (potyieldbin ...
                            ./(1 + exp(bnut - abs(bFitw(3)) ...
                            .* x(:,3))))],[],2);
                        cropOS.modyieldmap(ii) = modY;
                        
                    case 2 % VL MB: 3 nutrients, no irr
                        
                        modY = min([(potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(1)) .* x(:,1))))), ...
                            (potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(2)) .*x(:,2))))), ...
                            (potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(3)) .*x(:,3)))))],[],2);
                        cropOS.modyieldmap(ii) = modY;
                        
                end
                
            elseif i == 1
                
                switch modelnumber
                    
                    case 1 % VL ELM: 3 nutrients + irr
                        
                        modY = min([(potyieldbin ...
                            ./(1 + exp(bnut - abs(bFitw(1)) ...
                            .* x(:,1)))), ...
                            (potyieldbin ...
                            ./(1 + exp(bnut - abs(bFitw(2)) ...
                            .* x(:,2)))), ...
                            (potyieldbin ...
                            ./(1 + exp(bnut - abs(bFitw(3)) ...
                            .* x(:,3)))), ...
                            (potyieldbin ...
                            ./(1 + exp(bFitw(4) - abs(bFitw(5)) ...
                            .* x(:,4))))],[],2);
                        cropOS.modyieldmap(ii) = modY;
                        
                    case 2 % VL MB: 2 nutrients + irr
                        
                        modY = min([(potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(1)) .* x(:,1))))), ...
                            (potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(2)) .*x(:,2))))), ...
                            (potyieldbin ...
                            .* (1 - (alpha .* ...
                            exp(-abs(bFitw(3)) .*x(:,3))))), ...
                            (potyieldbin ...
                            .* (1 - (abs(bFitw(4) .* ...
                            exp(-abs(bFitw(5)).*x(:,4))))))],[],2);
                        cropOS.modyieldmap(ii) = modY;
                        
                end
            end
    end
    
    if min(modY) < (minyieldbin - .2)
        warning(['min(modY) ' num2str(min(modY)) ' < minyieldbin ' ...
            num2str(minyieldbin) ', ' cropname ' bin ' num2str(bin) ...
            ', cb = ' cb]);
    end
    
    modyield(ii) = modY;
end

% use error correction if errorflag is activated
if errorflag == 1
    disp('finalizing modeled yield using spatially-explicit residuals')
    errormap(isnan(errormap)) = 0;
    % note: subtract the errors b/c the errors were derived as modeled -
    % observed (M3)
    modyield = modyield - errormap;
    % now make sure no place exceeds min or max yields
    modyield(modyield > maxyield) = maxyield(modyield > maxyield);
    modyield(modyield < minyield) = minyield(modyield < minyield);
end