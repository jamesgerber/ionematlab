function [theta,theta_lowerbd,theta_upperbd,AIC,BIC,covmatrix] =...
    CallR_frommatlab_function(Y,W,VarStruct,modelterms,tauvalues,iikeep,alphavalue,saveinputvaluesflag,algorithmflag);
% Y - Nx1 column of yields
% W - column of weights
% VarStruct - structure of variables which will be put into the workspace
% here in the function
% modelterms - these will 'eval' to the variable names that R will look for
% tauvalues - values for QR
% iikeep = indices to keep.  Should have same length as Y
% alphavalue
% saveinputvaluesflag - 0 (default) does nothing >0  saves a copy of inputs
% with saveinputvalueflag in name



if nargin<8
    saveinputvaluesflag=0;
end

if nargin<9
    algorithmflag=0;
end



if saveinputvaluesflag>0
    
    
    if exist(['./callRfrommatlab_flag' int2str(saveinputvaluesflag) '_output' '.mat'])==2
        load(['./callRfrommatlab_flag' int2str(saveinputvaluesflag) '_output' '.mat'],'theta','theta_lowerbd','theta_upperbd','AIC','BIC','covmatrix')
        return
    else
        
        if exist(['../callRfrommatlab_flag' int2str(saveinputvaluesflag) '.mat'])==0
            % calling to set up the analysis (probably from laptop)
            save(['../callRfrommatlab_flag' int2str(saveinputvaluesflag) '.mat'],'Y','W','VarStruct','modelterms','tauvalues','iikeep','alphavalue','saveinputvaluesflag')
theta=nan;
theta_lowerbd=nan;
theta_upperbd=nan;
AIC=nan;
BIC=nan;
covmatrix=nan;
return
        else
            disp('loading some stuff, proceeding ... ')
            load(['./callRfrommatlab_flag' int2str(saveinputvaluesflag) '.mat'],'Y','W','VarStruct','modelterms','tauvalues','iikeep','alphavalue','saveinputvaluesflag')
        end
    end
    
end

    
    

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
M=[W];

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


unix('rm output.txt');
unix('rm AICValue.txt');


% adding some terms for individual country terms

% a=fieldnames(VarStruct);
% countrynums=getfield(VarStruct,a{end});
% 
% countries=unique(countrynums);
% for j=1:numel(countries);
%     C=countries(j);
%     iiC=countrynums==C;
%     coveragetest(iiC)=1;
%    M(iiC,end+1)=1;   
% end

%M=[ W X1(:) X2(:)];

%tic
%writefile('datafile.csv',Y,M,fileheaderline,',');
%toc

tic
BigArray=[Y M];
BigArray=BigArray(iikeep,:);





save transferdatatoR.mat  -v6 BigArray tauvalues alphavalue algorithmflag
%toc;

%disp(['calling R program']);
% tic
% [s,w]=unix('R CMD BATCH /Users/jsgerber/source/matlabgit/matlab/utils/quantileregression/CallQR2.R Routput.txt')
% unix('cat Routput.txt')
% theta=load('output.txt')
% toc

tic

if ismalthus
    [s,w]=unix('/usr/local/bin/R CMD BATCH /Users/jsgerber/source/matlab/trunk/utils/quantileregression/CallQR5.R Routput.txt');

else
    [s,w]=unix('/usr/local/bin/R CMD BATCH /Users/jsgerber/source/matlab/utils/quantileregression/CallQR5.R Routput.txt');
end
toc
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
 
if algorithmflag==0
    cm=load('covmatrix.txt');

    covmatrix=reshape(cm,sqrt(numel(cm)),sqrt(numel(cm)));
else
    covmatrix=nan;
end
%toc;
if ~isempty(saveinputvaluesflag)

save(['./callRfrommatlab_flag' int2str(saveinputvaluesflag) '_output' '.mat'],'theta','theta_lowerbd','theta_upperbd','AIC','BIC','covmatrix')
end