function [F] = getirrgivennutrients(IRR, assign)

% function [F] = getirrgivennutrients(IRR, assign)

persistent c
persistent bnut
persistent NappGC
persistent Ymaxbin
persistent YmaxRF
persistent desiredyield

if nargin > 1 % a call to set variables

    c = assign.c;
    bnut = assign.bnut;
    NappGC = assign.NappGC;
    Ymaxbin = assign.Ymaxbin;
    YmaxRF = assign.YmaxRF;
    desiredyield = assign.desiredyield;
    
    F = 0;
    
else % call by fzero
    
    if IRR>1
        IRR = 1;
    elseif IRR <0
        IRR = 0;
    end
    
    NreqRF = log((1 - (YmaxRF ./ Ymaxbin)) ./ bnut) ./ -c;
    
    Nappirr = (NappGC - (NreqRF.*(1 - IRR))) ...
        ./ IRR;
    
    ymodirr = Ymaxbin .* (1 - (bnut .* ...
        exp(-abs(c) .* Nappirr)));
    
    ymodweightavg_rfandirr = ((1-IRR).*YmaxRF) + ...
        (IRR .* ymodirr);
    
    F = ymodweightavg_rfandirr - desiredyield;
    
    if ~isfinite(F)
        keyboard
    end
    
end