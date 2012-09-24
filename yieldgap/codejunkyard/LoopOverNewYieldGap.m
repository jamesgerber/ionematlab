for jwf=[4]
    for jhf=1
        for CropNo=[5 ]
            for RevCount=[6]
                switch jwf
                    case 1
                        WetFlag='prec_on_gdd'
                    case 2
                        WetFlag='prec'
                        
                    case 3
                        WetFlag='aei'
                    case 4
                        WetFlag='TMI'
                end
                switch jhf
                    case 1
                        HeatFlag='GDD'
                    case 2
                        HeatFlag='GSL'
                end
                
                cheating='ABCDEF';
                Rev=cheating(RevCount)
                
                clear WorkingVariable
                
                BinVector=[10];
                
                for j=1:length(BinVector)
                    numbins = BinVector(j)
                    
                    N=numbins;
                    Nstr=int2str(numbins);
                    %    FileName=['GDD' num2str(GDDTemp) '_' WetFlag '_' Nstr 'x' Nstr '_RevA'];
                    %    load (['/Users/jsgerber/sandbox/jsg003_YieldGapWork/ClimateSpaceLibrary/' FileName '.mat'])
                    
                    stash j
                    YieldGapFunction;
                    unstash j
              %      PercentageYieldDifference(j)=perdifference;
                    
                    %                 cropname=strrep(cropname,' ','_');
                    %                 ionesurf(Long,Lat,YieldGapArray, 'Yield Gap Fraction', ['YG Fraction for ' cropname ', Moisture Index: ' WetFlag '. Rev ' Rev ' ']);
                    %                 disp(['YGArray_' cropname '_' WetFlag ' = YieldGapArray;'])
                    %                 eval(['YGArray_' strrep(cropname,' ','_') '_' WetFlag ' = YieldGapArray;'])
                    %                 AddCoasts
                    %                 OutputFig('Force')
                    % close all
                    
                    
                    
                    
                    %                 Global_YG_Mean = nanmean(YieldGapArray(DataMaskIndices));
                    
                    %                 WorkingVariable(j) = [Global_YG_Mean];
                    
                    %   close all
                    % ShannonEntropyMeasure;
                    % ShannonEntropy(j)=WeightedHbin;
                    %%%   Output = [Output; numbins Global_YG_Mean]
                    %     close all
                end
                %             figure
                %             plot(BinVector,(PercentageYieldDifference-1)*100,'-x');
                %             xlabel('Size of climate space (NxN)')
                %             ylabel('%')
                %             title(['Potential yield increase (%) for ' cropname ' if reach 95% yield throughout climate bin'])
                %           fattenplot
                %           OutputFig('Force')
            end
        end
    end
end