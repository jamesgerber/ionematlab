function a=strident(str)
% strident - create a unique number for the given string
a=0;
for i=1:length(str)
    a=a+(128^(i-1))*sum(str(i));
end
