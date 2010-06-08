function [ContourMask,CutoffValue]=FindContour(jp,jpmax,p)

  %find contour that has 0.95% of area

jpmax_norm=jpmax/max(max(jpmax));

%level=fminbnd(@(level) testlevel(level,jp,jpmax,p),0,1);
level=fzero(@(level) testlevel(level,jp,jpmax_norm,p),.1);

ContourMask=(jpmax_norm>level);
CutoffValue=level*max(max(jpmax));  %need to renormalize


function tlerror=testlevel(level,jp,jpmax,p)
% returns an error measure of how far off level is from giving
% contour that encloses p percent of jp
ii=(jpmax>level);

pguess=sum(jp(ii))/sum(sum(jp));

tlerror=(pguess-p);


