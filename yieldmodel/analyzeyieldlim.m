function [yieldlim, dN, dNquality, dP, dPquality, dK, dKquality, ...
    dI, dIquality] = analyzeyieldlim(cropname, ...
    modelnumber, desiredyield, potentialyield, yieldmap, datamask, ...
    climatemask, nfert, pfert, kfert, avgpercirr, errorflag, errormap, ...
    adjCflag, scenario)

% [yieldliam, dN, dNquality, dP, dPquality, dK, dKquality, ...
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
%   - scenario: decide how to close yield gaps ... options are ...
%         (1) 'fixednutrients' - hold nutrients constant and see if yield
%              gaps can be closed
%         (2) 'fixedirrigation' - hold irrigation constant and see if yield
%              gaps can be closed
%         (3) 'minimumdistance' - use the minimum distance in input vs.
%              irrigation space to estimate changes in inputs to close
%              yield gaps
%         (4 or 5?) 'minimumirrigation' OR 'minimumnutrients'??? Nathan has
%              the logic developed for these scenarios but they would not
%              be necessary for the intensification paper
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
    N_creg_slope = CS.N_slope(ii);
    N_creg_yint = CS.N_y_int(ii);
    N_creg_r2 = CS.N_r2(ii);
    N_creg_p = CS.N_p(ii);
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

% if we are running the mindistance scenario, we need to get the
% normalization constant for nitrogen
switch scenario
    case 'minimumdistance'
        Nmax95 = getcropfertrate(cropname, 'N', .95, datamask);
end

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
    potyieldbin = MS.yield_ceiling(bin);
    minyieldbin = MS.yield_floor(bin);
    
    % get rainfed potential yield
    yc_rf_bin = str2num(MS.yc_rf{bin});
    
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
    
    if bin == 71
        disp('check')
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% SWITCH ANALYSIS BASED ON THE SCENARIO %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    switch scenario
        
        case 'fixedirrigation' % CLOSING YIELD GAPS WITH NUTRIENTS ONLY
            
            % for fixed irrigation, we calculate the desired_ymodnutbin
            % given the desired yield and constant irrigation.
            
            % create desired ymodnutbin for backcalculting nutrient
            % requirements before adjusting downward for irrigation
            % limitation
            desired_ymodnutbin = desiredyield_bin;
            if str2num(cb(4)) == 1
                kk = desiredyield_bin > yc_rf_bin;
                desired_ymodnutbin(kk) = ((desiredyield_bin(kk) - ...
                    yc_rf_bin) ./ irr_bin(kk)) + yc_rf_bin;
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
                        desired_ymodnutbin) - 1) - bnut) ./ - bFitw;
                case 2 % VL MBM
                    nfertplus_bin = log((1 - (desired_ymodnutbin ./ ...
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
                        desired_ymodnutbin) - 1) - bnut) ./ - bFitw;
                case 2 % VL MBM
                    pfertplus_bin = log((1 - (desired_ymodnutbin ./ ...
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
                        desired_ymodnutbin) - 1) - bnut) ./ - bFitw;
                case 2 % VL MBM
                    kfertplus_bin = log((1 - (desired_ymodnutbin ./ ...
                        potyieldbin)) ./ bnut) ./ -bFitw;
            end
            dK_bin = kfertplus_bin - kfert_bin;
            jj = find(imag(dK_bin)~=0);
            dK_bin(jj) = NaN;
            dKQ_bin(jj) = 4;
            if bininfo == 1
                lim_bin(kfertplus_bin > kfert_bin) = 1;
            end
            
            % examine for irrigation limitation
            
            if str2num(cb(4)) == 1
                
                % by definition, there is no change in irrigation ...
                irrplus_bin = irr_bin;
                % ... except in places where the desired yield is under the
                % rainfed yield ceiling
                irrplus_bin(desiredyield_bin < yc_rf_bin) = 0;
                
                % record water and nutrient limited areas
                jj = find((desiredyield_bin > yc_rf_bin) & (lim_bin == 1));
                %                 jj = find((irrplus_bin > irr_bin) & (lim_bin == 1));
                lim_bin(jj) = 2;
                
                dI_bin = irrplus_bin - irr_bin;
                jj = find(imag(dI_bin)~=0);
                dI_bin(jj) = NaN;
                dIQ_bin = ones(1,length(dIQ_bin));
                dIQ_bin(jj) = 4;
            else
                dI_bin = zeros(length(dI_bin),1);
                dIQ_bin = ones(length(dIQ_bin),1)+2;
            end
            
        case 'fixednutrients' % CLOSING YIELD GAPS WITH IRRIGATION ONLY
            
            % for fixed nutrients, we calculate the current yields on
            % irrigated lands (current_ymodnutbin), then determine the
            % change in %IRR to achieve the desired yield. you can only
            % close yield gaps with %IRR only when current_ymodnutbin >=
            % the desiredyield.
            
            % places without irrigation responses parameterized cannot
            % close yield gaps through irrigation only
            
            % nutrients are fixed to the amount needed to attain
            % current_ymodnutbin
            
            % calculate current_ymodnutbin
            current_ymodnutbin = yield_bin;
            if str2num(cb(4)) == 1
                kk = yield_bin > yc_rf_bin;
                current_ymodnutbin(kk) = ((yield_bin(kk) - ...
                    yc_rf_bin) ./ irr_bin(kk)) + yc_rf_bin;
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
                        current_ymodnutbin) - 1) - bnut) ./ - bFitw;
                case 2 % VL MBM
                    nfertplus_bin = log((1 - (current_ymodnutbin ./ ...
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
                        current_ymodnutbin) - 1) - bnut) ./ - bFitw;
                case 2 % VL MBM
                    pfertplus_bin = log((1 - (current_ymodnutbin ./ ...
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
                        current_ymodnutbin) - 1) - bnut) ./ - bFitw;
                case 2 % VL MBM
                    kfertplus_bin = log((1 - (current_ymodnutbin ./ ...
                        potyieldbin)) ./ bnut) ./ -bFitw;
            end
            dK_bin = kfertplus_bin - kfert_bin;
            jj = find(imag(dK_bin)~=0);
            dK_bin(jj) = NaN;
            dKQ_bin(jj) = 4;
            if bininfo == 1
                lim_bin(kfertplus_bin > kfert_bin) = 1;
            end
            
            % examine for irrigation limitation
            if str2num(cb(4)) == 1
                
                % calculate irrplus_bin to achieve desired yields
                irrplus_bin = (desiredyield_bin - yc_rf_bin) ./ ...
                    (current_ymodnutbin - yc_rf_bin);
                
                % in places where the desired yield is under rainfed yield
                % ceiling we don't predict any irrigation needed
                irrplus_bin(desiredyield_bin <= yc_rf_bin) = 0;
                
                % in places where the modyieldmap (yield_bin) is < the
                % rainfed yield ceiling and is < the desired yield, we
                % can't reach the desired yield by changing irrigation. in
                % these cases just make dI NaNs.
                irrplus_bin((yield_bin < yc_rf_bin) & ...
                    (yield_bin < desiredyield_bin)) = NaN;
                
                % record water and nutrient limited areas
                jj = find((desiredyield_bin > yc_rf_bin) & (lim_bin == 1));
                %  jj = find((irrplus_bin > irr_bin) & (lim_bin == 1));
                lim_bin(jj) = 2;
                
                dI_bin = irrplus_bin - irr_bin;
                jj = find(imag(dI_bin)~=0);
                dI_bin(jj) = NaN;
                dIQ_bin = ones(1,length(dIQ_bin));
                dIQ_bin(jj) = 4;
            else
                dI_bin = nan(length(dI_bin),1);
                dIQ_bin = ones(length(dIQ_bin),1)+2;
            end
            
        case 'minimumdistance' % CLOSING YIELD GAPS USING THE MIN DISTANCE
            % IN NORMALIZED NUTRIENT VS IRRIGATION SPACE
            
            % for minimum distance, we'll find the constant desired yield
            % contour in nutrient x irrigation space, then look at the
            % minimum distance to get from our current input combination to
            % the desired yield contour. (note: we normalize the nutrient
            % axis to accomplish this)
            
            % only build the contour if we have an irrigation response for
            % this bin
            
            if str2num(cb(4)) == 1
                
                % calculate current_ymodnutbin - need this to determine
                % "effective" amount of current nutrients needed to sustain
                % current yields
                current_ymodnutbin = yield_bin;
                kk = (yield_bin > yc_rf_bin) & (irr_bin > 0); %%%% ADD HERE THAT IRR_BIN MUST BE > 0?
                current_ymodnutbin(kk) = ((yield_bin(kk) - ...
                    yc_rf_bin) ./ irr_bin(kk)) + yc_rf_bin;
                
                % get current effective N rate (since it will only exactly
                % equal the input amount where N is the limiting nutrient)
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
                        eff_nfert_current = (log((potyieldbin ./ ...
                            current_ymodnutbin) - 1) - bnut) ./ - bFitw;
                    case 2 % VL MBM
                        eff_nfert_current = log((1 - ...
                            (current_ymodnutbin ./ potyieldbin)) ./ ...
                            bnut) ./ -bFitw;
                end
                
                % normalize the effective nitrogen application rate vector
                eff_nfert_current_norm = eff_nfert_current./Nmax95;
                
                % build NxIRR space in order to get contour
                b = [bFitw, yc_rf_bin];
                bnut = MS.b_nut(bin);
                assign.binyieldceiling = potyieldbin;
                % assign fixed parameters
                switch modelnumber
                    case 1 % VL LM
                        assign.bnut = bnut;
                        [~]=agmgmt_elm_irrintmodel_nutoneirron(0,0,assign);
                    case 2 % VL MBM - note: I am sloppy w/ bnut/alpha
                        assign.alpha = bnut;
                        [~]=agmgmt_mbm_irrintmodel_nutoneirron(0,0,assign);
                end
                        
                % run for N/I values
                ymod = nan(101,101);
                nlist = 0:2:800;
                ilist = 0:.01:1;
                for n = 1:length(nlist)
                    for i = 1:length(ilist)
                        x(1) = nlist(n);
                        x(2) = ilist(i);
                        tmp = agmgmt_mbm_irrintmodel_nutoneirron(b,x);
                        ymod(n,i) = tmp;
                    end
                end
                
%                 % draw surface plot of response
%                 mesh(ilist,nlist,ymod)
%                 xlabel('proportion of grid cell area irrigated');
%                 ylabel('nitrogen application rate (kg/ha)');
%                 zlabel([cropname ' yield (t/ha)']);
%                 zlim([0 floor(max(max(ymod))+2)])
                
                % add constant yield value line
                % hold on
                udyb = unique(desiredyield_bin);
                [contmatrix, conthandle] = contour3(ilist,nlist, ...
                    ymod,[udyb,udyb]);
                contmatrix = contmatrix(:,2:length(contmatrix(1,:)));
                
                % calculate minimum distance to the desired yield at that
                % grid cell
                eff_nfert_desired = nan(length(eff_nfert_current),1);
                irrplus_bin = nan(length(eff_nfert_current),1);
                for q = 1:length(eff_nfert_current)
                   
%                     disp(num2str(q))
%                     dy = desiredyield_bin(q);
%                     [contmatrix, conthandle] = contour3(ilist,nlist, ...
%                         ymod,[dy,dy]);
%                     contmatrix = contmatrix(:,2:length(contmatrix(1,:)));
                     
                    Ncurrent = eff_nfert_current(q);
                    Icurrent = irr_bin(q);
                    Nnormconstant = Nmax95;
                    
                    Idistances = contmatrix(1,:);
                    Ndistances = contmatrix(2,:);
                    Ndist_norm = Ndistances ./ Nnormconstant;
                    Ncurr_norm = Ncurrent ./ Nnormconstant;
                    distancevector = sqrt((Ndist_norm - Ncurr_norm).^2 + ...
                        (Idistances - Icurrent).^2);
                    [tmp,mm] = min(distancevector);
                    minvals = contmatrix(:,mm);
                   
                    irrplus_bin(q) = minvals(1);
                    eff_nfert_desired(q) = minvals(2);
                end
                close all
            end
            
            % create desired ymodnutbin for backcalculting nutrient
            % requirements before adjusting downward for irrigation
            % limitation. this is the same code as for fixed irrigation,
            % but here we are utilizing our new irrplus_bin values
            desired_ymodnutbin = desiredyield_bin;
            if str2num(cb(4)) == 1
                kk = desiredyield_bin > yc_rf_bin;
                desired_ymodnutbin(kk) = ((desiredyield_bin(kk) - ...
                    yc_rf_bin) ./ irrplus_bin(kk)) + yc_rf_bin;
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
                        desired_ymodnutbin) - 1) - bnut) ./ - bFitw;
                case 2 % VL MBM
                    nfertplus_bin = log((1 - (desired_ymodnutbin ./ ...
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
                        desired_ymodnutbin) - 1) - bnut) ./ - bFitw;
                case 2 % VL MBM
                    pfertplus_bin = log((1 - (desired_ymodnutbin ./ ...
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
                        desired_ymodnutbin) - 1) - bnut) ./ - bFitw;
                case 2 % VL MBM
                    kfertplus_bin = log((1 - (desired_ymodnutbin ./ ...
                        potyieldbin)) ./ bnut) ./ -bFitw;
            end
            dK_bin = kfertplus_bin - kfert_bin;
            jj = find(imag(dK_bin)~=0);
            dK_bin(jj) = NaN;
            dKQ_bin(jj) = 4;
            if bininfo == 1
                lim_bin(kfertplus_bin > kfert_bin) = 1;
            end
            
            % examine for irrigation limitation
            
            if str2num(cb(4)) == 1
              
                % record water and nutrient limited areas
                % jj=find((desiredyield_bin > yc_rf_bin) & (lim_bin == 1));
                jj = find((irrplus_bin > irr_bin) & (lim_bin == 1));
                lim_bin(jj) = 2;
                
                dI_bin = irrplus_bin - irr_bin;
                jj = find(imag(dI_bin)~=0);
                dI_bin(jj) = NaN;
                dIQ_bin = ones(1,length(dIQ_bin));
                dIQ_bin(jj) = 4;
            else
                dI_bin = zeros(length(dI_bin),1);
                dIQ_bin = ones(length(dIQ_bin),1)+2;
            end
          
    end
    
    % place lim_bin into yieldlim map
    if errorflag == 1
        lim_bin(desiredyield_bin <= (yield_bin - error_bin)) = 4;
        lim_bin(desiredyield_bin <= yield_bin) = 4;
        lim_bin(desiredyield_bin > potentialyield_bin) = 5;
        % note: no error-correction for the "5" scenario right now
        % lim_bin((desiredyield_bin - error_bin) > potentialyield_bin) = 5;
    elseif errorflag == 0
        lim_bin(desiredyield_bin <= yield_bin) = 4;
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
