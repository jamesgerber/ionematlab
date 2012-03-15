function small=aggregate_quantity(big,N)        
%aggregatequantity - aggregate quantity data down to a coarser scale
%
% Syntax:
%   aggregate_quantity(bigmatrix,N)
%
% See also:  aggregate_rate

small=zeros(size(big)/N);
for m=1:N
    for k=1:N
        small(:,:)=small(:,:)+big(m:N:end,k:N:end);
    end
end
