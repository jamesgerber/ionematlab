function [Y,YQ05,YQ95]=Nfunction(Napplied,model,crop,varargin);
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
%         'meanNLNRRresponse'
%         {'meanNLNRRzyi','meanNLNRRresponse'}
%         'derivmeanNLNRR'
%         'medianNLNRR'
%         'derivmedianNLNRR'
%         'NLNRR_parammean_ricesep'
%         'meanNLNRRzyi_ricesep700'    %VERSION USED FOR GCB PAPER!!!
%         'derivparammeanNLNRR_ricesep'
%         'correlatedparams_NLNRR_ricesep' - this will average over
%         site-year variability, but use a randomly selected set of model
%         parameters.
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
%
%
%  y=Nfunction(20*ones(1,1000000),'NLNRRzyi_ricesep','maize');
% mean(y)
%
%Nfunction(20,'meanNLNRRzyi_ricesep','maize')

        persistent x_semian meanY_semian
        persistent YQ05_semian dydn_rice dydn
        persistent meanY_semian_rice YQ05_semian_rice
        persistent YQ95_semian_rice
        persistent YQ95_semian

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
  %  Nrandom(Nrandom > 800)=800;
    
    N2O_rand=Nfunction(Nrandom,model,crop);
    
    % For any values that are above 700, use the EF from 700.
    
    ii=Nrandom>700;
    N2O_rand(ii)=Nrandom(ii)/700.*Nfunction(700,model,crop);
    
    Y=mean(N2O_rand,2);
    return
end



switch model
    
    case {'shcherbak','Shcherbak'};
        Y=0.001*X.*(6.49+0.0187*X);
    case {'hoben','Hoben'};
        Y=0.001*X.*(4.36+0.025*X);
    case {'hobenexp','Hoben'};
        Y=4.46*(exp(0.0062*X)-exp(0.0062))/1000;
    case {'derivhoben'}
        Y=0.001*(4.36) +2*0.001*0.025*X;
        
    case {'derivshcherbak'}
        Y=0.001*(6.49)+2*0.001*0.0187*X;
        
        
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
%     case 'NLNRR'
%         mu0=0.19;
%         mu1=0.00369;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         
%         
%         epsilon=normdist(0,tau^2,X);
%         alpha0=normdist(mu0,sigma0.^2,X);
%         alpha1=normdist(mu1,sigma1.^2,X);
%         
%         Y=exp(alpha0+alpha1.*X)+epsilon;
%     case 'NLNRRmeanparameters'
%         mu0=0.19;
%         mu1=0.00369;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         
%         
%         epsilon=0;
%         alpha0=mu0;
%         alpha1=mu1;
%         
%         Y=exp(alpha0+alpha1.*X)-exp(alpha0);
%         
%     case 'NLNRRzyi'
%         mu0=0.19;
%         mu1=0.00369;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         
%         
%         epsilon=normdist(0,tau^2,X);
%         alpha0=normdist(mu0,sigma0.^2,X);
%         alpha1=normdist(mu1,sigma1.^2,X);
%         
%         Y=exp(alpha0+alpha1.*X)-exp(alpha0);
%         
%         
%         
%         %      Y=exp(alpha0+alpha1.*X);
%     case 'globalparamNLNRR'
%         mu0=0.19;
%         mu1=0.00369;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         
%         
%         epsilon=normdist(0,tau^2,1);
%         alpha0=normdist(mu0,sigma0.^2,1);
%         alpha1=normdist(mu1,sigma1.^2,1);
%         
%         Y=exp(alpha0+alpha1.*X)+epsilon;
%     case 'LNRF'
%         mu0=0.99;
%         sigma0=3.16;
%         mu1=0.0130;
%         tau=2.67;
%         % page 31 of makowski paper / find parameters
%         epsilon=normdist(0,tau^2,X);
%         alpha0=normdist(mu0,sigma0.^2,X);
%         
%         Y=alpha0+mu1.*X+epsilon;
%     case 'LNRR'
%         mu0=1.04;
%         sigma0=0.7;
%         mu1=0.0117;
%         sigma1=0.0187;
%         tau=2.08;
%         % page 31 of makowski paper / find parameters
%         epsilon=normdist(0,tau^2,X);
%         alpha0=normdist(mu0,sigma0.^2,X);
%         alpha1=normdist(mu1,sigma1.^2,X);
%         
%         Y=alpha0+alpha1.*X+epsilon;
%     case 'meanLNRR'
%         mu0=1.04;
%         sigma0=0.7;
%         mu1=0.0117;
%         sigma1=0.0187;
%         tau=2.08;
%         % page 31 of makowski paper / find parameters
%         % epsilon=normdist(0,tau^2,X);
%         % alpha0=normdist(mu0,sigma0.^2,X);
%         % alpha1=normdist(mu1,sigma1.^2,X);
%         
%         alpha0=mu0;
%         alpha1=mu1;
%         epsilon=0;
%         
%         Y=alpha0+alpha1.*X+epsilon;
%     case 'meanNLNRR'
%         %mean of the model
%         mu0=0.19;
%         mu1=0.00369;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) );
%         
%     case 'meanNLNRR_ricesep'
%         %mean of the model
%         switch crop
%             case 'rice'
%                 Z=-1.139;
%             otherwise
%                 Z=0;
%         end
%         mu0=0.24+Z;
%         mu1=0.00376;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.935;
%         Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) );
%         
%         
%     case {'meanNLNRRzyi','meanNLNRRresponse'}
%         % mean of the model but we subtract off the zero value
%         mu0=0.19;
%         mu1=0.00369;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
%             exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;
%         
      case {'meanNLNRRzyi_ricesep_GCBSubmit','meanNLNRRresponse_ricesep_GCBSubmit'}
%         % mean of the model but we subtract off the zero value
%         %mean of the model
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
        tau=1.94;
          Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
       exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;
% % 

%         %mean of the model
% %        case {'meanNLNRRzyi_ricesep','meanNLNRRresponse_ricesep'}
% %        switch crop
% %             case 'rice'
% %                 Z=-1.0780975;
% %             otherwise
% %                 Z=0;
% %         end
% %         mu0=0.3400364+Z;
% %         mu1=0.0031001;
% %         sigma0=0.7142285;
% %         sigma1=0.002054274;
% %          Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
% %              exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;
% % 
   
     case {'meanNLNRRzyi_ricesep500philibertsig72'}
     mu=[0.2404356 0.0037637 -1.1387809];
  
     sigma0=0.72;
     sigma1=0.002450415;

       
        switch crop
            case 'rice'
                Z=mu(3);
            otherwise
                Z=0;
        end
        
        mu0=mu(1)+Z;
        mu1=mu(2);

         Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
             exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;

              case {'meanNLNRRzyi_ricesep500philibert'}
     mu=[0.2404356 0.0037637 -1.1387809];
  
     sigma0=0.6961457 ;
     sigma1=0.002450415;

       
        switch crop
            case 'rice'
                Z=mu(3);
            otherwise
                Z=0;
        end
        
        mu0=mu(1)+Z;
        mu1=mu(2);

         Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
             exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;

         
              case {'meanNLNRRzyi_ricesep500','meanNLNRRresponse_ricesep500'}
     mu=[0.2063760 0.0039503 -1.0048088];
  
     sigma0=0.6775408;
     sigma1=0.002046277;

       
        switch crop
            case 'rice'
                Z=mu(3);
            otherwise
                Z=0;
        end
        
        mu0=mu(1)+Z;
        mu1=mu(2);

         Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
             exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;

         
    case {'meanNLNRRzyi_ricesep700','meanNLNRRresponse_ricesep700'}
     mu=[0.3033216 0.0033885 -0.9718765];
  
     sigma0=0.7066093;
     sigma1=0.001950911;

       
        switch crop
            case 'rice'
                Z=mu(3);
            otherwise
                Z=0;
        end
        
        mu0=mu(1)+Z;
        mu1=mu(2);

         Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
             exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;

     case 'derivmeanNLNRR_ricesep700'
     mu=[0.3033216 0.0033885 -0.9718765];
  
     sigma0=0.7066093;
     sigma1=0.001950911;

       
        switch crop
            case 'rice'
                Z=mu(3);
            otherwise
                Z=0;
        end
        
        mu0=mu(1)+Z;
        mu1=mu(2);
         Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) ).*...
             ((2*(mu1+sigma1.^2*X).*(sigma1.^2))/(2*sigma1.^2) );


    case {'meanNLNRRzyi_ricesep800','meanNLNRRresponse_ricesep800'}
        mu=[ ];
        
        switch crop
            case 'rice'
                Z=mu(3);
            otherwise
                Z=0;
        end
        
        mu0=mu(1)+Z;
        mu1=mu(2);
        sigma0=0.7106919;
        sigma1=0.001986826;
        Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
            exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;

 
          case {'meanNLNRRzyi_philibertplosone','meanNLNRRzyi_philibertplosone'}
        mu=[0.19 0.0037 ];
        
        switch crop
            case 'rice'
                Z=0;
            otherwise
                Z=0;
        end
        
        mu0=mu(1)+Z;
        mu1=mu(2);
        sigma0=0.72;
        sigma1=0.0025;
        Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
            exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;

        
        
         
         %  

%mu=[  ];

%sigma0=;
%sigma1=;

%     case 'NLNRRzyi_ricesep'
%         switch crop
%             case 'rice'
%                 Z=-1.139;
%             otherwise
%                 Z=0;
%         end
%         mu0=0.24+Z;
%         mu1=0.00376;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         
%         
%        % epsilon=normdist(0,tau^2,X);
%        % alpha0=normdist(mu0,sigma0.^2,X);
%        % alpha1=normdist(mu1,sigma1.^2,X);
%         
%        alpha0=randn(size(X))*sigma0+mu0;
%        alpha1=randn(size(X))*sigma1+mu1;
%        
%        
%        
%         Y=exp(alpha0+alpha1.*X)-exp(alpha0);
%         
%          case 'NLNRRzyi_ricesep_GLOBAL'
%         switch crop
%             case 'rice'
%                 Z=-1.139;
%             otherwise
%                 Z=0;
%         end
%         mu0=0.24+Z;
%         mu1=0.00376;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         
%         
%         %epsilon=normdist(0,tau^2,X);
%         %alpha0=normdist(mu0,sigma0.^2,X);
%         %alpha1=normdist(mu1,sigma1.^2,X);
% 
%         global HOLDRANDOMVARS  ALPHA0_MINUS_MU0 ALPHA1
% 
%         if isempty(HOLDRANDOMVARS)
%         
%         ALPHA1=mu1+sigma1*randn;
%         ALPHA0_MINUS_MU0=sigma0*randn;
%         
%         end
%         
%         alpha0=ALPHA0_MINUS_MU0 + mu0;
%         alpha1=ALPHA1;
%         
%       %  Y=alpha1;
%         Y=exp(alpha0+alpha1.*X)-exp(alpha0);
%       %  Y=exp(alpha0+alpha1.*X);
%           
%         
%         
%     case 'derivmeanNLNRR_ricesep'
%         % derivative of the mean of the model
%         switch crop
%             case 'rice'
%                 Z=-1.139;
%             otherwise
%                 Z=0;
%         end
%         mu0=0.24+Z;
%         mu1=0.00376;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) ).*...
%             ((2*(mu1+sigma1.^2*X).*(sigma1.^2))/(2*sigma1.^2) );
%     
%     case 'derivmeanNLNRR'
%         % derivative of the mean of the model
%         mu0=0.19;
%         mu1=0.00369;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) ).*...
%             ((2*(mu1+sigma1.^2*X).*(sigma1.^2))/(2*sigma1.^2) );
%         
%         
%     case 'medianNLNRR'
%         mu0=0.19;
%         mu1=0.00369;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         
%         % epsilon=normdist(0,tau^2,X);
%         % alpha0=normdist(mu0,sigma0.^2,X);
%         % alpha1=normdist(mu1,sigma1.^2,X);
%         
%         alpha0=mu0;
%         alpha1=mu1;
%         epsilon=0;
%         
%         Y=exp(alpha0+alpha1.*X)+epsilon;
%     case 'derivmedianNLNRR'
%         mu0=0.19;
%         mu1=0.00369;
%         sigma0=0.72;
%         sigma1=0.0025;
%         tau=1.94;
%         
%         % epsilon=normdist(0,tau^2,X);
%         % alpha0=normdist(mu0,sigma0.^2,X);
%         % alpha1=normdist(mu1,sigma1.^2,X);
%         
%         alpha0=mu0;
%         alpha1=mu1;
%         epsilon=0;
%         
%         Y=alpha1.*exp(alpha0+alpha1.*X)+epsilon;
%         
    case 'NLNRR_parammean_ricesep'


        if isempty(x_semian)
            load /Users/jsgerber/source/matlabgit/matlab/N2Opaper/NLNRR_parammean_ricesepparams
            load /Users/jsgerber/source/matlabgit/matlab/N2Opaper/NLNRR_parammean_ricesepparams_rice
        end
        switch crop
            case 'rice'
                
                Y=interp1(x_semian,meanY_semian_rice,X,'spline');
                YQ05=interp1(x_semian,YQ05_semian_rice,X,'spline');
                YQ95=interp1(x_semian,YQ95_semian_rice,X,'spline');
            otherwise
                Y=interp1(x_semian,meanY_semian,X,'spline');              
                YQ05=interp1(x_semian,YQ05_semian,X,'spline');
                YQ95=interp1(x_semian,YQ95_semian,X,'spline');
        end

        
    case 'NLNRR_parammean_ricesep_GCBSubmit'



        if isempty(x_semian)
            load /Users/jsgerber/sandbox/jsg070_N2Omodelling/jsg070b_WithManurenewstats/statistics/NLNRR_parammean_ricesepparams
            load /Users/jsgerber/sandbox/jsg070_N2Omodelling/jsg070b_WithManurenewstats/statistics/NLNRR_parammean_ricesepparams_rice
        end
        switch crop
            case 'rice'
                
                Y=interp1(x_semian,meanY_semian_rice,X,'spline');
                YQ05=interp1(x_semian,YQ05_semian_rice,X,'spline');
                YQ95=interp1(x_semian,YQ95_semian_rice,X,'spline');
            otherwise
                Y=interp1(x_semian,meanY_semian,X,'spline');              
                YQ05=interp1(x_semian,YQ05_semian,X,'spline');
                YQ95=interp1(x_semian,YQ95_semian,X,'spline');
        end

        
        
    case 'derivparammeanNLNRR_ricesep'
        
        if isempty(x_semian)
            load NLNRR_parammean_ricesepparams
            load NLNRR_parammean_ricesepparams_rice
        end
        
        % derivative of the mean of the model
        switch crop
            case 'rice'              
                Y=interp1(x_semian,dydn_rice,X,'spline');
            otherwise
                Y=interp1(x_semian,dydn,X,'spline');      
        end
        
        
    case 'correlatedparams_NLNRR_ricesep700'

sigmamat=[0.005723625 -1.260516e-05 -0.001436962
    -1.260516e-05 8.980901e-08 -7.550001e-06
    -0.001436962 -7.550001e-06 0.0703605];
   

    mu=[0.3033216 0.0033885 -0.9718765];
    sigma0=0.7066093;
    sigma1=0.001950911;
   
   
        R=chol(sigmamat);
        

        N=length(X);
        
        z=repmat(mu,N,1)+randn(N,3)*R;
        mu0=z(:,1);
        mu1=z(:,2);
        %     beta=z(:,3);
        beta=mu(3);

        
        switch    crop
            case 'rice'
                
                %  for j=1:N
                %      Y(j)=newNft(mu0(j)+beta(j),sigma0,mu1(j),sigma1,X(j));
                %  end
                Ypar=newNftparallel(mu0(:)+beta,sigma0(:),mu1,sigma1,X(:));
                Y=Ypar;
                
            otherwise
                %   for j=1:N
                %       Y(j)=newNft(mu0(j),sigma0,mu1(j),sigma1,X(j));
                %   end
                Ypar=newNftparallel(mu0(:),sigma0,mu1(:),sigma1,X(:));
                Y=Ypar;
        end
        
end

function Y=newNft(mu0,sigma0,mu1,sigma1,X);
% determine N2O emissions averaged over site years.  


Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*X).^2- mu1.^2)/(2*sigma1.^2) )- ...
    exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) )*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)/(2*sigma1.^2) )  ;

function Y=newNftparallel(mu0,sigma0,mu1,sigma1,X);
% determine N2O emissions averaged over site years.  


Y=exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)./(2*sigma0.^2) ).*exp( ((mu1+sigma1.^2.*X(:)).^2- mu1.^2)./(2*sigma1.^2) )- ...
    exp(  ( (mu0+sigma0.^2*1).^2- mu0.^2)/(2*sigma0.^2) ).*exp( ((mu1+sigma1.^2*0).^2- mu1.^2)./(2*sigma1.^2) )  ;

function y=normdist(mu,sigmasq,templatevar);

if nargin<3
    templatevar=NaN;
end
y=mu+randn(size(templatevar))*sqrt(sigmasq);