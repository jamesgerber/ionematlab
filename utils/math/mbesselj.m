function mb = mbesselj(alpha,xx)
%BESSELJ Bessel functions of the first kind of negative index
% 
% uses reflection formula.  see numerical recipes
%

if alpha >= 0
 disp('alpha not negative');
 return
end

nu = - alpha;
mb = cos(pi*nu)*besselj(nu,xx) - sin(pi*nu)*bessely(nu,xx);

return;
end
