function y=nanmean(x);

ii=find(~isnan(x));

y=mean(x);