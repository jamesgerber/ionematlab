% % % for CropNo=[5 7 8 10]
% % %
for jwf=1:3
    switch jwf
        case 1
            WetFlag='prec_on_gdd'
        case 2
            WetFlag='prec'
        case 3
            WetFlag='aei'
    end
    disp(['load GDD0_' WetFlag '_10x10_RevA GDD Prec GDDBinEdges PrecBinEdges'])
    eval(['load GDD0_' WetFlag '_10x10_RevA GDD Prec GDDBinEdges PrecBinEdges'])
    GenerateJointDist(GDD(DataMaskIndices),Prec(DataMaskIndices),GDDBinEdges,PrecBinEdges);
    ylabel([WetFlag])
    xlabel('GDD Base 0')
    title(['Bin Populations for Climate Space: GDD0 & ' WetFlag ' (10x10)'])
    OutputFig
    close all
end