function data=pullfromnetcdfvector(inputname,varname)
% get data from output from opengeneralnetcdf
%
%  data=pullfromnetcdfvector(Svector,varname)
%  data=pullfromnetcdfvector(filename,varname)
%

if ischar(inputname)
    Svector=opengeneralnetcdf(inputname);
else
    Svector=inputname;
end

counter=0;
for j=1:length(Svector)
    if isequal(Svector(j).varname,varname)
        data=Svector(j).Data;
        counter=counter+1;
    end
end

if counter>1
    error([' something wrong here in ' mfilename])
end
