function [mdn,ts,struct]=getwatchteststripe(idx,type);
% getWFDEIteststripe - get test stripe returns a stripe with increasing
% variance




[mdn,Tair,struct]=getstripe(97729,'Tair');





switch type
    
    case 'nochange'
        alpha= 0;   % 1 degree/year
        delvar=0;
    case 'increasingmean'
        alpha= 2/10;   % 1 degree/year
        delvar=0;
    case 'increasingvariance'
        alpha=0;
        delvar=1/20;   % 1 degree / year more or less.  
    otherwise 
        error
        
        
end

        
d=mdn-mdn(1);

%%%d=d'; comment this out.  needed it for WFDEI.  row/columns conventions
%%%are different.

dm=repmat(d,1,length(idx));
d=dm;


%function y=functionguts(alpha,d,delvar);

y=alpha*(d/365)+20*cos(2*pi/365.25*d)+15*cos(2*pi/1*d)+3*cos(2*pi/365.25/4*d) + (5+(delvar*d/365)).*randn(size(d));
%y= (1+(delvar*d/365)).*randn(size(d));

y=y+273.15+10;


ts=y;
