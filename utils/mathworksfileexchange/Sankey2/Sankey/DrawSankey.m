% Example data 
% data of the left panel in each block
data1{1}=[5 6]; 
data1{2}=[3 4 2];
data1{3}=[2 3 4];

% data of the right panel in each block
data2{1}=data1{2};
data2{2}=data1{3};
data2{3}=[2 6];

% data of flows in each block
data{1}=[0 2 1;2 2 0];
data{2}=[0 1 1; 1 1 1; 1 0 0];
data{3}=[1 1; 1 1; 0 1];

% x-axis
X=[0 1 2 3];

% panel color
barcolors{1}=[1 0 0; 0 1 1];
barcolors{2}=[1 0 1; 0 1 0; 1 1 0];
barcolors{3}=[1 .6 0; .6 .6 .6; 0 0 1];
barcolors{4}=[.2 1 .2; .6 .6 1];

% flow color
c = [.7 .7 .7];

% Panel width
w = 25; 

for j=1:3
    if j>1
        ymax=max(ymax,sankey_yheight(data1{j-1},data2{j-1}));
        y1_category_points=sankey_alluvialflow(data1{j}, data2{j}, data{j}, X(j), X(j+1), y1_category_points,ymax,barcolors{j},barcolors{j+1},w,c);
    else
        y1_category_points=[];
        ymax=sankey_yheight(data1{j},data2{j});
        y1_category_points=sankey_alluvialflow(data1{j}, data2{j}, data{j}, X(j), X(j+1), y1_category_points,ymax,barcolors{j},barcolors{j+1},w,c);
    end
end
        