function FileName=OutputFig(Hfig,FileName,ResFlag)
% OutputFig - output a figure as a .png
%
% SYNTAX
% OutputFig('Force') will force priting w/o querying user.
% 
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
    ResFlag='-r200';
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



if ForcePlots==0
    [filename,pathname]=uiputfile('*.png','Choose File Name',InitGuess);
    FileName=[pathname  filename];
else
    FileName=InitGuess;
end
    
    
hideui;
ppm=get(gcf,'PaperPositionMode');
set(gcf,'PaperPositionMode','auto');

drawnow;

disp(['Saving ' FileName '.png']);
print('-dpng',ResFlag,FileName);

set(Hfig,'PaperPositionMode',ppm)

if isequal(get(Hfig,'tag'),'IonEFigure')
    set(fud.DataAxisHandle,'position',storepos)
end

showui;