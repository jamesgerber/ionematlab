function makewebdatakmls
makekml('5minmask.img', 'Land-Sea Mask','jet');
fclose all;
makekml('5minfdr.img', 'Flow Direction Data','jet');
fclose all;
makekml('5minfac.img', 'Flow Accumulation Data','jet');
fclose all;
makekml('5minriv.img', 'Rivers Delineation','jet');
fclose all;
makekml('5minshd.img', '55 Large Watersheds Delineation','jet');
fclose all;
makekml('5minint.img', 'Internally Draining Regions','jet');
fclose all;
makekml('5min19.img', '19 Large-Scale Drainage Regions','jet');
fclose all;
makekml('5min19o.img', 'Lakes Delineation','jet');
fclose all;

function makekml(file,name,colormap)
imgtoimage(file,colormap);
im=imread([file '.png']);
layeredkml(im,name);


    
function im=imgtoimage(file,colormap)
try
        matrix=readmtx(file,2160,4320,'int8');
catch 
try
        matrix=readmtx(file,2160,4320,'int16');
        if (max(max(matrix))==1)
            matrix=matrix*100;
        end
                max(matrix)
catch 
        'Oh no!'
        matrix=readmtx(file,2160,4320,'int32')/10000000;
end
end
        max(max(matrix))
eval(['colormap=' colormap '(max(max(matrix))+1);']);
colormap(1,:)=min(min(matrix));
imwrite(ind2rgb(round(matrix),colormap),[file '.png']);