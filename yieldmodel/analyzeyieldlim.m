function [yieldlim, dN, dNquality, dP, dPquality, dK, dKquality, ...
    dI, dIquality] = analyzeyieldlim(cropname, modelnumber, ...
    desiredyield, potentialyield, yieldmap, datamask, climatemask, ...
    nfert, pfert, kfert, avgpercirr, errorflag, errormap, adjCflag)

% [yieldlim, dN, dNquality, dP, dPquality, dK, dKquality, ...
%     dI, dIquality] = analyzeyieldlim(cropname, modelnumber, ...
%     desiredyield, potentialyield, yieldmap, datamask, climatemask, ...
%     nfert, pfert, kfert, avgpercirr, errorflag, errormap, adjCflag)
%
%                      %%%%%%%%%%%%%%%%%%%%%%
%                      % NOTES ON VARIABLES %
%                      %%%%%%%%%%%%%%%%%%%%%%
%
% OUTPUTS
%
%   - yieldlim is a categorical map of yield-limiting factors.
%        - code 1 = nutrient limited
%        - code 2 = nutrient + water (irrigation) limited
%        - code 3 = water (irrigation) limited
%        - code 4 = desired yield (desiredyield) < observed yield
%                   (yieldmap)
%        - code 5 = desired yield (desiredyield) > potential yield
%                   (potentialyield) (note: this could include areas that
%                   would otherwise be labeled as code 4)
%   - dNPKI = delta inputs necessary to achieve the desiredyield. this
%             can be negative when less nutrients are required to
%             achieve a desired yield than what is use. NOTE: you cannot
%             estimate a dNPKI for a yield value above the asymptote (98th
%             percentile yields).
%   - dNPKIquality = the quality of the delta nutrient projection
%        - code 1 = projected change is from a bin-specific coefficient for
%                   that particular input
%        - code 2 = projected change is from a global  or a Ymax-normalized 
%                   coefficient (if adjCflag = 1) for that particular input
%                   (note: we only revert to global slopes for nutrients,
%                   for irrigation we just don't estimate a response if
%                   there is no coefficient - this is code 3)
%        - code 3 = no estimated irrigation response for this bin
%
% INPUTS
%
%   - cropname: can be any one of the 17 crops modeled (this should be a
%         lowercase string with no spaces), however yield models perform
%         much better for some crops than others. please check r2s and
%         errors before running.
%   - modelnumber: von Liebig logistic model (VL_LM) = 1, von Liebig
%         Mitscherlich-Baule model (VL_MBM) = 2 NOTE: the
%         Mitscherlich-Baule model generally performs slightly better ...
%         if you are unsure which model to use - use this one!
%   - desiredyield = the yield you would like to achieve - this can come in
%         two forms: 1) it can be the percent change in yield you would
%         like to analyze (e.g. 10, 20, 50 = a 10%, 20%, 50% increase over
%         current yields) or 2) it can be a map of the yield you would like
%         to obtain (i.e. a map of 75th percentile yields)
%   - potentialyield: a map defining potential yields (such as 95th
%         percentile yields in each climate bin) - this defines code 5 in 
%         the yieldlim map
%   - datamask: a logical mask defining "good areas" - probably just the
%         intersection of good data for yields, inputs, and climate (this
%         is mostly a sanity check ... being careful)
%   - climatemask: the crop-specific climate bin map
%   - nfert, pfert, kfert: fertilizer application rates from the M3
%         fertilizer dataset (in kg/ha) - try the function "getfertdata" to
%         quickly load these maps for a given crop
%   - avgpercirr: average percent irrigated area over the growing season
%         from the MIRCA2000 dataset
%   - errorflag: if this flag is turned on, only grid cells where the
%         observed (Monfreda) yield > desiredyield are categorized as code
%         4 in the yieldlim map (the alternative is that places where
%         modeledyield > desired yield get set as number 4)
%   - errormap: the difference between modeled and observed yields (modeled
%         minus observed)
%

% check input variables
switch modelnumber
    case 1
        modelname = 'VL_LM';
    case 2
        modelname = 'VL_MBM';
end
if nargin < 12
errorflag = 0;
    adjCflag = 0;
elseif nargin < 14
    adjCflag = 0;
end
if errorflag == 0
    warning('no error correction enabled');
elseif errorflag == 1
    disp(['using spatially-explicit errors to correct definition of ' ...
        'areas achieving the desired yield']);
end
if adjCflag == 1
    % if adjCflag = 1, normalize the response coefficients for "missing
    % bins" using the Ymax within a bin
    disp(['using regression-adj "c" coefficients for bins' ...
        'lacking bin-specific coefficients for particular inputs']);
    filestr = [iddstring 'ClimateBinAnalysis/YieldModel/cvsYmax_' ...
        modelname '.csv'];
    CS = ReadGenericCSV(filestr);
    ii = strmatch(cropname,CS.cropname);
    N_creg_slope = str2num(CS.N_slope{ii});
    N_creg_yint = str2num(CS.N_y_int{ii});
    N_creg_r2 = str2num(CS.N_r2{ii});
    N_creg_p = str2num(CS.N_p{ii});
    disp(['the N regression between Ymax and Cs has an r2 of ' ...
        num2str(N_creg_r2) ' and a p-value of ' num2str(N_creg_p)]);
    P_creg_slope = CS.P_slope(ii);
    P_creg_yint = CS.P_y_int(ii);
    P_creg_r2 = CS.P_r2(ii);
    P_creg_p = CS.P_p(ii);
    disp(['the P2O5 regression between Ymax and Cs has an r2 of ' ...
        num2str(P_creg_r2) ' and a p-value of ' num2str(P_creg_p)]);
    K_creg_slope = str2num(CS.K_slope{ii});
    K_creg_yint = str2num(CS.K_y_int{ii});
    K_creg_r2 = str2num(CS.K_r2{ii});
    K_creg_p = str2num(CS.K_p{ii});
    disp(['the K regression between Ymax and Cs has an r2 of ' ...
        num2str(K_creg_r2) ' and a p-value of ' num2str(K_creg_p)]);
    clear CS
else
    disp(['using global average response "c" coefficient for bins ' ...
        'lacking bin-specific coefficients for particular inputs']);
end

% create desired yield map if necessary
if length(desiredyield) == 1
    desiredyieldstr = num2str(desiredyield);
    desiredyield = 1 + (desiredyield./100);
    desiredyield = yieldmap .* desiredyield;
    disp(['analyzing management factors limiting a ' desiredyieldstr ...
        '% increase in ' cropname ' yield']);
else
    disp(['analyzing management factors limiting the change in ' ...
        cropname ' yield specified by the "desiredyield" matrix'])
end

% load model info (VL LM OR VL MBM)
filestr = [iddstring 'ClimateBinAnalysis/YieldModel/' ...
    cropname '_m3yieldmodeldata_' modelname '.csv'];
MS = ReadGenericCSV(filestr);

% initialize yieldlim map output
yieldlim = nan(4320,2160);
dN = nan(4320,2160);
dNquality = nan(4320,2160);
dP = nan(4320,2160);
dPquality = nan(4320,2160);
dK = nan(4320,2160);
dKquality = nan(4320,2160);
dI = nan(4320,2160);
dIquality = nan(4320,2160);

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

    yield_bin = double(yieldmap(ii));
    potentialyield_bin = double(potentialyield(ii));
    irr_bin = double(avgpercirr(ii));
    nfert_bin = double(nfert(ii));
    pfert_bin = double(pfert(ii));
    kfert_bin = double(kfert(ii));
    desiredyield_bin = double(desiredyield(ii));
    error_bin = double(errormap(ii));
    
    % identify potential and min yields in the bin
    potyieldbin = MS.potential_yield(bin);
    minyieldbin = MS.minimum_yield(bin);
    
    % initialize the lim_bin codes and nutrient plus vectors
    lim_bin = zeros(length(yield_bin),1);
    dN_bin = zeros(length(yield_bin),1);
    dNQ_bin = zeros(length(yield_bin),1);
    dP_bin = zeros(length(yield_bin),1);
    dPQ_bin = zeros(length(yield_bin),1);
    dK_bin = zeros(length(yield_bin),1);
    dKQ_bin = zeros(length(yield_bin),1);
    dI_bin = zeros(length(yield_bin),1);
    dIQ_bin = zeros(length(yield_bin),1);
    
    %     nfertplus_bin = [];
    %     kfertplus_bin = [];
    %     pfertplus_bin = [];
    %     irrplus_bin = [];
    
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
    
    %%% cycle through cb, look at each individual functional form
    
    % examine for nitrogen limitation
    if str2num(cb(1)) == 1
        bFitw = str2num(MS.c_N{bin});
        bininfo = 1;
        dNQ_bin = ones(length(dNQ_bin),1);
    elseif adjCflag == 1
        bFitw = (N_creg_slope.*potyieldbin) + N_creg_yint;
        bininfo = 0;
    else
        bFitw = str2num(MS.c_N{101});
        bininfo = 0;
        dNQ_bin = ones(length(dNQ_bin),1)+1;
    end
    switch modelnumber
        case 1 % VL LM
            nfertplus_bin = (log((potyieldbin ./ ...
                desiredyield_bin) - 1) - bnut) ./ - bFitw;
        case 2 % VL MBM
            nfertplus_bin = log((1 - (desiredyield_bin ./ ...
                potyieldbin)) ./ bnut) ./ -bFitw;
    end
    dN_bin = nfertplus_bin - nfert_bin;
    jj = find(imag(dN_bin)~=0);
    dN_bin(jj) = NaN;
    dNQ_bin(jj) = 4;
    if bininfo == 1
        lim_bin(nfertplus_bin > nfert_bin) = 1;
    end
    
    % examine for phosphorus limitation
    if str2num(cb(2)) == 1
        bFitw = str2num(MS.c_P2O5{bin});
        bininfo = 1;
        dPQ_bin = ones(length(dPQ_bin),1);
    elseif adjCflag == 1
        bFitw = (P_creg_slope.*potyieldbin) + P_creg_yint;
    else
        bFitw = str2num(MS.c_P2O5{101});
        bininfo = 0;
        dPQ_bin = ones(length(dPQ_bin),1)+1;
    end
    switch modelnumber
        case 1 % VL LM
            pfertplus_bin = (log((potyieldbin ./ ...
                desiredyield_bin) - 1) - bnut) ./ - bFitw;
        case 2 % VL MBM
            pfertplus_bin = log((1 - (desiredyield_bin ./ ...
                potyieldbin)) ./ bnut) ./ -bFitw;
    end
    dP_bin = pfertplus_bin - pfert_bin;
    jj = find(imag(dP_bin)~=0);
    dP_bin(jj) = NaN;
    dPQ_bin(jj) = 4;
    if bininfo == 1
        lim_bin(pfertplus_bin > pfert_bin) = 1;
    end
    
    % examine for potash limitation
    if str2num(cb(3)) == 1
        bFitw = str2num(MS.c_K2O{bin});
        bininfo = 1;
        dKQ_bin = ones(length(dKQ_bin),1);
    elseif adjCflag == 1
        bFitw = (K_creg_slope.*potyieldbin) + K_creg_yint;
    else
        bFitw = str2num(MS.c_K2O{101});
        bininfo = 0;
        dKQ_bin = ones(length(dKQ_bin),1)+1;
    end
    switch modelnumber
        case 1 % VL LM
            kfertplus_bin = (log((potyieldbin ./ ...
                desiredyield_bin) - 1) - bnut) ./ - bFitw;
        case 2 % VL MBM
            kfertplus_bin = log((1 - (desiredyield_bin ./ ...
                potyieldbin)) ./ bnut) ./ -bFitw;
    end
    dK_bin = kfertplus_bin - kfert_bin;
    jj = find(imag(dK_bin)~=0);
    dK_bin(jj) = NaN;
    dKQ_bin(jj) = 4;
    if bininfo == 1
        lim_bin(kfertplus_bin > kfert_bin) = 1;
    end
    
    % examine for water limitation: this is now the same linear plateau
    % model regardless of whether you are using MBM or LM for nutrient
    % responses
    if str2num(cb(4)) == 1
        bFitw(1) = str2num(MS.b_irr{bin});
        bFitw(2) = str2num(MS.c_irr{bin});
        %         switch modelnumber
        %             case 1 % VL ELM
        %                 irrplus_bin = (log((potyieldbin ./ ...
        %                     desiredyield_bin) - 1) - bFitw(1)) ./ - bFitw(2);
        %             case 2 % VL MB
        %                 irrplus_bin = log((1 - (desiredyield_bin ./ ...
        %                     potyieldbin)) ./ bFitw(1)) ./ -bFitw(2);
        %         end
        % use the linear plateau model to calculate irr_plus
        % (Y - abs(b_irr - c_irr)) / c_irr = x
        irrplus_bin = (desiredyield_bin - abs(bFitw(1) - bFitw(2))) ./ ...
            bFitw(2);
        % record water and nutrient limited areas
        jj = find((irrplus_bin > irr_bin) & (lim_bin == 1));
        lim_bin(jj) = 2;
        % record just water limited areas
        jj = find((irrplus_bin > irr_bin) & (lim_bin == 0));
        lim_bin(jj) = 3;
        % record change in % irrigated areas
        dI_bin = irrplus_bin - irr_bin;
        jj = find(imag(dI_bin)~=0);
        dI_bin(jj) = NaN;
        dIQ_bin = ones(1,length(dIQ_bin));
        dIQ_bin(jj) = 4;
    else
        dI_bin = zeros(length(dI_bin),1);
        dIQ_bin = ones(length(dIQ_bin),1)+2;
    end
    
    % place lim_bin into yieldlim map
    if errorflag == 1
        lim_bin(desiredyield_bin < (yield_bin - error_bin)) = 4;
        lim_bin(desiredyield_bin > potentialyield_bin) = 5;
        % note: no error-correction for the "5" scenario right now
        % lim_bin((desiredyield_bin - error_bin) > potentialyield_bin) = 5;
    elseif errorflag == 0
        lim_bin(desiredyield_bin < yield_bin) = 4;
        lim_bin(desiredyield_bin > potentialyield_bin) = 5;
    end
    yieldlim(ii) = lim_bin;
    dN(ii) = dN_bin;
    dNquality(ii) = dNQ_bin;
    dP(ii) = dP_bin;
    dPquality(ii) = dPQ_bin;
    dK(ii) = dK_bin;
    dKquality(ii) = dKQ_bin;
    dI(ii) = dI_bin;
    dIquality(ii) = dIQ_bin;
end


% old code:
%     if errorflag == 1
%         jj = find((desiredyield_bin - error_bin) > potentialyield_bin);
%         lim_bin(jj) = 4;
%     elseif errorflag == 0
%         jj = find(desiredyield_bin > potentialyield_bin | yield_bin ...
%             > desiredyield_bin);
%         lim_bin(jj) = 4;
%     end
