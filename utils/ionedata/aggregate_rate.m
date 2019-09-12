function [small,modecount]=aggregate_rate(big,N,nanflag)        
%aggregate_rate - aggregate quantity data down to a coarser scale
%
% Syntax:
%   aggregate_rate(bigmatrix,N)
%
%   aggregate_rate(bigmatrix,N,'NANFLAG')
%    where 'NANFLAG' can be 
%     'hidden' or 'average' - NaN values will be treated as 'missing' data
%     and replaced with the average value of the non-nan values found at
%     the smallest level of aggregation.
%     'sum'  - NaN values will be treated as zero
%     'kill' - any NaN values at the highst resolution will lead to a NaN
%     values for the associated aggregated cell. 
%     'mode'  - replace with modal value.  i dont' know how this would work
%     with NAN ... could work around by replacing nan with a value that
%     doesn't appear in the matrix and then doing 'mode'
%
%
% EXAMPLE
%   A=testdata;
%   B=aggregate_rate(A,5);
%
% [  1 1 1 
%  NaN 1 1       ->   "hidden"  ->  [1]
%  NaN 1 1]  
%
% [  1 1 1 
%  NaN 1 1       ->   "sum"  ->  [0.7777778]
%  NaN 1 1]  
%
% [  1 1 1 
%  NaN 1 1       ->   "kill"  ->  [NaN]
%  NaN 1 1]  
%
% [  1 1 1 
%    2 1 1       ->   "mode"  ->  [1]
%    2 1 1] 
%
%
% See also:  aggregate_quantity


% may need to make big a tiny bit bigger

x=size(big);
if rem(x(1),N)==0 & rem(x(2),N)==0
    % don't need to change anything
else
    % need to tack some extra stuff onto end of big so that accelerated
    % methods below will still work (i.e. parsing into columns, squares,
    % etc.)    
    warning([ 'Expanding size of input matrix in ' mfilename ' to allow ' ...
        'integer aggregation.  This may lead to issues at boundaries']);
    newr=N*ceil(x(1)/N);
    newc=N*ceil(x(2)/N);
    big(newr,newc)=0;
end
    

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
        small=small/N^2;
    case {'hidden','average'}
        correctionfactor=aggregate_rate(isfinite(big),N,'kill');
        big(isnan(big))=0;
        x=aggregate_quantity(big,N,'kill');
        small=x./correctionfactor/N^2;
    case {'sum'}
        big(isnan(big))=0;
        small=aggregate_rate(big,N,'kill');
    case {'mode'}
        
        temp=zeros([ceil(size(big)/N) N.^2]);
        c=0;
        for m=1:N
            for k=1:N
                c=c+1;
                temp(:,:,c)=big(m:N:end,k:N:end);
            end
        end
        
        if nargout==1
            [small,modecount]=mode(temp,3);          
        else
            [small,modecount]=mode(temp,3);
        end
        
        
        
    otherwise
        error(' syntax of aggregate_quantity has been changed ');
end
  


