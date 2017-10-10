function small=aggregate_quantity(big,N,nanflag)        
%aggregatequantity - aggregate quantity data down to a coarser scale
%
% Syntax:
%   aggregate_quantity(bigmatrix,N)
%
%   aggregate_quantity(bigmatrix,N,'NANFLAG')
%    where 'NANFLAG' can be 
%     'hidden' or 'average' - NaN values will be treated as 'missing' data
%     and replaced with the average value of the non-nan values found at
%     the smallest level of aggregation.
%     'sum'  - NaN values will be treated as zero
%     'kill' - any NaN values at the highst resolution will lead to a NaN
%     values for the associated aggregated cell. 
%
% EXAMPLE
%   A=testdata;
%   B=aggregate_quantity(A,5);
%
% [  1 1 1 
%  NaN 1 1       ->   "hidden"  ->  [9]
%  NaN 1 1]  
%
% [  1 1 1 
%  NaN 1 1       ->   "sum"  ->  [7]
%  NaN 1 1]  
%
% [  1 1 1 
%  NaN 1 1       ->   "kill"  ->  [NaN]
%  NaN 1 1]  
%
%
%
%
% See also:  aggregate_rate

if nargin==2
    nanflag='kill';
end

switch lower(nanflag)
    case 'kill'
        small=zeros(size(big)/N);
        for m=1:N
            for k=1:N
                small(:,:)=small(:,:)+big(m:N:end,k:N:end);
            end
        end
    case {'hidden','average'}
        correctionfactor=aggregate_rate(isfinite(big),N,'kill');
        big(isnan(big))=0;
        x=aggregate_quantity(big,N,'kill');
        small=x./correctionfactor;
    case {'sum'}
        big(isnan(big))=0;
        small=aggregate_quantity(big,N,'kill');
    otherwise
        error(' syntax of aggregate_quantity has been changed ');
end
  


