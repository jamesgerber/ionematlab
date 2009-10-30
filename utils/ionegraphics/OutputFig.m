function OutputFig(Hfig,FileName)
% OutputFig - output a figure as a .png
%
% SYNTAX
% OutputFig('Force') will force priting w/o querying user.
%
% OutputFig('Force','FileName')
% OutputFig(gcf,'FileName')

if nargin==0
    Hfig=gcf;
    ForcePlots=0;
end

if nargin>0
    if ischar(Hfig)
        ForcePlots=1;
        Hfig=gcf;
    else
        ForcePlots=0;
    end
end

if nargin==2
    InitGuess=FileName;
else
    InitGuess=get(get(gca,'Title'),'String');
end


figure(Hfig); %Make sure this figure is on top. 

try

    InitGuess=strrep(InitGuess,' ','_');
    InitGuess=strrep(InitGuess,'.','_');
    InitGuess=strrep(InitGuess,':','_');
    InitGuess=strrep(InitGuess,'/','_');
    InitGuess=strrep(InitGuess,',','_');
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
print('-dpng',FileName);
%print('-djpeg90',[FileName]);

set(Hfig,'PaperPositionMode',ppm)

showui;