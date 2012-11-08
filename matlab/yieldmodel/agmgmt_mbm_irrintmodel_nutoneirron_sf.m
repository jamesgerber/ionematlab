function [ymod] = agmgmt_mbm_irrintmodel_nutoneirron_sf(b,x,assign)

persistent binyieldceiling
persistent alpha
persistent kfloatflag
persistent cb

if nargin > 2 % a call to set parameters
    
    binyieldceiling = assign.binyieldceiling;
    alpha = assign.alpha;
    kfloatflag = assign.kfloatflag;
    cb = assign.cb;
    ymod = [];
    
elseif nargin == 2 % a call to run model (can be called by lsqcurvefit)
    
    % rename input variables
    nutvec = x(:,1);
    irrvec = x(:,2);
    
    % get nutrient requirements to achieve rainfed potential yield
    if (kfloatflag == 1) &&  (str2num(cb(3)) == 1)
        nutreqRFYC = max(log((1-(b(2)./binyieldceiling))./b(3))./-b(2),0);
    else
        nutreqRFYC = max(log((1-(b(2)./binyieldceiling))./alpha)./-b(1),0);
    end
    
    % get grid cells where we have nutrients in excess of nutreqRF and have
    % irrigated area
    ii = (nutvec > nutreqRFYC) & (irrvec > 0);
    rr = ~ii;
    
    % on the "ii" grid cells, ymod is a weighted average of rainfed yield
    % ceiling and ymodirr (yield on irrigated lands - these places get the
    % benefits of nutrients > nutreqRF)
    if sum(ii)>0
        nutirrvec_ii = (nutvec(ii) - (nutreqRFYC.*(1 - irrvec(ii)))) ...
            ./ irrvec(ii);
        
        if (kfloatflag == 1) &&  (str2num(cb(3)) == 1)
            ymodirr_ii = binyieldceiling .* (1 - (b(3) .* ...
                exp(-abs(b(1)) .* nutirrvec_ii)));
        else
            ymodirr_ii = binyieldceiling .* (1 - (alpha .* ...
                exp(-abs(b(1)) .* nutirrvec_ii)));
        end
        
        ymodweightavg_rfandirr_ii = ((1-irrvec(ii)).*b(2)) + ...
            (irrvec(ii) .* ymodirr_ii);
    end
    
    % calculate ymod on rainfed land or land where nutrients limit yield
    % below rainfed yield ceiling
    if sum(rr)>0
        if (kfloatflag == 1) &&  (str2num(cb(3)) == 1)
            ymodnutonerf_rr = binyieldceiling .* (1 - (b(3) .* ...
                exp(-abs(b(1)) .* nutvec(rr))));
        else
            ymodnutonerf_rr = binyieldceiling .* (1 - (alpha .* ...
            exp(-abs(b(1)) .* nutvec(rr))));
        end
        
        yc_rf_bin_col_rr = b(2).*ones(length(ymodnutonerf_rr),1);
        ymodrf_rr = min([yc_rf_bin_col_rr, ymodnutonerf_rr],[],2);
    end
    
    % combine into final ymod vector
    ymod = nan(length(nutvec),1);
    if sum(ii)>0
        ymod(ii) = ymodweightavg_rfandirr_ii;
    end
    if sum(rr)>0
        ymod(rr) = ymodrf_rr;
    end
    
end