function x=ismalthus
%is malthus returns 1 if called from malthus

a=dir('/Users');

if length(a) > 20
    x=1;
else
    x=0;
end