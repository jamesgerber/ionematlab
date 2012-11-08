function [Long,Lat,Raster]=ShapeFileToRaster(S,FieldName,MatrixTemplate,plotflag)
% ShapefileToRaster - Turn a shapefile into a 5 minute matrix
%
%  Syntax:
%      [Long,Lat,RASTER]=ShapeFileToRaster(S,FIELD,MATRIXTEMPLATE,PLOTFLAG);
%
%      S is a vector of structures with the fields "X" "Y" and
%      FIELD.  This function most useful when S comes from a SHAPEREAD command
%      executed on a .shp file.  
%      RASTER will be a matrix corresponding to the values of the field
%      FIELD.  
%
%      if PLOTFLAG is 1, a plot will be made as things go alond
%
%      Possible problems:
%      * Not all shaperead commands result in an X,Y that are in lat/long.
%      Function would fail in this case
%      * If polygons overlap, then results will be arbitrary 
%      * Function can be very slow
%      * This function is based on the function inpolygon
%      I don't know how well this would behave if we tried to
%      operate it on a shapefile which included a bunch of lakes.  
%
%    Example
%   S=shaperead([iddstring ...
%   'AdminBoundary2005/Vector_ArcGISShapefile/gladmin_m3lcover'])
%
%   %make a smaller shapefile just for demonstrating this code
%  
%   
%    NS=S(1:800);
%   
%   for j=1:800
%    NS(j).NumericalField=j;
%   end
%
%   template=datablank(0,'30min');
%
%   [Long,Lat,Raster]=ShapeFileToRaster(NS,'NumericalField',template,0);

switch nargin
    case 0
        help(mfilename)
        return
    case 1
        %debugging only.   % commented out debuggin lines below
        FieldName='d';
        plotflag=0;
        MatrixTemplate=ones(4320,2160);
    case 2
        plotflag=0;
        MatrixTemplate=ones(4320,2160);
    case 3
        plotflag=0;
end

Matrix=0*ones(size(MatrixTemplate));
[Long,Lat]=InferLongLat(Matrix);

[LatGrid,LongGrid]=meshgrid(Lat,Long);

if plotflag==1
    figure(11)
    clf
    axis([-180 180 -90 90])
    hold on
end

hh=waitbar(0,'working ... ')
for j=1:length(S);
    
   % if int(j/length(
        waitbar(j/length(S),hh);
    %end
    %for j=120;
    xx=S(j).X;
    yy=S(j).Y;
    
    xx(2:end+1)=xx;
    xx(1)=NaN;
    yy(2:end+1)=yy;
    yy(1)=NaN;
    
    
    kk=find(isnan(xx));
    if length(kk)==1
        error('This S vector isn''t quite working out ... ')
    end
    
%    disp(['Working on ' S(j).ID '(' num2str(j) ' out of ' num2str(length(S)) ...
%        ').  ' num2str(length(kk)-1) ' regions.']);
    
    LogicalCountryMatrix=logical(zeros(size(MatrixTemplate)));
    
    for k=2:length(kk);%
        
        x=xx(kk(k-1)+1:kk(k)-1);
        y=yy(kk(k-1)+1:kk(k)-1);
        
        if plotflag==1
            figure(11)
            plot(xx,yy,x,y,'r')
            hold on
            drawnow
            PlotMatrix=NaN*ones(size(MatrixTemplate));
            LogicalPlotMatrix=0*ones(size(MatrixTemplate));
        end
        
        ii=find(LongGrid > min(x)-.1 & LongGrid < max(x)+.1 & ...
            LatGrid > min(y)-.1 & LatGrid < max(y)+.1);
        
        [IN ON]=inpolygon(LongGrid(ii),LatGrid(ii),x,y);
        
        %     Matrix(ii)=(IN | ON)*getfield(S(j),FieldName);
        
        LogicalCountryMatrix(ii)=     LogicalCountryMatrix(ii) | IN | ON;
        
        
        if plotflag==1
            LogicalPlotMatrix(ii)=LogicalPlotMatrix(ii) | IN;
            PlotMatrix(ii)=IN;
            PlotMatrix(ii(find(IN==0)))=NaN;
            iiLong=find(Long > min(x)-.1 & Long < max(x)+.1);
            iiLat=find(Lat > min(y)-.1 & Lat < max(y)+.1);
            figure(11)
            hold on
            tmp=double(LogicalPlotMatrix);
            tmp(find(tmp==0))=NaN;
            surface(Long(iiLong),Lat(iiLat),tmp(iiLong,iiLat).');
            hold on
            drawnow
            shading flat
        end
    end  % end of k loop over regions within each country
    % end of country loop
    jj=find(LogicalCountryMatrix);
  %  if (FieldName~='d')
        Matrix(jj)=getfield(S(j),FieldName);
   % else
   %     Matrix(jj)=1;
   % end
end % end of j loop over countries


Raster=Matrix;
