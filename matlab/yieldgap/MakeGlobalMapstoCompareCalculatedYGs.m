for CropNo=[7]
    for jwf=[2 3 4]
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
        N=10
        HeatFlag='GDD';
        Rev='F';
        % % %         for IAM=1:2
        % % %             switch IAM
        % % %                 case 1
        % % %                     IndividualAreaMethod='AllBinFifthPercentile';
        % % %                 case 2
        % % %                     IndividualAreaMethod='fixed';
        % % %             end
        % % %             NewYieldGap
        % % %             disp(['YGArray_' cropname '_' WetFlag '_' IndividualAreaMethod  '= YieldGapArray;'])
        % % %             eval(['YGArray_' cropname '_' WetFlag '_' IndividualAreaMethod  '= YieldGapArray;'])
        % % %             ionesurf(Long,Lat,YieldGapArray, 'Yield Gap Fraction', ['YG Fraction for ' cropname ' 5% Method: ' IndividualAreaMethod]);
        % % %             AddCoasts
        % % %             OutputFig
        % % %         end
        YieldGapFunction
        cropname=strrep(cropname,' ','_');
        ionesurf(Long,Lat,YieldGapArray, 'Yield Gap Fraction', ['YG Fraction for ' cropname ', Moisture Index: ' WetFlag '. Rev' Rev]);
        disp(['YGArray_' cropname '_' WetFlag ' = YieldGapArray;'])
        eval(['YGArray_' strrep(cropname,' ','_') '_' WetFlag ' = YieldGapArray;'])
        AddCoasts
        OutputFig('Force')
        close all
    end
    save(['working_' cropname]);
    
    disp(['Diff_aei_prec = YGArray_' cropname '_aei - YGArray_' cropname '_prec;'])
    eval(['Diff_aei_prec = YGArray_' cropname '_aei - YGArray_' cropname '_prec;'])
    ionesurf(Long,Lat,Diff_aei_prec, 'Difference in YG Fraction', [' YGArray_' cropname '_aei - YGArray_' cropname '_prec  Rev' Rev]);
    AddCoasts
    caxis([-1 1])
    OutputFig('Force')
    close all
    %     disp(['Diff_aei_precongdd = YGArray_' cropname '_aei - YGArray_' cropname '_prec_on_gdd;'])
    %     eval(['Diff_aei_precongdd = YGArray_' cropname '_aei - YGArray_' cropname '_prec_on_gdd;'])
    %     ionesurf(Long,Lat,Diff_aei_precongdd, 'Difference in YG Fraction', ['YGArray_' cropname '_aei - YGArray_' cropname '_prec_on_gdd']);
    %     AddCoasts
    %     OutputFig('Force')
    %     close all
    %     disp(['Diff_prec_precongdd = YGArray_' cropname '_prec - YGArray_' cropname '_prec_on_gdd;'])
    %     eval(['Diff_prec_precongdd = YGArray_' cropname '_prec - YGArray_' cropname '_prec_on_gdd;'])
    %     ionesurf(Long,Lat,Diff_prec_precongdd, 'Difference in YG Fraction', ['YGArray_' cropname '_prec - YGArray_' cropname '_prec_on_gdd']);
    %     AddCoasts
    %     OutputFig('Force')
    %     close all
    disp(['Diff_aei_TMI = YGArray_' cropname '_aei - YGArray_' cropname '_TMI;'])
    eval(['Diff_aei_TMI = YGArray_' cropname '_aei - YGArray_' cropname '_TMI;'])
    ionesurf(Long,Lat,Diff_aei_TMI, 'Difference in YG Fraction', [' YGArray_' cropname '_aei - YGArray_' cropname '_TMI. Rev' Rev]);
    AddCoasts
    caxis([-1 1])
    OutputFig('Force')
    close all
    disp(['Diff_prec_TMI = YGArray_' cropname '_prec - YGArray_' cropname '_TMI;'])
    eval(['Diff_prec_TMI = YGArray_' cropname '_prec - YGArray_' cropname '_TMI;'])
    ionesurf(Long,Lat,Diff_prec_TMI, 'Difference in YG Fraction', [' YGArray_' cropname '_prec - YGArray_' cropname '_TMI. Rev' Rev]);
    caxis([-1 1])
    AddCoasts
    OutputFig('Force')
    close all
end


