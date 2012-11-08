% notes:  initial revision of this worked in original directory structure:
% ~/sandbox/jsg003_yieldgapwork/
%
% now modifying to work in DeltaClimate
for soilno=[1 2]
    switch soilno
        case 1
            SoilRev='Ar1';
        case 2
            SoilRev='Ar2';
        case 3
            SoilRev='Br1';
        case 4
            SoilRev='Br2';
        otherwise
            error
    end
                
    for CropNo=[  7] % 7 8
       % for CropNo=7;
        N=5;
    
    FS.PercentileForMaxYield=95;
    FS.MinNumberHectares=10;
    FS.CropNo=CropNo;
    FS.WetFlag='TMI';
%    FS.ClimateSpaceRev=['G_soilrev' SoilRev ];
    FS.ClimateSpaceRev='G';
    FS.ClimateSpaceN=N;
    FS.csqirev=SoilRev;
    FS.QuietFlag=0;
    FS.MakeGlobalMaps=0;
    FS.MakeBinWeightedYieldGapPlotFlag=0;
    FS.ClimateLibraryDir='../ClimateLibrary3D';   
    
    FS.ibinlist=(2*N^2+1:3*N^2);
    OS3=YieldGapFunction(FS);
    
    FS.ibinlist=(N^2+1:2*N^2);
    OS2=YieldGapFunction(FS);
    
    FS.ibinlist=1:N^2;
    OS1=YieldGapFunction(FS); 
     
    FS.PercentileForMaxYield=95;
    FS.MinNumberHectares=10;

    FS.WetFlag='TMI';
    FS.ClimateSpaceRev='F';
    FS.ClimateSpaceN=N;
    
    FS.QuietFlag=0;
    FS.MakeGlobalMaps=0;
    FS.MakeBinWeightedYieldGapPlotFlag=0;
    FS.ClimateLibraryDir='../ClimateSpaces';
    
    FS.ibinlist=1:N^2;
    OSF=YieldGapFunction(FS);
    
    
    %% in each bin ... how does potential proe
%     figure
%     NN=N^2;
%     plot([1:NN],OS1.VectorOfPotentialYields(1:NN),'d:',...
%         [1:NN],OS2.VectorOfPotentialYields(NN+(1:NN)),'o--',...
%         [1:NN],OS3.VectorOfPotentialYields(2*NN+(1:NN)),'p-.',...
%         [1:NN],OSF.VectorOfPotentialYields,'x-');
%     legend('Best Soil','Moderate Soil','Poor Soil','All Soils');
%     xlabel('Climate Bin')
%     ylabel(['Potential yield. t/ha'])
%     title(['Potential yield analysis within Rev ' SoilRev ' soil bins. ' OS1.cropname]);
%     grid on
%     fattenplot
    
    for j=1:N.^2
        TotalArea1(j)=sum(sum(OS1.Area(OS1.LogicalArrayOfGridPointsInABin & OS1.ClimateMask==j)));
        TotalArea2(j)=sum(sum(OS2.Area(OS2.LogicalArrayOfGridPointsInABin & OS2.ClimateMask==(j+N^2))));
        TotalArea3(j)=sum(sum(OS3.Area(OS3.LogicalArrayOfGridPointsInABin & OS3.ClimateMask==(j+2*N^2))));
        TotalAreaF(j)=sum(sum(OSF.Area(OSF.LogicalArrayOfGridPointsInABin & OSF.ClimateMask==j)));
    end
    
    figure
    NN=N^2;
    scatter([1:NN],OS1.VectorOfPotentialYields(1:NN),200*TotalArea1./TotalAreaF,'rd');
    hold on
    scatter([1:NN],OS2.VectorOfPotentialYields(NN+(1:NN)),200*TotalArea2./TotalAreaF,'^g');
 %   scatter( [1:NN],OS3.VectorOfPotentialYields(2*NN+(1:NN)),200*TotalArea2./TotalAreaF,'sb');
    scatter([1:NN],OSF.VectorOfPotentialYields,200*TotalAreaF./TotalAreaF,'oc')
    legend(['Best Soil (' int2str( sum(TotalArea1)/sum(TotalAreaF)*100) '%)'], ...
        ['Moderate Soil (' int2str( sum(TotalArea2)/sum(TotalAreaF)*100) '%)'], ...
                ['All Soils (' int2str( sum(TotalAreaF)/sum(TotalAreaF)*100) '%)'],3);
 %       ['Poor Soil (' int2str( sum(TotalArea3)/sum(TotalAreaF)*100) '%)'], ...

    xlabel('Climate Bin')
    ylabel(['Potential yield. t/ha'])
    title(['Potential yield analysis within Rev ' SoilRev ' soil bins. ' OS1.cropname]);
    grid on
    plot([1:NN],OS1.VectorOfPotentialYields(1:NN),'r');
    
    plot([1:NN],OS2.VectorOfPotentialYields(NN+(1:NN)),'g');
%    plot( [1:NN],OS3.VectorOfPotentialYields(2*NN+(1:NN)),'b');
    plot([1:NN],OSF.VectorOfPotentialYields,'c')
    zeroylim
    %fattenplot
    %% what is total harvested area?
    end
end
