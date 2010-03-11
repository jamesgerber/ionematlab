function NiceSurf(Data,Title,Units,coloraxis,colormap,FileName);
% NICESURF Data MissingValue,ColorMap,LowerMap
% 
% Syntax:
%    NiceSurf(Data,Title,Units,coloraxis,colormap,FileName);
%
%
%  Example
%
%  SystemGlobals
%  S=OpenNetCDF([IoneDataDir '/Crops2000/crops/maize_5min.nc'])
%
%  Area=S.Data(:,:,1);
%  Yield=S.Data(:,:,2);
%   NiceSurf(Yield,'Yield Maize','tons/ha',[0 12],'revsummer','YieldTestPlot1')
%   NiceSurf(Yield,'Yield Maize','tons/ha',[],'revsummer','YieldTestPlot2')
if nargin==0
    help(mfilename)
    return
end

if isstruct(Data)
    MissingValue=GetMissingValue(Data);   
    [Long,Lat,Data,Units,DefaultTitleStr,NoDataStructure]=ExtractDataFromStructure(Data);
    Data(Data==MissingValue)=NaN;
end

if nargin<2
    Title='Data';
end

if nargin<3
    Units='';
end

if nargin<4
    coloraxis=[];
end

if nargin<5
    colormap=[];
end

if nargin<6
    FileName='';
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
    coloraxis=[min(tmp01) hiaverage];
    
  %  colormax=max(tmp01);
  %  colormin=min(tmp01);
  %  coloraxis=[colormin colormax];
end


Data=double(Data);


UpperMap='white';
LowerMap='robin'



cmax=coloraxis(2);
cmin=coloraxis(1);
minstep= (cmax-cmin)*.001;

Data(Data>cmax)=cmax;
Data(cmin>Data)=cmin;



OceanVal=coloraxis(1)-minstep;



% first, get any no-data points
land=LandMaskLogical;
ii=(LandMaskLogical==0);
Data(ii)=OceanVal;

% no make no-data points above color map to get 'UpperMap' (white)
Data(isnan(Data))=cmax+2*minstep;


IonESurf(Data);
%title(Title);
finemap(colormap,LowerMap,UpperMap);

caxis([(cmin-minstep)  (cmax+minstep)]);
AddCoasts(0.1);
gridm

fud=get(gcf,'UserData');
set(gcf,'position',[ 218   618   560   380]);
set(fud.DataAxisHandle,'Visible','off');
set(fud.DataAxisHandle,'Position',[0.00625 .2 0.9875 .7]);
set(fud.ColorbarHandle,'Visible','on');
%set(fud.ColorbarHandle,'Position',[0.1811+.1 0.08 0.6758-.2 0.0568])
set(fud.ColorbarHandle,'Position',[0.09+.05 0.10 (0.6758-.1+.18) 0.02568])

hcbtitle=get(fud.ColorbarHandle,'Title');
 set(hcbtitle,'string',[' ' Units ' '])
set(hcbtitle,'fontsize',12);
set(hcbtitle,'fontweight','bold');
%cblabel(Units)



set(fud.DataAxisHandle,'Visible','off');%again to make it current
ht=text(0,pi/2,Title);
set(ht,'HorizontalAlignment','center');
set(ht,'FontSize',14)
set(ht,'FontWeight','Bold')

hideui

if ~isempty(FileName)
    OutputFig('Force',FileName);
    if length(get(allchild(0)))>4
        close(gcf)
    end
end


