function [Hfig,h221,h222]= uberscatter(x,y,w,Hfig,xlabelstring,ylabelstring);
% uberscatter - make scatter and density plots and show regression line
%
%  SYNTAX
%       uberscatter(x,y,w,Hfig);
%
%x=1:4000;
%y=x*.03+randn(size(x))*30;
%uberscatter(x,y)
%uberscatter(x,y,w)
%uberscatter(x,y,w,Hfig)

%
Nmax=50000;


if numel(x)~=numel(y)
    error
end

if nargin==2
    w=ones(size(y));
end

if nargin==3
    error('does not have weights correct in here')
end

x=x(:);
y=y(:);
w=w(:);

if nargin<4 | isempty(Hfig)
    Hfig=figure;
else
    figure(Hfig)
end

if nargin<5
    xlabelstring='';
end
if nargin<6
    ylabelstring='';
end



if length(x)>Nmax;
    ii=randperm(numel(x),Nmax);
    
    x=x(ii);
    y=y(ii);
    w=w(ii);
end

h221=subplot(221);
scatter(x,y);
xlabel(xlabelstring)
ylabel(ylabelstring)


[jp,xbins,ybins,XBinEdges,YBinEdges]=GenerateJointDist(x,y,100,110);

h222=subplot(222);

surface(xbins,ybins,jp');
shading flat
xlabel(xlabelstring)
ylabel(ylabelstring)
X=[ones(size(x)) x];
 

[B,BINT,R,RINT,STATS] = regress(y,X);

Rsq=STATS(1);

h223=subplot(223)
xpl=[min(x) max(x)];
plot(x,y,'.',x,x*B(2)+ B(1))
xlabel(xlabelstring)
ylabel(ylabelstring)
h224=subplot(224);
set(h224,'visible','off');

text(.1,.1,[' Rsq = ' num2str(Rsq)]);
text(.1,.3,[' slope = ' num2str(B(2)) ' (' num2str(BINT(2,1)) ',' num2str(BINT(2,2)) ')']);
text(.1,.5,[' intercept = ' num2str(B(1)) ' (' num2str(BINT(1,1)) ',' num2str(BINT(1,2)) ')']);


mdl=fitlm(x,y,'Weights',w)
%d=display(mdl)