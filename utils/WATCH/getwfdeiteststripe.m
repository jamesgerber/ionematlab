function [mdn,ts,struct]=getWFDEIteststripe(idx,type);
% getWFDEIteststripe - get test stripe returns a stripe with increasing
% variance




[mdn,Tair,struct]=getWFDEIstripe(97729,'Tair_WFDEI');





switch type
    
    case 'nochange'
        alpha= 0;   % 1 degree/year
        delvar=0;
    case 'increasingmean'
        alpha= 2/10;   % 1 degree/year
        delvar=0;
    case 'increasing variance'
        alpha=0;
        delvar=1/10;   % 1 degree / year more or less.  
    otherwise 
        error
        
        
end

        
d=mdn-mdn(1);

d=d';

dm=repmat(d,1,length(idx));
d=dm;


%function y=functionguts(alpha,d,delvar);

y=alpha*(d/365)+20*cos(2*pi/365.25*d)+15*cos(2*pi/1*d)+3*cos(2*pi/365.25/4*d) + (5+(delvar*d/365)).*randn(size(d));
%y= (1+(delvar*d/365)).*randn(size(d));




ts=y;
