function ClimateBinLegend(CDS,colors,BinMatrix,CBPS);
% ClimateBinLegend - make a climate bin legend which is appropriately
% spaced
%
%  ClimateBinLegend(CDS,colors,BinMatrix,CBPS);
%
%   colors is an NxN structure with field .rgb.  It is output from ClimateBinPlot_variableN
%
%  CBPS has fields:
%             suppressbox (default 0)
%             titlestring  (default 'Climate Zones.')
%             cmapname (default 'jget')
%             xtext    (default ' GDD ')
%             ytext    (default ' prec')



a=BinMatrix;
a(a==0)=NaN;



suppressbox=0;
titlestring='Climate Zones.';
cmapname='jet';
xtext='  GDD  ';
ytext='  precipitation  ';

if nargin >3
    expandstructure(CBPS);
end


N=sqrt(length(CDS));


  figure
axes

  
x=1:N;
y=1:N;
for j=1:N
    for k=1:N
        m=(j-1)*N+k;
        
        S=CDS(m);
        xvect=[S.GDDmin S.GDDmax S.GDDmax S.GDDmin];
        yvect=[S.Precmin S.Precmin S.Precmax S.Precmax];
        
        
        patch(xvect,yvect,colors(j,k).rgb);
        
    end
end


set(gca,'visib','off')

  figure
axes

  
x=1:N;
y=1:N;
for j=1:N
    for k=1:N
        m=(j-1)*N+k;
        
        S=CDS(m);
        xvect=[S.GDDmin S.GDDmax S.GDDmax S.GDDmin];
        yvect=[S.Precmin S.Precmin S.Precmax S.Precmax];
        
        
        patch(xvect,yvect,colors(j,k).rgb);
        
    end
end
xlabel(xtext)
ylabel(ytext)
title(titlestring)
