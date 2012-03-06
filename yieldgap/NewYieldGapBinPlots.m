[CountryNumbers,CountryNames]=GetCountry(LongCol,LatCol);

[CountryNums,idx]=unique(CountryNumbers);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOXPLOT
clear MatrixForBoxPlot CountryNameList
MinNumPoints=100;
c=1;
Offset=1;
for m=1:length(CountryNums);
    jj=find(CountryNumbers==CountryNums(m));
    sty=getlinestyle(jj);
    
    x=CountryNumbers(jj);
    y=YieldCol(jj);
    
    ThisCountry=CountryNames{idx(m)};
    
    
    if  length(jj) >= MinNumPoints
        MatrixForBoxPlot(1:length(jj),c)=y+Offset;
        CountryNameList{c}=ThisCountry;
        c=c+1;
    end
    
    %h=plot(m,y,'.',m,mean(y),'go',m,mean(y)+std(y),'rd',m,mean(y)-std(y),'rd');
    
    MeanVector(m)=mean(y);
    StdVector(m)=std(y);
    
    %  hold on
    
    %set(h,'ButtonDown',[disp(
end
% hold off
%xlabel('Country Number')
%ylabel('Yield')


figure
MatrixForBoxPlot(MatrixForBoxPlot==0)=NaN;
MatrixForBoxPlot=MatrixForBoxPlot-Offset;
boxplot(MatrixForBoxPlot,CountryNameList,'labelorientation','inline');
title([cropname ' Yield.  Climate bin ' int2str(ibin) '. Min pts/country=' int2str(MinNumPoints)]);
ylabel('tons/ha')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plots for data quality

figure
plot(FilteredCropTable(:,2),FilteredCropTable(:,1),'.')
ylabel('Yield')
xlabel('Area')

GenerateJointDist(FilteredCropTable(:,2),FilteredCropTable(:,1),20,20);
ylabel('Yield')
xlabel('Area')
title(['Joint Distribution of Yield and Area. ' cropname ' Climate bin ' int2str(ibin) '. Min pts/country=' int2str(MinNumPoints)]);


%%%% what are those outliers? - interesting data for bin 27
ii=find(FilteredCropTable(:,2) > FilteredCropTable(:,1)*2000);
if length(ii)>1
    [Cnums,Cnames]=GetCountry(FilteredLong(ii),FilteredLat(ii));
end