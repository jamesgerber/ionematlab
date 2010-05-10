function NiceSurf(Data,NSS);
% NICESURF Data MissingValue,ColorMap,LowerMap
% 
% Syntax:
%    NiceSurf(Data,STRUCT);
%    NiceSurf(Long,Lat,Data,STRUCT);
%    NiceSurf(DataStruct,STRUCT);
%
%  
%  Struct can have the following fields [Default]
%
%   NSS.coloraxis=coloraxis
%
%   where coloraxis can have the following forms:
%   [] (empty vector) 
%           coloraxis from data minimum to data maximum
%   [f]   where f is between 0 and 1 
%           coloraxis from data minimum to 100*f percentile maximum
%           This syntax useful if there are a few outliers
%   [0]     coloraxis from -max(abs(Data)) to +max(abs(Data))
%           This syntax is useful for aligning 0 with the center of a
%           colorbar
%   [cmin cmax]
%           coloraxis from cmin to cmax
%
%
%
%   NSS.Units ['']
%   NSS.TitleString
%   NSS.FileName
%   NSS.ColorMap
%   NSS.LongLatBox
%
%
%  Example
%
%  SystemGlobals
%  S=OpenNetCDF([IoneDataDir '/Crops2000/crops/maize_5min.nc'])
%
%  Area=S.Data(:,:,1);
%  Yield=S.Data(:,:,2);
%   NSS.Units='tons/ha';
%   NSS.TitleString='Yield Maize';
%   NSS.FileName='YieldTestPlot4';
%   NSS.ColorMap='revsummer'
%   NSS.LongLatBox=[];
%   NSS.coloraxis=[];
%
%   NiceSurfGeneral(Yield,NSS)
%
%   NSS.LongLatBox=[-120 -80 10 35];
%   NSS.coloraxis=[];
%
%   NiceSurfGeneral(Yield,NSS)
%   NiceSurf(Yield,'Yield Maize','tons/ha',[],'revsummer','YieldTestPlot2')
%   NiceSurf(Yield,'Yield Maize','tons/ha',[0 12],'revsummer','YieldTestPlot1')
%   NiceSurf(Yield,'Yield Maize','tons/ha',[0.99],'revsummer','YieldTestPlot3')
%
if nargin==0
    help(mfilename)
    return
end

if nargin==2
    [Long,Lat]=InferLongLat(Data);
end


if isstruct(Data)
    MissingValue=GetMissingValue(Data);   
    [Long,Lat,Data,Units,DefaultTitleStr,NoDataStructure]=ExtractDataFromStructure(Data);
    Data(Data==MissingValue)=NaN;
end




units='';
titlestring='';
filename='';
colormap='summer';
longlatbox=[-180 180 -90 90];
coloraxis=[];

%%now pull thins out of structure

a=fieldnames(NSS);
for j=1:length(a)
    disp([ lower(a{j}) '=NSS.' a{j} ';'])
    eval([ lower(a{j}) '=NSS.' a{j} ';'])
end

ii=find(abs(Data) >= 1e9);
if length(ii)>0
    disp([' Found elements >= 1E9.  replacing with NaN. '])
    Data(ii)=NaN;
end

if length(coloraxis)<2
    
    
    if length(coloraxis==1)
        ii=find(Data~=0  & isfinite(Data));
        tmp01=Data(ii);
        if coloraxis==0
            coloraxis=[-(max(abs(tmp01))) (max(abs(tmp01)))]
        else
            
            
            
            f=coloraxis;
            
            tmp01=sort(tmp01);
            loval=min(tmp01);
            hiaverage=tmp01(round(length(tmp01)*f));
            coloraxis=[loval hiaverage];
        end
     else
        ii=find(isfinite(Data));
        tmp01=Data(ii);
        coloraxis=[min(tmp01) max(tmp01)]
    end
    
    
    % make sure that coloraxis isn't really close to zero but not quite.
    % If so, then pull it down to zero.
    
    c1=coloraxis(1);
    c2=coloraxis(2);
    
    if c1 < (c2-c1)/10
        coloraxis(1)=min(c1,0);
    end

    
    
    
end


Data=double(Data);


UpperMap='white';
LowerMap='emblue'



cmax=coloraxis(2);
cmin=coloraxis(1);
minstep= (cmax-cmin)*.001;

Data(Data>cmax)=cmax;
Data(cmin>Data)=cmin;



OceanVal=coloraxis(1)-minstep;


if numel(Data)==4320*2160
    % first, get any no-data points
    land=LandMaskLogical;
    ii=(land==0);
    Data(ii)=OceanVal;
else
   % problem ... this is not 5minute data
   land=LandMaskLogical(Data);
   ii=(land==0);
   Data(ii)=OceanVal;
end
% no make no-data points above color map to get 'UpperMap' (white)
Data(isnan(Data))=cmax+2*minstep;


IonESurf(Data);
%title(Title);
finemap(colormap,LowerMap,UpperMap);

caxis([(cmin-minstep)  (cmax+minstep)]);
AddCoasts(0.1);

fud=get(gcf,'UserData');
if fud.MapToolboxFig==1
    gridm
else
    grid on
end
set(gcf,'position',[ 218   618   560   380]);
set(fud.DataAxisHandle,'Visible','off');
set(fud.DataAxisHandle,'Position',[0.00625 .2 0.9875 .7]);
set(fud.ColorbarHandle,'Visible','on');
%set(fud.ColorbarHandle,'Position',[0.1811+.1 0.08 0.6758-.2 0.0568])
set(fud.ColorbarHandle,'Position',[0.09+.05 0.10 (0.6758-.1+.18) 0.02568])







if ~isequal(longlatbox,[-180 180 -90 90])
   
    g1=longlatbox(1);
    g2=longlatbox(2);
    t1=longlatbox(3);
    t2=longlatbox(4);
    
    
    
    if fud.MapToolboxFig==1
    
    trustmatlab=1
    
    if trustmatlab==1
    
        setm(fud.DataAxisHandle,'Origin',...
            [(t1+t2)/2 (g1+g2)/2 0])
        setm(fud.DataAxisHandle,'FLonLimit',[g1 g2]-mean([g1 g2]))
        setm(fud.DataAxisHandle,'FLatLimit',[t1 t2]-mean([t1 t2]))
    else
        setm(fud.DataAxisHandle,'Origin',...
            [0 0 0])
          setm(fud.DataAxisHandle,'FLonLimit',[g1 g2])
          setm(fud.DataAxisHandle,'FLatLimit',[t1 t2])
    end
    
    else
        % no mapping toolbox.  let's make things easy.
        
        
        
        
    end
    
    
end


set(fud.DataAxisHandle,'Visible','off');%again to make it current
ht=text(0,pi/2,titlestring);
set(ht,'HorizontalAlignment','center');
set(ht,'FontSize',14)
set(ht,'FontWeight','Bold')

hcbtitle=get(fud.ColorbarHandle,'Title');
 set(hcbtitle,'string',[' ' units ' '])
set(hcbtitle,'fontsize',12);
set(hcbtitle,'fontweight','bold');
%cblabel(Units)

hideui

if ~isempty(filename)
    OutputFig('Force',filename);
    if length(get(allchild(0)))>4
        close(gcf)
    end
end


