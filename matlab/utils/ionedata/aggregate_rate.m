function small=aggregate_rate(big,N)        
%aggregate_rate - aggregate rate data down to a coarser scale
%
% aggregate_rate(big,N) - where big is a 2D matrix and N is a scalar,
% returns the big reduced in size by a factor of N.

small=zeros(size(big)/N);
for m=1:N
    for k=1:N
        small(:,:)=small(:,:)+big(m:N:end,k:N:end);
    end
end

small=small/N^2;   % this line assures that rate stays the same