% testCDSForCountryCoverage
wd=pwd;

cd /Users/jsgerber/sandbox/jsg162_worldbankCWON/CDSextrapolations

a=dir('NewCDSwithAYRev4*');

ymapcoverage=logical(datablank);
amapcoverage=logical(datablank);


for j=1:numel(a);
    load(a(j).name,'NewCDS');
    
    [yield,area,deepakindexmap,CDSindexmap]=CDStoRasters_allocatetomap(NewCDS,2012);
    
    ymapcoverage=ymapcoverage | yield>0;
    amapcoverage=ymapcoverage | area>0;
end

cd(pwd)

nsg(ymapcoverage)

nsg(amapcoverage)
