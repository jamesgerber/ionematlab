function y=evalmodel(b,modelterms,XS);
%evalQRmodel - evaluate quantile regression model
%
%XS must contain field X1 
% modelterms must 'eval' out to a matlab expression

expandstructure(XS);

try
y=X1*0;
catch
   error([' didn''t find field field for pre-allocating.  maybe update code']);
end
for j=1:length(modelterms)
    xtemp=eval(modelterms{j});
    y=y+xtemp*b(j);
end

