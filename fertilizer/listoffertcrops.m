function list=listoffertcrops;
% listoffertcrops - return a list of crops with fertilizer data

a=dir([iddstring '/Fertilizer2000/ncmat/*Napprate.mat']);
cn=cropnames;
c=1;
for j=1:length(a)
    crop=a(j).name(1:end-12);
    ii=strmatch(crop,cn,'exact')
    if length(ii)==1;
        list{c}=crop;
        c=c+1;
    end
end