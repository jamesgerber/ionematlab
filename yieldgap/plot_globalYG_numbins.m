for jwf=[2 3 1]
    switch jwf
        case 1
            WetFlag='prec_on_gdd' 
        case 2
            WetFlag='prec'
        case 3
            WetFlag='aei'
    end
    
    HeatFlag='GDD';
    
    for CropNo=[5 7 8 10]
    
    clear WorkingVariable
    BinVector=[1:10 12 15  25];
    for j=1:length(BinVector)
        numbins = BinVector(j)
        N=numbins;
        Nstr=int2str(numbins);
        %    FileName=['GDD' num2str(GDDTemp) '_' WetFlag '_' Nstr 'x' Nstr '_RevA'];
        %    load (['/Users/jsgerber/sandbox/jsg003_YieldGapWork/ClimateSpaceLibrary/' FileName '.mat'])
        
        stash j
        YieldGapFunction;
        unstash j
        
        Global_YG_Mean = nanmean(YieldGapArray(DataMaskIndices));
        
        WorkingVariable(j) = [Global_YG_Mean];
        
        
   %     ShannonEntropyMeasure;
   %     ShannonEntropy(j)=WeightedHbin;
        %%%   Output = [Output; numbins Global_YG_Mean]
        
        
    end
    
% %     %rename WorkingVariable
      Global_YG_Mean_Vector_GDD0 = WorkingVariable;
% %     
% %     %disp(['Global_YG_Mean_Vector_GDD' num2str(GDDTemp) '_' WetFlag '=WorkingVariable;']);
% %     eval(['Global_YG_Mean_Vector_Crop_' strrep(cropname,' ','') '_' WetFlag '=WorkingVariable;']);
% %     figure;
% %     plot(BinVector, ShannonEntropy,'o-');
% %     xlabel('Measure of bins in climate space')
% %     ylabel('Shannon Entropy Measure')
% %     title(['Population diversity measure (' cropname ') as a function of climate space size.  Moisture Index = ' WetFlag])
% %     fattenplot
% %     OutputFig('Force');
% % 
    grid on

    figure
    plot(BinVector, WorkingVariable,'o-');
    xlabel('Measure of bins in climate space')
    ylabel('Mean Yield Gap')
    title(['Mean Yield Gap (' cropname ') as a function of climate space size.  Moisture Index = ' WetFlag])
    fattenplot
    OutputFig('Force');
    grid on
    end
end

crash

for crpname=1:4
    switch crpname
        case 1
            cropname = 'Barley'
        case 2
            cropname = 'Maize'
        case 3
            cropname = 'OilPalm'
        case 4
            cropname = 'Wheat'
    end
    for jwf=1:3
        switch jwf
            case 1
                WetFlag='prec_on_gdd'
            case 2
                WetFlag='prec'
                
            case 3
                WetFlag='aei'
        end
        
        eval(['Global_YG_Mean_Vector_Crop_' strrep(cropname,' ','') '_' WetFlag '=WorkingVariable;']);
        figure;
        plot(BinVector, WorkingVariable,'o-');
        xlabel('Measure of bins in climate space')
        ylabel('Mean Yield Gap')
        title(['Mean Yield Gap (' cropname ') as a function of climate space size.  Moisture Index = ' WetFlag])
        fattenplot
        grid on
    end

end

    