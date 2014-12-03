function [Y]=Nfunction(Napplied,model,crop,varargin);
% Nfunction
%    [N20]=Nfunction(Napplied,model,crop);
%    implement Philibert and IPCC models relating N application and N2O
%    emission.
%    Napplied in kg/ha/yr
%    model can be any of the following
%         'IPCC'
%         'derivIPCC'
%         'NLNRR'
%         'NLNRRzyi'
%         'globalparamNLNRR'
%         'LNRF'
%         'LNRR'
%         'meanLNRR'
%         'meanNLNRR'
%         {'meanNLNRRzyi','meanNLNRRresponse'}
%         'derivmeanNLNRR'
%         'medianNLNRR'
%         'derivmedianNLNRR'
%
%  I have added a sneaky syntax:
%  N2O_newfunction=Nfunction(1:200,'CVmeanNLNRRresponse_ricesep','maize',.25,10000);
%  where CV means take the N application rate and distribute the N by a
%  gaussian distribution with CV of 0.25.   N app values are constrained to
%  within [0,600]    10000 is the number of random values used to get the
%  average.
% 

% The EF value of 1.25%, set in 1999 [17], was calculated from the following linear regression: 
% Y = 0.0125 * X, where Y is the emission rate (in kg N2O-N ha
% -1
%  yr
% -1
% 2  ) and X is the fertilizer 
% application rate (in kg N ha
% -1
%  yr
% -1
% 3  ), based on 20 experiments [18]. A background emission of 1 
% kg N2O-N ha
% -1
%  yr
% -1
% 4  (i.e., emission for X=0) was obtained in five experiments. The new value 
% 5  of EF used by the IPCC after 2006 (1%; [14]) was estimated from a larger dataset, including 
% 6  N2O emission measurements from studies on both crops and grassland [10].
%
X=Napplied;

if isequal(model(1:2),'CV')
    CV=varargin{1};

    Nreps=varargin{2};;

    
    
    X=X(:);
    XX=repmat(X,1,Nreps);
    model=model(3:end);
    r=randn(length(X),Nreps);
    Nrandom=XX.*(1+r*CV);
    
    Nrandom(Nrandom < 0)=0;
    Nrandom(Nrandom > 600)=600;

    N2O_rand=Nfunction(Nrandom,model,crop);

    Y=mean(N2O_rand,2);
    return
end



switch model
    
    
    case 'IPCC'
        switch crop
            case 'rice'
                Y=X*0.0031;
            otherwise
                Y=X*0.01;
        end
    case 'derivIPCC'
        switch crop
            case 'rice'
                Y=X*0+0.0031;
            otherwise
                Y=X*0+0.01;
        end
    case 'NLNRR'
        mu0=0.19;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        
        
        epsilon=normdist(0,tau^2,X);
        alpha0=normdist(mu0,sigma0.^2,X);
        alpha1=normdist(mu1,sigma1.^2,X);
        
        Y=exp(alpha0+alpha1.*X)+epsilon;
   case 'NLNRRmeanparameters'
        mu0=0.19;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        
        
        epsilon=0;
        alpha0=mu0;
        alpha1=mu1;
        
        Y=exp(alpha0+alpha1.*X)-exp(alpha0);
        
    case 'NLNRRzyi'
        mu0=0.19;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        
        
        epsilon=normdist(0,tau^2,X);
        alpha0=normdist(mu0,sigma0.^2,X);
        alpha1=normdist(mu1,sigma1.^2,X);
        
        Y=exp(alpha0+alpha1.*X)-exp(alpha0)+epsilon;
        
  %      Y=exp(alpha0+alpha1.*X);
  case 'globalparamNLNRR'
        mu0=0.19;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        
        
        epsilon=normdist(0,tau^2,1);
        alpha0=normdist(mu0,sigma0.^2,1);
        alpha1=normdist(mu1,sigma1.^2,1);
        
        Y=exp(alpha0+alpha1.*X)+epsilon;
    case 'LNRF'
        mu0=0.99;
        sigma0=3.16;
        mu1=0.0130;
        tau=2.67;
        % page 31 of makowski paper / find parameters
        epsilon=normdist(0,tau^2,X);
        alpha0=normdist(mu0,sigma0.^2,X);
        
        Y=alpha0+mu1.*X+epsilon; 
    case 'LNRR'
        mu0=1.04;
        sigma0=0.7;
        mu1=0.0117;
        sigma1=0.0187;
        tau=2.08;
        % page 31 of makowski paper / find parameters
        epsilon=normdist(0,tau^2,X);
        alpha0=normdist(mu0,sigma0.^2,X);
        alpha1=normdist(mu1,sigma1.^2,X);
        
        Y=alpha0+alpha1.*X+epsilon;
  case 'meanLNRR'
        mu0=1.04;
        sigma0=0.7;
        mu1=0.0117;
        sigma1=0.0187;
        tau=2.08;
        % page 31 of makowski paper / find parameters
       % epsilon=normdist(0,tau^2,X);
       % alpha0=normdist(mu0,sigma0.^2,X);
       % alpha1=normdist(mu1,sigma1.^2,X);
        
       alpha0=mu0;
       alpha1=mu1;
       epsilon=0;
       
        Y=alpha0+alpha1.*X+epsilon;
    case 'meanNLNRR'
        %mean of the model
        mu0=0.19;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) );

      case 'meanNLNRR_ricesep'
        %mean of the model
        switch crop
            case 'rice'
                Z=-1.139;
            otherwise
                Z=0;
        end
        mu0=0.24+Z;
        mu1=0.00376;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.935;
        Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) );

        
    case {'meanNLNRRzyi','meanNLNRRresponse'}
        % mean of the model but we subtract off the zero value
        mu0=0.19;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
          exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;

    case {'meanNLNRRzyi_ricesep','meanNLNRRresponse_ricesep'}
        % mean of the model but we subtract off the zero value
        %mean of the model
        switch crop
            case 'rice'
                Z=-1.139;
            otherwise
                Z=0;
        end
        mu0=0.24+Z;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
          exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;
     
    case 'derivmeanNLNRR_ricesep'
        % derivative of the mean of the model
        switch crop
            case 'rice'
                Z=-1.139;
            otherwise
                Z=0;
        end
        mu0=0.24+Z;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) ).*...
            ((2*(mu1+sigma1.^2*X).*(sigma1.^2))/(2*sigma1.^2) );
  case 'derivmeanNLNRR_ricesep'
        % derivative of the mean of the model
        switch crop
            case 'rice'
                Z=-1.139;
            otherwise
                Z=0;
        end
        mu0=0.24+Z;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) ).*...
            ((2*(mu1+sigma1.^2*X).*(sigma1.^2))/(2*sigma1.^2) );
 case 'derivmeanNLNRR'
        % derivative of the mean of the model
        mu0=0.19;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) ).*...
            ((2*(mu1+sigma1.^2*X).*(sigma1.^2))/(2*sigma1.^2) );

        
    case 'medianNLNRR'
        mu0=0.19;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        
        % epsilon=normdist(0,tau^2,X);
        % alpha0=normdist(mu0,sigma0.^2,X);
        % alpha1=normdist(mu1,sigma1.^2,X);
        
        alpha0=mu0;
        alpha1=mu1;
        epsilon=0;
        
        Y=exp(alpha0+alpha1.*X)+epsilon;
    case 'derivmedianNLNRR'
        mu0=0.19;
        mu1=0.00369;
        sigma0=0.72;
        sigma1=0.0025;
        tau=1.94;
        
        % epsilon=normdist(0,tau^2,X);
        % alpha0=normdist(mu0,sigma0.^2,X);
        % alpha1=normdist(mu1,sigma1.^2,X);
        
        alpha0=mu0;
        alpha1=mu1;
        epsilon=0;
        
        Y=alpha1.*exp(alpha0+alpha1.*X)+epsilon;
end



function y=normdist(mu,sigmasq,templatevar);

if nargin<3
    templatevar=NaN;
end
y=mu+randn(size(templatevar))*sqrt(sigmasq);