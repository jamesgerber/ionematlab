function [theta,X,Y,W] =...
    callWeightedQR(Y,W,VarStruct,modelterms,tauvalues,iikeep,alphavalue);
% callWeightedQR(Y,W,VarStruct,modelterms,tauvalues,iikeep,alphavalue)
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

if nargin < 7
    alphavalue=0.1;
end

if numel(iikeep) ~=numel(Y)
    error
end
% this function is an embarassing disaster - step through in debugger to
% see what it does.

fileheaderline=['Y,W'];
M=[W];  % stupid legacy.  construct M around W (legacy) so later have to pull it off.

expandstructure(VarStruct);

% constructing this for call to R.  but R call doesn't want the column of
% ones.
for j=1:length(modelterms)-1
    newvar=eval(modelterms{j+1}); 
    if numel(find(~isfinite(newvar))) == numel(newvar)
        error(['no finite variables in ' mfilename]);
    end
    newvarname=['var' int2str(j)];
    fileheaderline=[fileheaderline ',' newvarname];
    M=[M newvar];
end

%X=M(:,2:9);
X=M;
X(:,1)=1;
theta=weightedQR(X,Y,tauvalues,W);


