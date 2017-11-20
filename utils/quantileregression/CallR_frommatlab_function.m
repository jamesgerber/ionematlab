function [theta,theta_lowerbd,theta_upperbd,AIC,BIC] =...
    CallR_frommatlab_function(Y,W,VarStruct,modelterms,tauvalues,iikeep);
% Y - Nx1 column of yields
% W - column of weights
% VarStruct - structure of variables which will be put into the workspace
% here in the function
% modelterms - these will 'eval' to the variable names that R will look for
% tauvalues - values for QR
% iikeep = indices to keep.  Should have same length as Y

if nargin <5
    tauvalues=0.95
end

if nargin < 6
    iikeep=1:length(Y);
end
% this function is an embarassing disaster - step through in debugger to
% see what it does.

fileheaderline=['Y,W'];
M=[W];

expandstructure(VarStruct);

% constructing this for call to R.  but R call doesn't want the column of
% ones.
for j=1:length(modelterms)-1
    newvar=eval(modelterms{j+1}); 
    if numel(find(~isfinite(newvar))) == numel(newvar)
        error(['all nan variable in ' mfilename]);
    end
    newvarname=['var' int2str(j)];
    fileheaderline=[fileheaderline ',' newvarname];
    M=[M newvar];
end


unix('rm output.txt')
unix('rm AICValue.txt');
%M=[ W X1(:) X2(:)];

%tic
%writefile('datafile.csv',Y,M,fileheaderline,',');
%toc

tic
BigArray=[Y M];
BigArray=BigArray(iikeep,:);





save transferdatatoR.mat  -v6 BigArray tauvalues
toc;

disp(['calling R program']);
% tic
% [s,w]=unix('R CMD BATCH /Users/jsgerber/source/matlabgit/matlab/utils/quantileregression/CallQR2.R Routput.txt')
% unix('cat Routput.txt')
% theta=load('output.txt')
% toc

tic
[s,w]=unix('/usr/local/bin/R CMD BATCH /Users/jsgerber/source/matlab/trunk/utils/quantileregression/CallQR3.R Routput.txt');

if s~=0
w
unix('cat Routput.txt')
end


N=length(modelterms);
thetatemp=load('output.txt');
theta=thetatemp(1:N);

AIC=load('AICValue.txt');

numdata=log(length(find(isfinite(Y))));

BIC=AIC-2*N+2*numdata;  

%BIC=load('BICValue.txt');
if length(thetatemp)==3*N
    theta_lowerbd=thetatemp(N+1:2*N);
    theta_upperbd=thetatemp(2*N+1:3*N);
else
    theta_lowerbd=theta*NaN;
    theta_upperbd=theta*NaN;
end
 
toc
