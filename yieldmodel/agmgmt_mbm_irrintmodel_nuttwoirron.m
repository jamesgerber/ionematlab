function [ymod] = agmgmt_mbm_irrintmodel_nuttwoirron(b,x,assign)

persistent binyieldceiling
persistent alpha

if nargin > 2 % a call to set parameters
    
    binyieldceiling = assign.binyieldceiling;
    alpha = assign.alpha;
    ymod = [];
    
elseif nargin == 2 % a call to run model (can be called by lsqcurvefit)
    
    ymodnut = min([binyieldceiling .* (1 - (alpha .* exp(-abs(b(1)) .* ...
        x(:,1)))), binyieldceiling .* (1 - (alpha .* exp(-abs(b(2)) .* ...
        x(:,2))))],[],2);

    zerocol = zeros(length(ymodnut),1);
    ymodirr = (max([ymodnut - b(3), zerocol],[],2) .* x(:,3)) + b(3);
    
    ymod = min([ymodnut,ymodirr],[],2);
    
end