function IM=ScaleToDouble(Image,cls)
if (nargin==1)
    cls=class(Image);
end
if strcmpi(cls,'double')
    IM=double(Image);
    if (max2d(Image)>1)
        if (max2d(Image<256))
            IM=IM/255;
        else IM=IM/65535;
        end
    end
end
if strcmpi(cls,'uint8')
    IM=double(Image)/255;
end
if strcmpi(cls,'uint16')
    IM=double(Image)/65535;
end