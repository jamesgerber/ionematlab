function a=normrnd(N);
% fills a with N gaussian random variables.  see Numerical recipes for algorithm.
persistent resetstate

if nargin==0
 N=1;
end

if ~(N>0) | isempty(resetstate)
   rand('state',sum(100*clock));  %reset random number generator
   resetstate=1;
   return
end


for j=1:ceil(N/2)

   rsq=2;
   while rsq>=1
      v1=2.0*rand(1)-1;
      v2=2.0*rand(1)-1;
      rsq=v1^2+v2^2;
   end
   fac=sqrt(-2.0*log(rsq)/rsq);
   g1=v1*fac;
   g2=v2*fac;
   
   a(j*2-1)=g1;
   a(min(j*2,N))=g2;
   
end
