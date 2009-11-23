function [Long,Lat,FiveMinGridCellAreas]=GetFiveMinGridCellAreas;
% determine area in centered grids that are 5min x 5min
%
%

SystemGlobals

[Long,Lat,FiveMinGridCellAreas]=OpenNetCDF(AREAMAP_5MIN);

%  I tried to write this function myself, but this didn't agree with a file
%  provided by Rachel Licker (Sage) so now I'm just opening her file.
% 
% tmp=linspace(-1,1,2*4320+1);
% Long=180*tmp(2:2:end).';
% tmp=linspace(-1,1,2*2160+1);
% Lat=-90*tmp(2:2:end).';
% EarthCircumference=40075;
% FiveMinGridAreaAtEquator=EarthCircumference.^2*(1/360/12)^2*1e2; %1e2 is sq km to ha
% 
% FiveMinGridCellAreasha=FiveMinGridAreaAtEquator*ones(size(Long))*cosd(Lat.');
