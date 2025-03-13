function NSS=getNSSDrawdown;

NSS.titlefont='Bebas Neue';
NSS.font='Proxima Nova';
NSS.plotstates='countrieslight';
NSS.statewidth=0.05;
NSS.longlatlines='off';
NSS.sink='nonagplaces';
NSS.filename='temp';
NSS.resolution='-r600';
NSS.titlefontsize=24;
NSS.colorbarunitsfontsize=12;
NSS.titleverticalalignment='cap';
NSS.colorbarfontweight='normal';
NSS.mappingtoolbox='on';


disp([' OS=nsg(   ,NSS) ']);


disp(['maketransparentoceans_noant_nogridlinesnostates_removeislands' ...
    '(''temp.png'',''       .png'',[1 1 1],1);'])


disp(['maketransparentOcReg_noant_nogridlinesnostates_removeislands' ...
    '(''temp.png'',''       .png'',[1 1 1],1,''SEAsia'',''-r300'',''5min'');'])


disp(['[filename,DataResolution,PrintResolution,Region]=MakeNiceRegionalFigs'])
disp(['maketransparentOcReg_noant_nogridlinesnostates_removeislands' ...
    '(''temp.png'',''       .png'',[1 1 1],1,Region,PrintResolution,DataResolution);'])
