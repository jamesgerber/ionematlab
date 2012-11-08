        disp(['calling CountryNameToOutline']);
        [Outline,Codes,Names]=CountryNameToOutline;
        c=1;
        Offset=1;

        
        BinMask=[20:40]
        
        
        clear MatrixForBoxPlot CountryNameList CountryCodeList
        for j=1:length(Codes);
            ThisCountryCode=Codes(j);
            ThisCountry=Names{j};
            disp(['Working on ' ThisCountry ]);
            % now find those datapoints that correspond to this country
            ii=find(Outline==ThisCountryCode);
            ThisCountryYG=YieldGapArray(ii);
            ThisCountryYG(isnan(ThisCountryYG))=[];
            % now populate boxplot matrix
            
            
            
            
            
            if  length(ThisCountryYG) >= MinNumPointsAllBinsBoxPlot
                MatrixForBoxPlot(1:length(ThisCountryYG),c)=single(ThisCountryYG+Offset);
                CountryNameList{c}=ThisCountry;
                CountryCodeList(c)=ThisCountryCode;
                c=c+1;
            else
                disp(['Ignoring ' ThisCountry '. Not enough (' num2str(MinNumPointsAllBinsBoxPlot) ') datapoints']);
            end
            
            
        end
        disp('making box plot')
        figure
        
        [dum,iisorted]=sort(CountryCodeList);
        
        MatrixForBoxPlot(MatrixForBoxPlot==0)=NaN;
        MatrixForBoxPlot=MatrixForBoxPlot-single(Offset);
        boxplot(MatrixForBoxPlot(:,iisorted),CountryNameList(iisorted),'labelorientation','inline');
        title([cropname ' Yield.  All climate bins. Min pts/country=' int2str(MinNumPointsAllBinsBoxPlot)]);
        ylabel('Yield Gap Fraction')