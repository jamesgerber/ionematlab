function out=callpersonalpreferences(in);
%function callpersonalpreferences  - gateway & defaults for personalpreferences



ListOfPreferences={'printingres','GraphicsFileType','oceancolor',...
    'nodatacolor','latlongcolor','maxnumfigsNSG'};
%% if called with no arguments, tell user what defaults are
if nargin==0
    for j=1:length(ListOfPreferences)
        
        val=callpersonalpreferences(ListOfPreferences{j});
        
        if isstr(val)
        disp(sprintf('%20s ,     ''%s'' ) ',...
            ['personalpreferences(''' ListOfPreferences{j} ''''  ],...
            val));
        else
        disp(sprintf('%20s =      [%s])',...
            ['personalpreferences(''' ListOfPreferences{j} '''' ],...
            num2str(val)));
        end
    end
    return
end

    



%% OutputFig
printingres='-r300';
GraphicsFileType='-dpng';% '-djpg' ; '-dtiff';


%% NiceSurf / NiceSurfGeneral
oceancolor='emblue';
nodatacolor='gray';
latlongcolor=[.5 .5 .5];
maxnumfigsNSG=3;
try
    out=personalpreferences(in);
    return
catch
disp('Did not have successful call to personal preferences ... calling default')

disp(' You probably need to copy personalpreferencestemplate.m to ~/Documents/MATLAB !')

eval(['out=' in ';']);


end
