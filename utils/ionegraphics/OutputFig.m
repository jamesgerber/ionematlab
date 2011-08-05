function FileName=OutputFig(Hfig,FileName,ResFlag,transparent)
% OutputFig - output a figure as a .png
%
% SYNTAX
% OutputFig('Force') will force priting w/o querying user.
% OutputFig(gcf,'FileName','-r300',1) will make background transparent
% OutputFig('Force','FileName')
% OutputFig('Force','FileName','-r150')
% OutputFig(gcf,'FileName')

if nargin==0
    Hfig=gcf;
    ForcePlots=0;
end

if nargin>0
    if ischar(Hfig)
        switch(Hfig)
            case {'force','Force'}
                ForcePlots=1;
                Hfig=gcf;
            case 'Initialize'
                uicontrol('String','OutputFig','Callback', ...
                    'OutputFig;','position',NextButtonCoords);  
                Hfig=gcf;
                ForcePlots=0;
                return
            otherwise
                error('don''t know this argument to Hfig')
        end
    else
        ForcePlots=0;
    end
end

if nargin>1
    InitGuess=FileName;
    MakeSafe=0;
else
    InitGuess=get(get(gca,'Title'),'String');
    MakeSafe=1;
    
    if iscell(InitGuess)
        InitGuess=InitGuess{1};
    end
    
end

if nargin<3
    ResFlagcheck=personalpreferences('printingres');
    if isempty(ResFlagcheck)
        ResFlag='-r300';
    else
        ResFlag=ResFlagcheck;
    end
end

if (nargin>=4&&transparent)
    repeat=1;
    while repeat
    bgc=[rand rand rand];
    colors=colormap;
    tmp(:,1)=closeto(bgc(1),colors(:,1),.05);
    tmp(:,2)=closeto(bgc(2),colors(:,2),.05);
    tmp(:,3)=closeto(bgc(3),colors(:,3),.05);
    repeat=max(sum(tmp,2)==3);
    end
    set(gcf,'InvertHardcopy','off')
end
    

% Is this figure made by IonESurf?  If so, expand the data axis
fud=get(Hfig,'UserData');


if isequal(get(Hfig,'tag'),'IonEFigure')
    storepos=get(fud.DataAxisHandle,'position');
    set(fud.DataAxisHandle,'position',[0.025 .2 0.95 .7])
end

figure(Hfig); %Make sure this figure is on top. 


try
    InitGuess=strrep(InitGuess,' ','');
        
    if MakeSafe==1
        InitGuess=strrep(InitGuess,'.','_');
        InitGuess=strrep(InitGuess,':','_');
        InitGuess=strrep(InitGuess,'/','_');
        InitGuess=strrep(InitGuess,',','_');
    end
catch
    InitGuess='Figure';
end


try
    SaveFileType=personalpreferences('GraphicsFileType');
catch
    SaveFileType='-dpng';
end


if ForcePlots==0
    [filename,pathname]=uiputfile('*','Choose File Name',InitGuess);
    FileName=[pathname  filename];
else
    FileName=InitGuess;
end
    
    
hideui;
ppm=get(gcf,'PaperPositionMode');
set(gcf,'PaperPositionMode','auto');

drawnow;

disp(['Saving ' FileName]);

print(SaveFileType,ResFlag,FileName);

set(Hfig,'PaperPositionMode',ppm);

if isequal(get(Hfig,'tag'),'IonEFigure')
    set(fud.DataAxisHandle,'position',storepos);
end

if (nargin>=4&&transparent)
    im=imread(FileName);
    transparent=im(:,:,1)==im(1,1,1)&im(:,:,2)==im(1,1,2)&im(:,:,3)==im(1,1,3);
    imwrite(im,FileName,'Alpha',double(~transparent));
end
    
showui;