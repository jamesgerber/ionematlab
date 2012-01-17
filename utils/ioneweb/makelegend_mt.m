function makeLegend(cmap,crop,yield,cmin,cmax,tmin,tmax)
% MAKELEGEND - make a legend for a KML doc
%
format long g;
tmps=strrep(strrep(crop,'nes', ' (other)'),'for',' (for silage)');
fig=figure('units','pixels','position',[500 500 300 300])
axes('position',[.15,.1,.7,.75],'visible','off')
colorbar('location','north')
colormap(cmap)
caxis([cmin cmax])
if yield==1
    text(.5,1.0,['Regional ' tmps ' yield (tonnes/ha):'],'horizontalalignment','center',...
        'verticalalignment','bottom','fontsize',12)
%     text(.5,.72,{'Opacity indicates percentage of',...
%         ['land used for ' tmps ' cultivation'],...
%         ['Minimum: ' num2str(tmin) '%'],['Maximum: ' num2str(tmax,3) '%']},...
%         'fontsize',12,'horizontalalignment','center','verticalalignment','top')
else
    text(.5,1.0,{'Percentage of land used',['for ' tmps ' cultivation:']},'horizontalalignment','center',...
        'verticalalignment','bottom','fontsize',12)
%     text(.5,.72,{['Opacity indicates ' tmps ' yield'],...
%         ['Minimum: ' num2str(tmin) ' tonnes/ha'],['Maximum: ' num2str(tmax,3) ' tonnes/ha']},...
%         'fontsize',12,'horizontalalignment','center','verticalalignment','top');
end
set(gcf,'PaperPositionMode','auto')
print -dbmp -r300 'tmp.bmp';
close(gcf)
a=imread('tmp.bmp');
a=imresize(a,[300 300]);
if yield==1
    a(80:90,:,:)=min(a(80:90,:,:),a(90:100,:,:));
    a(91:100,:,:)=a(101:110,:,:);
    a=imcrop(a,[0 20 300 80]);
    copyfile('logo.png',['outfiles/yield/' crop '_overlay/file/logo.png']);
    imwrite(a,['outfiles/yield/' crop '_overlay/file/legend.png'],'png','Alpha',1.0-((a(:,:,1)>250)&(a(:,:,2)>250)&(a(:,:,3)>250))*.15);
else
    a(90:100,:,:)=min(a(90:100,:,:),a(100:110,:,:));
    a(101:110,:,:)=a(111:120,:,:);
    a=imcrop(a,[0 0 300 110]);
    copyfile('logo.png',['outfiles/area/' crop '_overlay/file/logo.png']);
    imwrite(a,['outfiles/area/' crop '_overlay/file/legend.png'],'png','Alpha',1.0-((a(:,:,1)>250)&(a(:,:,2)>250)&(a(:,:,3)>250))*.15);
end