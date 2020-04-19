% testCDSForCountryCoverage
wd=pwd;

cd /Users/jsgerber/sandbox/jsg162_worldbankCWON/CDSextrapolations
Revstr='Rev5'
a=dir(['NewCDSwithAY' Revstr '*']);

ymapcoverage=logical(datablank);
amapcoverage=logical(datablank);

for yr=[1990:5:2015];
    
for j=1:numel(a);
    load(a(j).name,'NewCDS');
    
    [yield,area,deepakindexmap,CDSindexmap]=CDStoRasters_allocatetomap(NewCDS,yr);
    
    ymapcoverage=ymapcoverage | yield>0;
    amapcoverage=ymapcoverage | area>0;
end


nsg(ymapcoverage,'title',['Yield coverage ' int2str(yr) ' REV ' Revstr],'filename','on')

nsg(amapcoverage,'title',['Area coverage ' int2str(yr) ' REV ' Revstr],'filename','on')
end



cd(pwd)
