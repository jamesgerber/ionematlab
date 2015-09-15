
%TitleStr=
Production(find(isnan(Production)))=0;
currentprodsum = sum(sum(Production));

potentialprod=potentialyield.*CultivatedArea;

potentialprod(find(isnan(potentialprod)))=0;
potentialprodsum=sum(sum(potentialprod));

perdifference = potentialprodsum ./ currentprodsum;

if MakePotentialYieldMapFlag ==1
ii=find(isnan(potentialyield));
Yield(ii)=NaN;
%potentialyield(ii)=NaN;
%    disp([cropname ': current production = ' num2str(currentprodsum) ...
%        ', 95 percentile production = ' num2str(potentialprodsum) ...
%        ', percent difference = ' num2str(perdifference.*100) '%'])
uppercolorlevel=nanmax(nanmax(potentialyield))
lowercolorlevel=nanmin(nanmin(Yield))

titlestr=([' ' cropname ' Actual Yield. (Production = ' ...
    int2str(currentprodsum/1e6) ' megatons). ' ...
    Nstr 'x' Nstr '. Moisture index=' ...
    WetFlag '. GDD Base Temp=' GDDTempstr '.  Rev' Rev ' ']);

PrintTitle=['./figures/Actual Yield' cropname  ...
    Nstr 'x' Nstr '  Rev' Rev ]

IonESurf(Long,Lat,Yield,'Potential Yield',titlestr);
caxis([lowercolorlevel uppercolorlevel])
AddCoasts
OutputFig('Force',PrintTitle);
close all

titlestr=([' ' cropname ' Potential Yield. (Production = ' ...
    int2str(potentialprodsum/1e6) ' megatons). Increase='...
    num2str((perdifference-1)*100,3) '%' ...
    Nstr ' x' Nstr '. Moisture index=' ...
    WetFlag '. GDD Base Temp=' GDDTempstr '.  Rev' Rev ' ']);
PrintTitle=['./figures/Potential Yield' cropname  ...
    Nstr 'x' Nstr '  Rev' Rev ]
IonESurf(Long,Lat,potentialyield,'Potential Yield',titlestr);
caxis([lowercolorlevel uppercolorlevel])
AddCoasts
OutputFig('Force',PrintTitle);
close all
end
