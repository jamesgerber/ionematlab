function outmap=embedWFDvector(vector);
% embedWFDvector - embed a vector of WATCH data into a 30minx30min matrix
%
%
%   S=OpenGeneralNetCDF('Tair_WFD_190012.nc');
%   outmap=embedWFDvector(S(6).Data(:,1))-273.15;
%   nsg(outmap,'title','Dec 1, 0000','filename','on','resolution','-r400','caxis',[-60 40],'units','deg C')
%
%
%  See Also:  getstripe

persistent WFDgrid iivect
if isempty(WFDgrid)
    load WFDindices iivect
end


outmap=datablank(NaN,'30min');
outmap(iivect)=vector;


% % ii=find(WFDgrid>0);
% % 
% % for j=1:67420
% %     ii=find(WFDgrid==j);
% %     iivect(j)=ii;
% %     outmap(ii)=vector(j);
% % end
% % 
    

