function imgtoimage(file,colormap)
try
        matrix=readmtx(file,2160,4320,'int16');
catch 
            matrix=readmtx(file,2160,4320,'int32');
end
eval(['colormap=' colormap '(max(max(matrix))+1);']);
colormap(1,:)=0;
imwrite(ind2rgb(round(matrix),colormap),[file '.png']);