function small=aggregate_rate(big,N)        
%aggregaterate - aggregate rate data down to a coarser scale


small=zeros(size(big)/N);
for m=1:N
    for k=1:N
        small(:,:)=small(:,:)+big(m:N:end,k:N:end);
    end
end

small=small/N^2;   % this line assures that rate stays the same