function [FileName,DirName]=YieldGapFunctionFileNames_CropName(FS,OutputDirBase);
% YieldGapFunctionFileNames - determine filenames for YieldGapFunction
%
%  Syntax
%
%  FileName=YieldGapFunctionFileNames(FS,OutputDirBase);
%
%
%   FS must contain fields
%
%   FS.ClimateSpaceRev
%   FS.CropNames
%   FS.ClimateSpaceN
%   FS.WetFlag
%   FS.PercentileForMaxYield;
%
%   Optional Field
%   FS.DataYear
%
%  example
%   FS.ClimateSpaceRev='K';
%   FS.CropNames='maize';
%   FS.ClimateSpaceN=10;
%   FS.WetFlag='prec';
%   FS.PercentileForMaxYield=90;
%   FS.DataYear=2000;
%   OutputDirBase=[iddstring '/ClimateBinAnalysis/YieldGap/'];
%   FileName=YieldGapFunctionFileNames_CropName(FS,OutputDirBase);
%

try
    crop=FS.CropNames;
catch
    crop=FS.cropnames;
end
cropname=MakeSafeString(char(crop));

[GDDBase,GDDTmaxstr]=GetGDDBaseTemp(cropname);



% Revision
switch FS.ClimateSpaceRev
    case 'K'
        ClimateSpaceDescription='AreaFilteredClimateSpace';
        SubDir='AreaFiltered';
    case 'L'
        ClimateSpaceDescription='AreaFilteredClimateSpaceWithSoil';
        SubDir='AreaFiltered_Soil';
    case 'H'
        ClimateSpaceDescription='ContourFilteredClimateSpace';
        SubDir='ContourFiltered';
    case 'N'
        ClimateSpaceDescription='ContourFilteredClimateSpace';
        SubDir='ContourFiltered';
    case 'P'
        ClimateSpaceDescription='ContourFilteredClimateSpace';
        SubDir='ContourFiltered';
    case 'M'
        ClimateSpaceDescription='ContourFilteredClimateSpaceWithSoil';
        SubDir='ContourFiltered_Soil';
    case 'Q'
        ClimateSpaceDescription='ContourFilteredClimateSpace';
        SubDir='ContourFiltered';
    case 'R'
        ClimateSpaceDescription='AreaFilteredClimateSpace_SymmetricQuantileBins';
        SubDir='SymmetricQuantileBins';
    otherwise
        warning(['using a default ClimateSpaceDescription in ' mfilename])
        ClimateSpaceDescription=['ClimateSpaceRev'  FS.ClimateSpaceRev];
        SubDir='AltRevision';
end

%%
try
    SystemGlobals
    switch FS.ClimateSpaceRev
         case 'G'
               FileName=[OutputDirBase '/' SubDir '/YieldGap_CropNo' int2str(FS.CropNo) ...
                   'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                '_ClimateSpaceRev'  FS.ClimateSpaceRev ...
                '_soilrev' FS.csqirev ...
                '_' num2str(FS.ClimateSpaceN)  '_' FS.WetFlag '.mat'];
        case {'R','Q'}
            
             if isfield(FS,'DataYear')
                FileName=[OutputDirBase '/' SubDir '/YieldGap_' cropname '_' ...
                    int2str(FS.DataYear) '_' ...
                    'BaseGDD_' GDDBase '_' 'MaxGDD_' num2str(GDDTmaxstr) ...
                    'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                    '_'  ClimateSpaceDescription ...
                    '_' num2str(FS.ClimateSpaceN) 'x' num2str(FS.ClimateSpaceN) '_' FS.WetFlag '.mat'];
            else
                FileName=[OutputDirBase '/' SubDir '/YieldGap_' cropname '_' ...
                    'BaseGDD_' GDDBase '_' 'MaxGDD_' num2str(GDDTmaxstr) ...
                    'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                    '_'  ClimateSpaceDescription ...
                    '_' num2str(FS.ClimateSpaceN) 'x' num2str(FS.ClimateSpaceN) '_' FS.WetFlag '.mat'];
            end
            
            
            
        otherwise  %{
            if isfield(FS,'DataYear')
                FileName=[OutputDirBase '/' SubDir '/YieldGap_' cropname '_' ...
                    int2str(FS.DataYear) '_' ...
                    'BaseGDD_' GDDBase '_' ...
                    'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                    '_'  ClimateSpaceDescription ...
                    '_' num2str(FS.ClimateSpaceN) 'x' num2str(FS.ClimateSpaceN) '_' FS.WetFlag '.mat'];
            else
                FileName=[OutputDirBase '/' SubDir '/YieldGap_' cropname '_' ...
                    'BaseGDD_' GDDBase '_' ...
                    'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                    '_'  ClimateSpaceDescription ...
                    '_' num2str(FS.ClimateSpaceN) 'x' num2str(FS.ClimateSpaceN) '_' FS.WetFlag '.mat'];
            end
            
    end
    
    DirName=[OutputDirBase '/' SubDir '/'];
catch
    error(['Prob. defining filename.  need CropNo, ClimateSpaceRev, ClimateSpaceN']);
end