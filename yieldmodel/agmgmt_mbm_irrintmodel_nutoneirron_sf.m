function [ymod] = agmgmt_mbm_irrintmodel_nutoneirron_sf(b,x,assign)

persistent binyieldceiling
persistent alpha

if nargin > 2 % a call to set parameters
    
    binyieldceiling = assign.binyieldceiling;
    alpha = assign.alpha;
    ymod = [];
    
elseif nargin == 2 % a call to run model (can be called by lsqcurvefit)
    
    % rename input variables
    nutvec = x(:,1);
    irrvec = x(:,2);
    
    % get nutrient requirements to achieve rainfed potential yield
    nutreqRFYC = max(log((1-(b(2)./binyieldceiling))./alpha)./-b(1),0);
    
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
        
        ymodirr_ii = binyieldceiling .* (1 - (alpha .* ...
            exp(-abs(b(1)) .* nutirrvec_ii)));
        
        ymodweightavg_rfandirr_ii = ((1-irrvec(ii)).*b(2)) + ...
            (irrvec(ii) .* ymodirr_ii);
    end
    
    % calculate ymod on rainfed land or land where nutrients limit yield
    % below rainfed yield ceiling
    ymodrf_rr = min(b(2), binyieldceiling .* (1 - (alpha .* ...
        exp(-abs(b(1)) .* nutvec(rr)))));
    
    % combine into final ymod vector
    ymod = nan(length(nutvec),1);
    if sum(ii)>0
        ymod(ii) = ymodweightavg_rfandirr_ii;
    end
    if sum(rr)>0
        ymod(rr) = ymodrf_rr;
    end
    
end