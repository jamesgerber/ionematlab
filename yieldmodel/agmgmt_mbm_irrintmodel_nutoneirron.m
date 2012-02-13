function [ymod] = agmgmt_mbm_irrintmodel_nutoneirron(b,x,assign)

persistent binyieldceiling
persistent alpha

if nargin > 2 % a call to set parameters
    
    binyieldceiling = assign.binyieldceiling;
    alpha = assign.alpha;
    ymod = [];
    
elseif nargin == 2 % a call to run model (can be called by lsqcurvefit)
    
    ymodnut = binyieldceiling .* (1 - (alpha .* exp(-abs(b(1)) .* ...
        x(:,1))));

    zerocol = zeros(length(ymodnut),1);
    ymodirr = (max([ymodnut - b(2), zerocol],[],2) .* x(:,2)) + b(2);
    
    ymod = min([ymodnut,ymodirr],[],2);
    
end