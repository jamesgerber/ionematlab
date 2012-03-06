function [ymod] = agmgmt_mbm_irrintmodel_nutthreeirron_sf(b,x,assign)

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
    nutonevec = x(:,1);
    nuttwovec = x(:,2);
    nutthreevec = x(:,3);
    irrvec = x(:,4);
    
    % get nutrient requirements to achieve rainfed potential yield
    nutonereqRFYC = max(log((1-(b(4)./binyieldceiling))./alpha)./-b(1),0);
    nuttworeqRFYC = max(log((1-(b(4)./binyieldceiling))./alpha)./-b(2),0);
    if (kfloatflag == 1) &&  (str2num(cb(3)) == 1)
        nutthreereqRFYC = max(log((1-(b(4)./binyieldceiling))./b(5))./...
            -b(3),0);
    else
        nutthreereqRFYC = max(log((1-(b(4)./binyieldceiling))./alpha)./...
            -b(3),0);
    end

    % get grid cells where we have nutrients in excess of nutreqRF and have
    % irrigated area
    ii = (nutonevec > nutonereqRFYC) & (nuttwovec > nuttworeqRFYC) ...
        & (nutthreevec > nutthreereqRFYC) & (irrvec > 0);
    rr = ~ii;
    
    % on the "ii" grid cells, ymod is a weighted average of rainfed yield
    % ceiling and ymodirr (yield on irrigated lands - these places get the
    % benefits of nutrients > nutreqRF)
    if sum(ii)>0
        nutoneirrvec_ii = (nutonevec(ii) - (nutonereqRFYC.*(1 - ...
            irrvec(ii)))) ./ irrvec(ii);
        nuttwoirrvec_ii = (nuttwovec(ii) - (nuttworeqRFYC.*(1 - ...
            irrvec(ii)))) ./ irrvec(ii);
        nutthreeirrvec_ii = (nutthreevec(ii) - (nutthreereqRFYC.*(1 - ...
            irrvec(ii)))) ./ irrvec(ii);
        
        ymodnutoneirr_ii = binyieldceiling .* (1 - (alpha .* ...
            exp(-abs(b(1)) .* nutoneirrvec_ii)));
        ymodnuttwoirr_ii = binyieldceiling .* (1 - (alpha .* ...
            exp(-abs(b(2)) .* nuttwoirrvec_ii)));
        if (kfloatflag == 1) &&  (str2num(cb(3)) == 1)
            ymodnutthreeirr_ii = binyieldceiling .* (1 - (b(5) .* ...
                exp(-abs(b(3)) .* nutthreeirrvec_ii)));
        else
            ymodnutthreeirr_ii = binyieldceiling .* (1 - (alpha .* ...
                exp(-abs(b(3)) .* nutthreeirrvec_ii)));
        end
        
        ymodirr_ii = min([ymodnutoneirr_ii, ymodnuttwoirr_ii, ...
            ymodnutthreeirr_ii],[],2);
        
        ymodweightavg_rfandirr_ii = ((1-irrvec(ii)).*b(4)) + ...
            (irrvec(ii) .* ymodirr_ii);
    end
    
    % calculate ymod on rainfed land or land where nutrients limit yield
    % below rainfed yield ceiling
    if sum(rr)>0
        ymodnutonerf_rr = binyieldceiling .* (1 - (alpha .* ...
            exp(-abs(b(1)) .* nutonevec(rr))));
        ymodnuttworf_rr = binyieldceiling .* (1 - (alpha .* ...
            exp(-abs(b(2)) .* nuttwovec(rr))));
        if (kfloatflag == 1) &&  (str2num(cb(3)) == 1)
            ymodnutthreerf_rr = binyieldceiling .* (1 - (b(5) .* ...
                exp(-abs(b(3)) .* nutthreevec(rr))));
        else
            ymodnutthreerf_rr = binyieldceiling .* (1 - (alpha .* ...
                exp(-abs(b(3)) .* nutthreevec(rr))));
        end
        
        yc_rf_bin_col_rr = b(4).*ones(length(ymodnutonerf_rr),1);
        ymodrf_rr = min([yc_rf_bin_col_rr, ymodnutonerf_rr, ...
            ymodnuttworf_rr, ymodnutthreerf_rr],[],2);
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
% 
%     ymodnut = min([binyieldceiling .* (1 - (alpha .* exp(-abs(b(1)) .* ...
%         x(:,1)))), binyieldceiling .* (1 - (alpha .* exp(-abs(b(2)) .* ...
%         x(:,2)))), binyieldceiling .* (1 - (alpha .* exp(-abs(b(3)) .* ...
%         x(:,3))))],[],2);
% 
%     zerocol = zeros(length(ymodnut),1);
%     ymodirr = (max([ymodnut - b(4), zerocol],[],2) .* x(:,4)) + b(4);
%     
%     ymod = min([ymodnut,ymodirr],[],2);
%     
% end