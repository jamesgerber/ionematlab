% script to determine a crop rank listing
fid=fopen([iddstring 'misc/Reconcile_Monfreda_FAO_cropnames.txt'],'r');
C = textscan(fid,'%s%s%s%s','Delimiter',tab,'HeaderLines',1);
fclose(fid)

nums_unsort=C{1};
mnames_unsort=C{2};
faonames_unsort=C{3};
group_unsort=C{4};

[dum,ii]=sort(mnames_unsort);

nums=nums_unsort(ii);
mnames=mnames_unsort(ii);
faonames=faonames_unsort(ii);
group=group_unsort(ii);

%for j=2:length(nums)

clear AllAreas

N=8;
Bounds=round(linspace(1,length(CropMaskIndices),N))




for Nouter=1:N-1
    %Nouter=1;
    
    ii=CropMaskIndices(Bounds(Nouter):Bounds(Nouter+1));
    
    AllAreas(length(mnames),length(ii))=-1;  %preallocate array.
    
    
    if isequal(Nouter,1)
        
        fid=fopen('CropNameKey.txt','w')
    end
    for j=1:length(mnames);
        %for j=1:20
        ThisCrop=mnames{j}
        %try
        %  ls([iddstring '/Crops2000/crops/' ThisCrop '_5min.nc' ]);
        %
        %catch
        %  disp(['prob for '  iddstring '/Crops2000/crops/' ThisCrop '_5min.nc' ...
        %	 ]);
        %  end
        
        
        S=OpenNetCDF([iddstring '/Crops2000/crops/' ThisCrop '_5min.nc' ]);
        Area=S.Data(:,:,1);
        Area(Area>9e9)=-9999;
        
        AllAreas(j,1:length(ii))=Area(ii);
        if isequal(Nouter,1)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n',int2str(j),mnames{j},faonames{j},group{j},nums{j});
        end
        
    end
    if isequal(Nouter,1)
        
        fclose(fid)
    end
    [Y,jj]=sort(AllAreas,1,'descend');
    
    save(['Workspace' num2str(Nouter)]);
    clear AllAreas
end


%% now parse individual files
% load each one.
% keep top 20 crops.
% also determine total area.
N=8

for Nouter=1:N-1
    
    S=load(['Workspace' num2str(Nouter)]);
    kk=S.Bounds(Nouter):S.Bounds(Nouter+1);
    
    
    AreaSum_sub=sum(S.Y,1);
    
    TopCrops_sub=S.jj(1:20,:);
    
    AreaSum(kk)=AreaSum_sub;
    TopCrops(1:20,kk)=TopCrops_sub;
end

% print out
for j=1:length(nums)
    nums_numeric(j)=str2num(nums{j});
end

CMii=CropMaskIndices;

for j=1:20;
    PopularCrop=CropMaskLogical*0;
    
    PopularCrop(CMii)=TopCrops(j,:);
    
    DAS.Units=['Codes based on alphabet-sorted Monfreda data names. 1=abaca ...' ...
        ' 175=yautia'];
    DAS.Notes=['Processed ' datestr(now)];
    WriteNetCDF(single(PopularCrop),'PrevalentCrop',['PrevalentCropRank' int2str(j) '.nc'],DAS);
    %make a version with FAO Codes
    
    PopCropMonfredaVector=TopCrops(j,:);
    PopCropFAOVector=PopCropMonfredaVector*0;
    for m=1:length(PopCropMonfredaVector);
        thismi=PopCropMonfredaVector(m);
        PopCropFAOVector(m)=nums_numeric(thismi);
    end

    PopCropFAO=DataBlank;
    PopCropFAO(CMii)=PopCropFAOVector;
     DAS.Units=['Codes from FAO.  e.g. Maize=56'];
    DAS.Notes=['Processed ' datestr(now)];
    WriteNetCDF(single(PopCropFAO),'PrevalentCrop',['PrevalentCropRank_FAOCodes_' int2str(j) '.nc'],DAS);   
end
