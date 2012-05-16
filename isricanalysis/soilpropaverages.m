function S=soilpropaverages(prop,area)
% soilpropaverages - determine weighted modal value
%
%  Syntax
%   S=soilpropaverages(propertyvector,areavector)
% 
%   S.median     =  area-weighted median value
%   S.modalvalue =  value on most freq occuring value
%
%
%
% Example
%
%  prop=[12.0 17.5 17.5 20.5];
%  area=[10 20 30 40];
%  S=soilpropaverages(prop,area)
%  the modal value is 20.5: it is what occurs on the most frequently
%  occuring soil type (40%)
%
%  the median value is 17.5.  determine that by sorting by property
%
%  
%  prop=[12.0 17.5 19.5 20.5];
%  area=[32 28 30 20];
%  S=soilpropaverages(prop,area)
%  
%  prop=[12.0 17.5 19.5 20.5];
%  area=[22 28 30 20];
%  S=soilpropaverages(prop,area)
%  
%  prop=[12.0 17.5 19.5 20.5];
%  area=[32 18 30 20];
%  S=soilpropaverages(prop,area)

%% first median

[dum,ii]=sort(prop);

areasort=area(ii);
propsort=prop(ii);

ca=cumsum(areasort);
ca=ca/max(ca);


alpha=.0001;
newx(1)=0;
newy(1)=propsort(1);
for j=1:(length(ca)-1)
    newx(2*j)=ca(j)-alpha;
    newx(2*j+1)=ca(j)+alpha;
end
for j=1:(length(ca)-1)
    newy(2*j)=propsort(j);
    newy(2*j+1)=propsort(j+1);
end
newx(end+1)=1.0;
newy(end+1)=propsort(end);



    
S.median=interp1(newx,newy,0.5);

%% now modal

vals=unique(prop);

for j=1:length(vals);
  
  ii=find(prop==vals(j));
  
  sumareas(j)= sum(area(ii));
  
end


[maxarea,ii]=max(sumareas);

wmv=vals(ii);
S.modalvalue=wmv;

%% correction in case there are multiple values with max weight

ii=find(maxarea==sumareas);

if length(ii) == 1
  return
%else
%  disp(['found a case with multiple areas'])
end

% of the two (or more) which have the greatest area, pick whichever one
% is closest to the area-weighted mean value
%  meanval= sum(area.*prop)./sum(area);
%  wmv=closestvalue( vals(ii),meanval);


% alternate idea - weighted mean of close value.    
wmv= sum(area(ii).*prop(ii))./sum(area(ii));
S.modalvalue=wmv;