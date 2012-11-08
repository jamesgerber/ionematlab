function imgtoimage(file,colormap)
% IMGTOIMAGE - resave a file containing a matrix as a .png image
%
% SYNTAX
% imgtoimage(file,colormap) - save the matrix in file as a png with the
% same name (but the png extension) using the specified colormap
try
        matrix=readmtx(file,2160,4320,'int16');
catch 
            matrix=readmtx(file,2160,4320,'int32');
end
eval(['colormap=' colormap '(max(max(matrix))+1);']);
colormap(1,:)=0;
imwrite(ind2rgb(round(matrix),colormap),[file '.png']);