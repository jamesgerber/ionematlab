Rev='N';


fid=fopen([iddstring 'misc/Reconcile_Monfreda_FAO_cropnames.txt'],'r');
C = textscan(fid,'%s%s%s%s','Delimiter',tab,'HeaderLines',1);
fclose(fid)

nums_unsort=C{1};
mnames=C{2};
faonames_unsort=C{3};
group_unsort=C{4};

ii=strmatch('coir',mnames);
mnames=mnames([1:ii-1   ii+1:length(mnames)]);
ii=strmatch('gums',mnames);
mnames=mnames([1:ii-1   ii+1:length(mnames)]);
ii=strmatch('popcorn',mnames);
mnames=mnames([1:ii-1   ii+1:length(mnames)]);

mnames={'maize'}
for j=1:length(mnames)

    thiscrop=mnames{j}

    load([iddstring 'ClimateBinAnalysis/ClimateLibrary/ClimateMask_' thiscrop '_GDD0_prec_10x10_Rev' Rev]);

    MultiBoxPlotInClimateSpaceSmoothContours(ContourMask',CDS,CultivatedArea,GDD,Prec,thiscrop,Rev,WetFlag,InsideContourLogical)

end