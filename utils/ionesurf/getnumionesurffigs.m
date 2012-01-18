function n=GetNumIonESurfFigures;

h=allchild(0);
s=get(h,'tag');
n=length(strmatch('IonEFigure',s));

