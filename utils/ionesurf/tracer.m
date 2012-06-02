function [R,C]=tracer(h,ri,ci,data,ctrace,squeeze,breadth,depth)
if nargin<5
    ctrace=[0.6784,0.9216,1.0000];
end
if nargin<6
    squeeze=std2(data);
end
if nargin<7
    breadth=length(data(:,:,1))/10;
end
if nargin<8
    depth=1;
end
R=[ri];
C=[ci];
val=data(round(ri),round(ci),1);
for i=1:size(data,3)
    [ri,ci]=center(data(:,:,i),val,squeeze,ri,ci,breadth,depth);
    R(length(R)+1)=ri;
    C(length(C)+1)=ci;
    axes(h);
    line(C(i:(i+1)),R(i:(i+1)),'LineWidth',2,'Color',ctrace);
end