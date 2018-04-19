function  [y,ybyterm]=evalqrmodel(b,modelterms,XS);
%evalQRmodel - evaluate quantile regression model
%
%  y=evalqrmodel(b,modelterms,XS);
%  [y,ybyterm]=evalqrmodel(b,modelterms,XS);
%
%  b          1xN vector 
%  modelterms 1xN cell array, each component must 'eval' as a matlab expression
%  XS         structure of 1xM vectors, usually named X1, X2, etc.
%
%    modelterms must be comprised of components such that eval(modelterms{j}) is a
%    valid matlab expression.   
%    XS must contain field X1 
%     
%
%

expandstructure(XS);

ybyterm=struct;

try
    y=X1*0;
catch
    error([' didn''t find field field for pre-allocating.  maybe update code']);
end
for j=1:length(modelterms)
    xtemp=eval(modelterms{j});
    y=y+xtemp*b(j);
    
    thisterm=strrep(makesafestring(modelterms{j}),'^','');
 
    thisterm=strrep(thisterm,'ones(size(X1))','intercept');
    thisterm=strrep(thisterm,'(','');
    thisterm=strrep(thisterm,')','');
    ybyterm=setfield(ybyterm,thisterm,xtemp*b(j));
    
end

