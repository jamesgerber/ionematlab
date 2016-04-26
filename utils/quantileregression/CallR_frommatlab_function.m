function theta =CallR_frommatlab_function(Y,W,VarStruct,modelterms);
% Y - Nx1 column of yields
% W - column of weights
% VarStruct - structure of variables which will be put into the workspace
% here in the function
% modelterms - these will 'eval' to the variable names that R will look for


% this function is an embarassing disaster - step through in debugger to
% see what it does.

fileheaderline=['Y,W'];
M=[W];

expandstructure(VarStruct)

% constructing this for call to R.  but R call doesn't want the column of
% ones.
for j=1:length(modelterms)-1
    newvar=eval(modelterms{j+1});
    newvarname=['var' int2str(j)];
    fileheaderline=[fileheaderline ',' newvarname];
    M=[M newvar];
end


unix('rm output.txt')
%M=[ W X1(:) X2(:)];

%tic
%writefile('datafile.csv',Y,M,fileheaderline,',');
%toc

tic
BigArray=[Y M];
save transferdatatoR.mat  -v6 BigArray
toc;

disp(['calling R program'])
% tic
% [s,w]=unix('R CMD BATCH /Users/jsgerber/source/matlabgit/matlab/utils/quantileregression/CallQR2.R Routput.txt')
% unix('cat Routput.txt')
% theta=load('output.txt')
% toc

tic
[s,w]=unix('R CMD BATCH /Users/jsgerber/source/matlabgit/matlab/utils/quantileregression/CallQR3.R Routput.txt');
unix('cat Routput.txt')
theta=load('output.txt');
toc
