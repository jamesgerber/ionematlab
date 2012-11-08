function squarefig
%SQUAREFIG - will set the aspect ratio of the current figure to 1:1

pos=get(gcf,'position');
xlim=get(gca,'Xlim');
ylim=get(gca,'Ylim');

%desired pos ratio

DPR=(xlim(2)-xlim(1))/(ylim(2)-ylim(1));

%change the width of x

disp(['Changing xwidth val from ' num2str(pos(3)) ' to ' ...
      num2str(pos(4)*DPR) ])
pos(3)=pos(4)*DPR;

set(gcf,'position',pos);
