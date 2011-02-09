function x=AreaWeightedPercentile(area,data,p);
%AreaWeightedPercentile - calculate a percentile value by area
%

if ~isequal(length(area),length(data))
    error('unequal vector lengths');
end

    
    
[dum,ii]=sort(data);

sortedarea=area(ii);
sorteddata=data(ii);

tmp=cumsum(sortedarea);
normcumarea=tmp/max(tmp);

%find the value 
[dum,j]=min( (normcumarea-p).^2);

x=sorteddata(j);

