function small=aggregate_rate(big,N,nanflag)        
%aggregate_rate - aggregate rate data down to a coarser scale
%
% aggregate_rate(big,N) - where big is a 2D matrix and N is a scalar,
% returns the big reduced in size by a factor of N.
%
% aggregate_rate(big,N,nanflag) if nanflag is 1, will ignore values
% present in the first element of the matrix BIG when aggregating.  (it 
% replaces with zero and then weights accordingly).  Default is zero.
%
%
%  example
% big=repmat([ 1 0; .5 .5],3,3);
% small=aggregate_rate(big,3);
% big=repmat([ 2 0; NaN 1],2,2);
% small=aggregate_rate(big,2);
% big=repmat([ 2 0; NaN 1],2,2);
% small=aggregate_rate(big,2,1);

if nargin==2
    nanflag=0;
end

if nanflag==0
    small=zeros(size(big)/N);
    for m=1:N
        for k=1:N
            small(:,:)=small(:,:)+big(m:N:end,k:N:end);
        end
    end
    
    small=small/N^2;   % this line assures that rate stays the same
    return
end

% if we are here, it can only be because nanflag=1
big(big==big(1))=nan;

correctionfactor=aggregate_rate(isfinite(big),N,0);

big(isnan(big))=0;

x=aggregate_rate(big,N,0);

small=x./correctionfactor;