function [FileName,DirName]=YieldGapFunctionFileNames(FS,OutputDirBase);
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
%   FS.CropNo
%   FS.ClimateSpaceN
%   FS.WetFlag
%   FS.PercentileForMaxYield;

[DS,NS]=CSV_to_structure('crops.csv');

% cropname
j=FS.CropNo;
cropname=NS.col1{j};
cropname=makesafestring(cropname);

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
        case {'F','H','I','J','K','L','M'}
            FileName=[OutputDirBase '/' SubDir '/YieldGap_' cropname '_' ...
                'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                '_'  ClimateSpaceDescription ...
                '_' num2str(FS.ClimateSpaceN) 'x' num2str(FS.ClimateSpaceN) '_' FS.WetFlag '.mat'];
  
        case 'G'
               FileName=[OutputDirBase '/' SubDir '/YieldGap_CropNo' int2str(FS.CropNo) ...
                   'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                '_ClimateSpaceRev'  FS.ClimateSpaceRev ...
                '_soilrev' FS.csqirev ...
                '_' num2str(FS.ClimateSpaceN)  '_' FS.WetFlag '.mat'];
    end
    
    DirName=[OutputDirBase '/' SubDir '/'];
catch
    error(['Prob. defining filename.  need CropNo, ClimateSpaceRev, ClimateSpaceN']);
end