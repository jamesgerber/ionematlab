  GDDBinCenters=double((GDDBinEdges(1:end-1)+GDDBinEdges(2:end)))/2;
        PrecBinCenters=double((PrecBinEdges(1:end-1)+PrecBinEdges(2:end)))/2;
    
        for iG=1:N;
            for iP=1:N;
        
              %  YieldMatrix(iG,iP)=MedianYield( (iG-1)*N+iP);
                YieldMatrix(iG,iP)=TotalYield( (iG-1)*N+iP);
                ExplanVar((iG-1)*N+iP,1:3)=[1 GDDBinCenters(iG) PrecBinCenters(iP)];
                
            end
        end
        YieldMatrix=double(YieldMatrix);
        
	
        figure
        surface(GDDBinCenters,PrecBinCenters,YieldMatrix.');
        colorbar
        xlabel('GDD')
        ylabel(WetFlag)
        [B,BINT,R,RINT,STATS] = regress(MedianYield.', ExplanVar)
        r2 = STATS(1)
        pval = STATS(3)
        title(['Med. Yield f/ ' cropname ' by Clim. Bin (' WetFlag '), r2=' num2str(r2) ' pval=' num2str(pval)])
        untex
        
        figure
        scatter3(ExplanVar(:,2),ExplanVar(:,3),MedianYield,'filled');
        hold on
        x1fit=linspace(GDDBinCenters(1),GDDBinCenters(end),20);
        x2fit=linspace(PrecBinCenters(1),PrecBinCenters(end),20);
        [X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
        b=B;
        YFIT = b(1) + b(2)*X1FIT + b(3)*X2FIT ;
        mesh(X1FIT,X2FIT,YFIT)
        xlabel('GDD')
        ylabel(WetFlag)
        zlabel('Median Yield')
        title([cropname 'Matlab regression code.  y=' num2str(b(2)) 'GDD+' num2str(b(3)) WetFlag '+' num2str(b(1)) ])
        untex
        
        %% Weighted linear best fit.
        y=MedianYield;
        w=TotalArea;
        G=ExplanVar(:,2);
        M=ExplanVar(:,3);
        
        
        
        ii=find(isfinite(w));
        [a,b,c,Rsq]=WeightedLinearLeastSquares(y(ii),G(ii),M(ii),w(ii))
        figure
       % scatter3(G,M,y,'filled');
               scatter3(G,M,y,w/max(w)*300,'filled');
        hold on
        x1fit=linspace(GDDBinCenters(1),GDDBinCenters(end),20);
        x2fit=linspace(PrecBinCenters(1),PrecBinCenters(end),20);
        [X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
        YFIT=a*X1FIT+b*X2FIT+c;
        mesh(X1FIT,X2FIT,YFIT)
        xlabel('GDD')
        ylabel(WetFlag)
        zlabel('Median Yield')
        title([cropname '. Weighted fit by area.  y=' num2str(a) 'GDD+' num2str(b) WetFlag '+' num2str(c) '.Weighted Rsq=' num2str(Rsq,3)])
        OutputFig('Force')
        untex
        
        
        ii=find(isfinite(w));
        [a,b,c,Rsq]=WeightedLinearLeastSquares(y(ii),G(ii),M(ii),w(ii)*0+1)
        figure
        scatter3(G,M,y,'filled');
        hold on
        x1fit=linspace(GDDBinCenters(1),GDDBinCenters(end),20);
        x2fit=linspace(PrecBinCenters(1),PrecBinCenters(end),20);
        [X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
        YFIT=a*X1FIT+b*X2FIT+c;
        mesh(X1FIT,X2FIT,YFIT)
        xlabel('GDD')
        ylabel(WetFlag)
        zlabel('Median Yield')
        title([cropname '. Best fit.  Unweighted. y==' num2str(a) 'GDD+' num2str(b) WetFlag '+' num2str(c) '. Rsq=' num2str(Rsq)])
        untex
    


