function x=personalpreferences(variable,setting)
% PERSONALPREFERENCES - get or set personal default settings for
% NiceSurfGeneral and finemap, oceancolor, nodatacolor, latlongcolor, and
% printingres
%
%  Syntax
%
%      x=personalpreferences(variable) - returns the current setting for
%      variable, or '' if none.
%
%      x=personalpreferences(variable,setting) - sets variable to setting,
%      returns previous setting
%
%  Example
%
%     personalpreferences('printingres')
%     personalpreferences('printingres','-r555')
%     personalpreferences('printingres')
%     personalpreferences('maxnumfigsNSG')
%
%
%


if nargin==0
    callpersonalpreferences
    return
end


persistent latlongcolor printingres GraphicsFileType oceancolor ...
    maxnumfigsNSG nodatacolor


if isempty(latlongcolor)   
    %% OutputFig
    printingres='-r300';
    GraphicsFileType='-dpng';% '-djpg' ; '-dtiff';
    
    
    %% NiceSurf / NiceSurfGeneral
    oceancolor=[0.835294118 0.894117647 0.960784314]; % old color: 'emblue';
    nodatacolor=[.92 .92 .92]; % old color: 'gray';
    latlongcolor=[.3 .3 .3];
    maxnumfigsNSG=3;

end



if nargin==2
    
    
    a=whos(variable);
    if isequal(a.class,'double')
        disp(['Setting ' variable '=[' num2str(setting) '];']);
        eval([variable '=[' num2str(setting) '];']);
        
    else
        
        disp(['Setting ' variable '=''' setting ''';']);
 
        eval([variable '=''' setting ''';']);
    end
    
    return
end












% don't mess with this:
eval(['x=' variable ';']);