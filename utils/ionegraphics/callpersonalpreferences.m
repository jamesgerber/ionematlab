function out=callpersonalpreferences(in);
%function callpersonalpreferences  - gateway & defaults for personalpreferences




%% OutputFig
printingres='-r300';
GraphicsFileType='-dpng';% '-djpg' ; '-dtiff';


%% NiceSurf / NiceSurfGeneral
oceancolor='emblue';
nodatacolor='gray';
latlongcolor=[.5 .5 .5];

try
    out=personalpreferences(in);
    return
catch
disp('Did not have successful call to personal preferences ... calling default')

disp(' You probably need to copy personalpreferencestemplate.m to ~/Documents/MATLAB !')

eval(['out=' in ';']);


end
