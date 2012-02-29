function small=aggregatequantity(big,N)        
%aggregatequantity - aggregate quantity data down to a coarser scale


small=zeros(size(big)/N);
for m=1:N
    for k=1:N
        small(:,:)=small(:,:)+big(m:N:end,k:N:end);
    end
end
