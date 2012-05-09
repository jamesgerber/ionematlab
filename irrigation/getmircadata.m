function [mircadata] = getmircadata(cropname, datatype)

% [mircadata] = getmircadata(cropname, mircadatatype)
%
% A function to call MIRCA2000 monthly rainfed grids, monthly irrigated
% grids, average % irrigated in a grid cell over the growing season, or the
% maximum % irrigated in a grid cell during a major growing month (defined
% as having at least 75% of the maximum crop cultivated area in that grid
% cell).
%
% cropname: lowercase crop name (fao/monfreda)
% mircadatatype valid options:
%     - rainfed (12 monthly rainfed grids)
%     - irrigated (12 monthly irrigated grids)
%     - avgpercirr
%     - irrmax75

switch datatype
    case 'rainfed'
        dtcode = 1;
    case 'irrigated'
        dtcode = 2;
    case 'avgpercirr'
        dtcode = 3;
    case 'irrmax75'
        dtcode = 4;
end

% rainfed, irrigated, and avgpercirr grids are stored in the original
% MIRCA2000 processed .nc file
if dtcode < 4
    
    % open mirca crop number lookup table
    mircatable = ReadGenericCSV([iddstring ...
        'MIRCA2000_processed/mircacroptable.csv']);

    % open irrigation data
    tmp = strmatch(cropname, mircatable.mircacrop);
    mircanumber = mircatable.mircanumber(tmp);
    ncid = netcdf.open([iddstring '/Irrigation/MIRCA2000_processed/mirca2000_crop'...
        num2str(mircanumber) '.nc'], 'NC_NOWRITE');
    
    % open the right variable
    switch dtcode
        case 1
            mircadata = netcdf.getVar(ncid,4);
        case 2
            mircadata = netcdf.getVar(ncid,5);
        case 3
            mircadata = netcdf.getVar(ncid,6);
    end
    
% irrmax75 exists separately as a .mat file in a subdirectory    
elseif dtcode == 4
    
    filename = [iddstring '/Irrigation/MIRCA2000_processed/maxirrsummarymaps/' ...
        cropname '_maxirr75.mat'];
    load(filename)
    mircadata = totalmaxirr_75areaconstraint;

end