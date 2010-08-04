function FileName=YieldGapFunctionFileNames(FS,OutputDirBase);
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
    case 'L'
        ClimateSpaceDescription='AreaFilteredClimateSpaceWithSoil';
    case 'H'
        ClimateSpaceDescription='ContourFilteredClimateSpace';
    case 'M'
        ClimateSpaceDescription='ContourFilteredClimateSpaceWithSoil';
    otherwise
        ClimateSpaceDescription=['ClimateSpaceRev'  FS.ClimateSpaceRev];
end

%%
try
    SystemGlobals
    switch FS.ClimateSpaceRev
        case {'F','H','I','J','K','L','M'}
            FileName=[OutputDirBase '/YieldGap_' cropname '_' ...
                'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                '_'  ClimateSpaceDescription ...
                '_' num2str(FS.ClimateSpaceN) 'x' num2str(FS.ClimateSpaceN) '_' FS.WetFlag '.mat'];
  
        case 'G'
               FileName=[OutputDirBase '/YieldGap_CropNo' int2str(FS.CropNo) ...
                   'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                '_ClimateSpaceRev'  FS.ClimateSpaceRev ...
                '_soilrev' FS.csqirev ...
                '_' num2str(FS.ClimateSpaceN)  '_' FS.WetFlag '.mat'];
    end
    
catch
    error(['Prob. defining filename.  need CropNo, ClimateSpaceRev, ClimateSpaceN']);
end