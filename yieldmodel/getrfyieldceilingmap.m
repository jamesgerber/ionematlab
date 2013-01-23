function rfycmap = getrfyieldceilingmap(cropname, saveflag, ...
    subdirname)

% function rfycmap = getrfyieldceilingmap(cropname, saveflag, ...
%     subdirname)
% 
% A function to make rainfed yield ceiling map from the yield model output.
% This take the yc_rf calculated by the model, and place it over the
% climate bin. Where we don't have a yc_rf parameterized, this code will
% grab the 95th percentile yield from the 10x10 bin output.
% 
% saveflag and subdirname are optional inputs
%
% saveflag = 1 will save the map in the current directory under the
%     rfyieldceilingmaps subdirectory
% subdirname = if you want another subdirectory level, input it here with a
%     slash, e.g. '/Ag'

% check to see if we will save / look for saved data
if nargin<2
    saveflag = 0;
    subdirname = '';
end

dirpath = [pwd subdirname '/rfyieldceilingmaps'];

% check for saved data if called to do so
if exist([dirpath '/' cropname '_rfycmap.mat'],'file')>0 && (saveflag == 1)
    % load up saved data
    load([dirpath '/' cropname '_rfycmap.mat']);

else
    
    % open yield gap output - 95th percentile yields
    potpercentstr = '95';
    climspace = '10x10';
    disp(['loading ' cropname ' ' climspace ' ' potpercentstr ...
        'th percentile potential yields and climate mask']);
    FNS.ClimateSpaceRev = 'P';
    FNS.ClimateSpaceN=10;
    FNS.WetFlag='prec';
    OutputDirBase=[iddstring 'ClimateBinAnalysis/YieldGap'];
    FNS.CropNames = cropname;
    FNS.PercentileForMaxYield=potpercentstr;
    FileName=YieldGapFunctionFileNames_CropName(FNS,OutputDirBase);
    load(FileName);
    
    % load model info
    filestr = [iddstring 'ClimateBinAnalysis/YieldModel/' ...
        cropname '_m3yieldmodeldata_VL_MBM.csv'];
    MS = ReadGenericCSV(filestr);
    
    % initialize yield ceiling map and cycle through bins
    rfycmap = zeros(4320,2160);
    for b=1:100
        potyieldbin = OS.VectorOfPotentialYields(b);
        
        % if we have yc_rf parameterized, grab and put into the map
        yc_rf_bin = str2double(MS.yc_rf{b});
        if ~isnan(yc_rf_bin) && yc_rf_bin<potyieldbin
            
            rfycmap(OS.ClimateMask==b) = yc_rf_bin;
            
            % if not, grab from potential yield map
        else
            rfycmap(OS.ClimateMask==b) = potyieldbin;
        end
    end
    
    if saveflag == 1
        mkdir(dirpath)
        save([dirpath '/' cropname '_rfycmap'],'rfycmap')
    end
end
