function isolatelegend(Fig);

if nargin==0
    Fig=gcf;
end

hc=allchild(Fig);

tags=get(hc,'tag');

ii=strmatch('legend',tags,'exact');

if numel(ii) ==0
    error([' did not find any legends in figure ' num2str(Fig)]);
end

if numel(ii) >1
    error([' found multiple legends in figure ' num2str(Fig)]);
end

hleg=hc(ii);

NewFig=figure;

set(hleg,'parent',NewFig)
