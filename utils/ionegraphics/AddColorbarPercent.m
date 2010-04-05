function AddColorbarPercent(Handle);
% ADDCOLORBARPERCENT - add a % sign to each number on colorbar
if nargin==0;
  Handle=gcf;
end

if fix(Handle)==Handle
  % Handle is an integer ... must be figure handle.  Assume its and
  % IonEFigure and look for colorbar accordingly.
  fud=get(Handle,'UserData');
  cbh=fud.ColorbarHandle;
else
 % user passed in a non-integer handle. Assume it is a handle to a colorbar.
  cbh=Handle;
end


xtl=get(cbh,'XTickLabel');

for j=1:size(xtl,1);
  xtlcell{j}=xtl(j,:);
end



for j=1:length(xtlcell);
  xtlcell{j}=[xtlcell{j} '%'];
end

set(cbh,'XTickLabel',xtlcell);


  
