function [Long,Lat,FiveMinGridCellAreas]=GetFiveMinGridCellAreas;
% GetFiveMinGridCellAreas determine area in centered grids that are 5min x 5min
%
%  Syntax
%      [Long,Lat,FiveMinGridCellAreas]=GetFiveMinGridCellAreas;
%
%   assumes a perfectly spherical earth of radius 6371km, which is mean
%   radius of earth





 tmp=linspace(-1,1,2*4320+1);
 Long=180*tmp(2:2:end).';
 tmp=linspace(-1,1,2*2160+1);
 Lat=-90*tmp(2:2:end).';
 %EarthCircumference=40075;
 % EarthCircumference=40024;
  EarthCircumference=6371*2*pi;  %source: wikipedia
  
  
  
 FiveMinGridAreaAtEquator=EarthCircumference.^2*(1/360/12)^2*1e2; %1e2 is sq km to ha
% 
 FiveMinGridCellAreasha=FiveMinGridAreaAtEquator*ones(size(Long))*cosd(Lat.');
FiveMinGridCellAreas=FiveMinGridCellAreasha;
 return
 
 
 %SystemGlobals

%[Long,Lat,FiveMinGridCellAreas]=OpenNetCDF(AREAMAP_5MIN);

%  I tried to write this function myself, but this didn't agree with a file
%  provided by Rachel Licker (Sage) so now I'm just opening her file.
% 
 
 plot(1:2160,FiveMinGridCellAreasha(1,:),1:2160,FiveMinGridCellAreas(1,:));
plot(1:2160,FiveMinGridCellAreasha(1,:)-FiveMinGridCellAreas(1,:));

Rachel=max(max(FiveMinGridCellAreas));
Geom=max(max(FiveMinGridCellAreasha));

NewCirc=40075*sqrt(Rachel/Geom)