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
%
%
%

persistent latlongcolor printingres GraphicsFileType oceancolor ...
    maxnumfigsNSG nodatacolor


if isempty(latlongcolor)   
    %% OutputFig
    printingres='-r300';
    GraphicsFileType='-dpng';% '-djpg' ; '-dtiff';
    
    
    %% NiceSurf / NiceSurfGeneral
    oceancolor='emblue';
    nodatacolor='gray';
    latlongcolor=[.3 .3 .3];
    maxnumfigsNSG=3;

end



if nargin==2
    
    disp(['Setting ' variable '=''' setting ''';']);
    
    a=whos(variable);
    if isequal(a.class,'double')
        eval([variable '=' num2str(setting) ';']);
    else
        
        
        eval([variable '=''' setting ''';']);
    end
    
    return
end












% don't mess with this:
eval(['x=' variable ';']);