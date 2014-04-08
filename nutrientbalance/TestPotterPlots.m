% produce graphs to corrobate our ability to reproduce results in Potter et
% al.

ManureBaseDir=[ iddstring '/misc/manure'];
%SN=OpenGeneralNetCDF([ManureBaseDir '/Nmanure.nc']);
SP=OpenGeneralNetCDF([ManureBaseDir '/Pmanure.nc']);

%Nmanure=disaggregate_rate(SN(6).Data,6).*(ca./(pa+ca));  %Estmiate of manure produced on feedlot.
Pmanure=disaggregate_rate(SP(6).Data,6);

clear NSS

NSS.categorical='on';
NSS.categoryranges={[0 0.01],[0.01 1],[1 3],[3 5],[5 10],[10 20],[20 40],[40 75]}
%NSS.categoryvalues={'[0 4]','[4 6]','[6 8]','[8 20]'}
NSS.cmap={[1 1 1],...
    [250 250 250]/255,... % [25 233 189]/255,...
    [255 241 63]/255,...
    [98 186 88]/255,...
    [109 184 228]/255,...
    [20 104 163]/255,...
    [73 82 104]/255,...
    [250 199 182]/255};
NiceSurfGeneral(SP(6).Data,NSS);
