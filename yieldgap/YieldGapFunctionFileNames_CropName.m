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
%  example
%   FS.ClimateSpaceRev='K';
%   FS.CropNames='maize';
%   FS.ClimateSpaceN=10;
%   FS.WetFlag='prec';
%   FS.PercentileForMaxYield=90;
%   OutputDirBase=[iddstring '/ClimateBinAnalysis/YieldGap/'];
%   FileName=YieldGapFunctionFileNames_CropName(FS,OutputDirBase);
%

try
    crop=FS.CropNames;
catch
    crop=FS.cropnames;
end
cropname=makesafestring(char(crop));

GDDBase=GetGDDBaseTemp(cropname);

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
    case 'M'
        ClimateSpaceDescription='ContourFilteredClimateSpaceWithSoil';
        SubDir='ContourFiltered_Soil';
    otherwise
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
        otherwise  %{
              FileName=[OutputDirBase '/' SubDir '/YieldGap_' cropname '_' ...
                  'BaseGDD_' GDDBase '_' ...
                'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                '_'  ClimateSpaceDescription ...
                '_' num2str(FS.ClimateSpaceN) 'x' num2str(FS.ClimateSpaceN) '_' FS.WetFlag '.mat'];
    end
    
    DirName=[OutputDirBase '/' SubDir '/'];
catch
    error(['Prob. defining filename.  need CropNo, ClimateSpaceRev, ClimateSpaceN']);
end