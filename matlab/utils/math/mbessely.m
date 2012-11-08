function mb = mbessely(alpha,xx)
%BESSELJ - Bessel functions of the first kind of negative index
% 
% uses reflection formula.  see numerical recipes
%

if alpha >= 0
 disp('alpha not negative');
 return
end

nu = - alpha;
mb = sin(pi*nu)*besselj(nu,xx)+cos(pi*nu)*bessely(nu,xx);