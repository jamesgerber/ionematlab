function [ymod] = agmgmt_mbm_irrintmodel_nuttwoirron_sf(b,x,assign)

persistent binyieldceiling
persistent alpha

if nargin > 2 % a call to set parameters
    
    binyieldceiling = assign.binyieldceiling;
    alpha = assign.alpha;
    ymod = [];
    
elseif nargin == 2 % a call to run model (can be called by lsqcurvefit)
    
    % rename input variables
    nutonevec = x(:,1);
    nuttwovec = x(:,2);
    irrvec = x(:,3);
    
    % get nutrient requirements to achieve rainfed potential yield
    nutonereqRFYC = max(log((1-(b(3)./binyieldceiling))./alpha)./-b(1),0);
    nuttworeqRFYC = max(log((1-(b(3)./binyieldceiling))./alpha)./-b(2),0);

    % get grid cells where we have nutrients in excess of nutreqRF and have
    % irrigated area
    ii = (nutonevec > nutonereqRFYC) & (nuttwovec > nuttworeqRFYC) ...
        & (irrvec > 0);
    rr = ~ii;
    
    % on the "ii" grid cells, ymod is a weighted average of rainfed yield
    % ceiling and ymodirr (yield on irrigated lands - these places get the
    % benefits of nutrients > nutreqRF)
    if sum(ii)>0
        nutoneirrvec_ii = (nutonevec(ii) - (nutonereqRFYC.*(1 - ...
            irrvec(ii)))) ./ irrvec(ii);
        nuttwoirrvec_ii = (nuttwovec(ii) - (nuttworeqRFYC.*(1 - ...
            irrvec(ii)))) ./ irrvec(ii);
        
        ymodnutoneirr_ii = binyieldceiling .* (1 - (alpha .* ...
            exp(-abs(b(1)) .* nutoneirrvec_ii)));
        ymodnuttwoirr_ii = binyieldceiling .* (1 - (alpha .* ...
            exp(-abs(b(2)) .* nuttwoirrvec_ii)));
        
        ymodirr_ii = min([ymodnutoneirr_ii, ymodnuttwoirr_ii],[],2);
        
        ymodweightavg_rfandirr_ii = ((1-irrvec(ii)).*b(3)) + ...
            (irrvec(ii) .* ymodirr_ii);
    end
    
    % calculate ymod on rainfed land or land where nutrients limit yield
    % below rainfed yield ceiling
    if sum(rr)>0
        ymodnutonerf_rr = binyieldceiling .* (1 - (alpha .* ...
            exp(-abs(b(1)) .* nutonevec(rr))));
        ymodnuttworf_rr = binyieldceiling .* (1 - (alpha .* ...
            exp(-abs(b(2)) .* nuttwovec(rr))));
        
        yc_rf_bin_col_rr = b(3).*ones(length(ymodnutonerf_rr),1);
        ymodrf_rr = min([yc_rf_bin_col_rr, ymodnutonerf_rr, ...
            ymodnuttworf_rr],[],2);
    end
    
    % combine into final ymod vector
    ymod = nan(length(nutonevec),1);
    if sum(ii)>0
        ymod(ii) = ymodweightavg_rfandirr_ii;
    end
    if sum(rr)>0
        ymod(rr) = ymodrf_rr;
    end
    
end