function NiceSurf(Data,Title,FileName,coloraxis,colormap);
% NICESURF Data MissingValue,ColorMap,LowerMap
% 
% Syntax:
%    NiceSurf(Data,Title,FileName,coloraxis,colormap);
%
%
%  Example
%
%  SystemGlobals
%  S=OpenNetCDF([IoneDataDir '/Crops2000/crops/maize_5min.nc'])
%
%  Area=S.Data(:,:,1);
%   NiceSurf(OS.Yield,'Yield Maize','savefilename',[0 12],'revsummer')


if isstruct(Data)
    MissingValue=GetMissingValue(Data);   
    [Long,Lat,Data,Units,DefaultTitleStr,NoDataStructure]=ExtractDataFromStructure(Data);
    Data(Data==MissingValue)=NaN;
end
if nargin<2
    Title='Data';
    FileName='outputfig.tif';
end
if nargin<3
        FileName='outputfig.tif';
end

if nargin<4
    coloraxis=[];
end

ii=find(Data >= 1e9);
if length(ii)>0
    disp([' Found elements >= 1E9.  replacing with NaN. '])
    Data(ii)=NaN;
end


if isempty(coloraxis)
    ii=find(Data~=0  & isfinite(Data));
    tmp01=Data(ii);

    tmp01=sort(tmp01);

    loaverage=tmp01(round(length(tmp01)*.02));
    hiaverage=tmp01(round(length(tmp01)*.98));
    coloraxis=[loaverage hiaverage];
end

if nargin<5
    colormap='jgbrownyellowgreen';
end

Data=double(Data);


UpperMap='white';
LowerMap='robin'

OceanVal=coloraxis(1)-.1;

cmax=coloraxis(2);
cmin=coloraxis(1);
minstep= (cmax-cmin)*.001;

Data(Data>cmax)=cmax;
Data(cmin>Data)=cmin;




% first, get any no-data points
land=LandMaskLogical;
ii=(LandMaskLogical==0);
Data(ii)=OceanVal;

% no make no-data points above color map to get 'UpperMap' (white)
Data(isnan(Data))=cmax+minstep;


IonESurf(Data);
finemap(colormap,LowerMap,UpperMap);

caxis([(cmin-minstep)  (cmax-minstep)]);
AddCoasts(0.1);
gridm

fud=get(gcf,'UserData');
set(gcf,'position',[ 218   618   560   380]);
set(fud.DataAxisHandle,'Visible','off');
set(fud.DataAxisHandle,'Position',[0.00625 .2 0.9875 .7]);
set(fud.ColorbarHandle,'Visible','on');
%set(fud.ColorbarHandle,'Position',[0.1811+.1 0.08 0.6758-.2 0.0568])
set(fud.ColorbarHandle,'Position',[0.09+.05 0.14 (0.6758-.1+.18) 0.02568])

hideui