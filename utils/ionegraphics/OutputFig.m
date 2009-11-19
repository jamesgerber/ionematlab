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
        switch(Hfig)
            case {'force','Force'}
                ForcePlots=1;
                Hfig=gcf;
            case 'Initialize'
                uicontrol('String','OutputFig','Callback', ...
                    'OutputFig;','position',[730 10 80 20]);  
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

if nargin==2
    InitGuess=FileName;
    MakeSafe=0;
else
    InitGuess=get(get(gca,'Title'),'String');
    MakeSafe=1;
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
print('-dpng',FileName);
%print('-djpeg90',[FileName]);

set(Hfig,'PaperPositionMode',ppm)

showui;