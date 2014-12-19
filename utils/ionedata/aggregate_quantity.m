function small=aggregate_quantity(big,N,nanflag)        
%aggregatequantity - aggregate quantity data down to a coarser scale
%
% Syntax:
%   aggregate_quantity(bigmatrix,N)
%
%
% EXAMPLE
%   A=testdata;
%   B=aggregate_quantity(A,5);
%
% See also:  aggregate_rate

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
    
    return
end

% if we are here, it can only be because nanflag=1

correctionfactor=aggregate_rate(isfinite(big),N,0);

big(isnan(big))=0;

x=aggregate_rate(big,N,0);

small=x./correctionfactor;