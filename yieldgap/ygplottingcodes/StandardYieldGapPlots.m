function StandardYieldGapPlots(FS,OS,fileroot)
% make some standard yield gap plots
%
%



% Yield Gap

yg=OS.potentialyield-OS.Yield;
yg(yg<0)=0;

nsg(yg,'title',[' ' OS.cropname ' yield gap ' ],...
    'cmap','revnmstoplight',...
    'filename',[fileroot OS.cropname 'yieldgap'],...
    'units','tons/ha');



nsg(OS.YieldGapFraction*100,'title',[' ' OS.cropname ' yield gap fraction ' ],...
    'cmap','revnmstoplight',...
    'filename',[fileroot OS.cropname 'yieldgapfraction'],...
    'colorbarpercent','on');




nsg((1-OS.YieldGapFraction)*100,'title',[' fraction of attainable ' OS.cropname ' yield. ' ],...
    'cmap','nmstoplight',...
    'filename',[fileroot OS.cropname 'attainableyieldfraction'],...
    'colorbarpercent','on');