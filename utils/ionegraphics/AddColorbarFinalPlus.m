function AddColorbarFinalPlus(Handle);
% AddColorbarFinalPlus - add a "+"  to final number on colorbar
if nargin==0;
    Handle=gcf;
end

if fix(Handle)==Handle
    % Handle is an integer ... must be figure handle.  Assume it is an
    % IonEFigure and look for colorbar accordingly.
    fud=get(Handle,'UserData');
    cbh=fud.ColorbarHandle;
else
    % user passed in a non-integer handle. Assume it is a handle to a colorbar.
    cbh=Handle;
end


xtl=get(cbh,'XTickLabel');
N=size(xtl,1);
C=size(xtl,2);
for j=1:N;
    xtlcell{j}=xtl(j,:);
end



for j=1:length(xtlcell);  %only this line changed from AddColorbarPercent
    tmp=xtlcell{j};
    tmp=strrep(tmp,' ','');
  
    if j<length(xtlcell)
      %  xtlcell{j}=[ tmp '  '];
    else
        xtlcell{j}=[ '>' tmp ' '];
    end
    %  xtlcell{j}=[ '\geq ' tmp ];  %doesn't work ... no tex interpreter
    %  for colorbar
end

%set(cbh,'XTickLabel',xtlcell);
xtlnew= strvcat(xtlcell);
set(cbh,'XTickLabel',xtlnew);
set(cbh,'XTickMode','manual')





