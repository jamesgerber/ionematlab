function DataToDrawdownFigures(raster,NSS,filenameroot,outputfolder,regionlist);
% DataToDrawdownFigures - make a bunch of figures, save output
%
%  DataToDrawdownFigures(raster,NSS,filenameroot,outputfolder,regionlist)
%
% Example
% DataToDrawdownFigures(area2020*100,NSS,'RiceCultivationArea','finalfigsanddata/',{'SEAsia'});

if nargin<4
    outputfolder='figures/';
end
mkdir(outputfolder);
mkdir([outputfolder '/data_geotiff']);
mkdir([outputfolder '/data_matlabfigure']);
mkdir([outputfolder '/regionalfigs'])

if nargin<5
    regionlist={};
end


% look for figurehandle field in NSS

if isfield(NSS,'figurehandle') & isgraphics(NSS.figurehandle);
    % everything fabulous, let's write to this figure
else
    nsgfig=figure;
    NSS.figurehandle=nsgfig;
end




NSSorig=NSS;

% first a drawdown blackbackground figure with title, units as passed in
OS=nsg(raster,NSS);
unix(['cp temp.png ' outputfolder filesep filenameroot '_WhiteBackground.png'])
filename=[outputfolder filesep filenameroot '_BlackBackground.png'];
maketransparentoceans_noant_nogridlinesnostates_removeislands('temp.png',filename,[1 1 1],1);

% now remove units
if isfield(NSS,'title')
    NSS=rmfield(NSS,'title');
end
if isfield(NSS,'Title')
    NSS=rmfield(NSS,'Title');
end
OS=nsg(raster,NSS);
NSSnotitle=NSS;
unix(['cp temp.png ' outputfolder filesep filenameroot '_WhiteBackground_NoTitle.png'])
filename=[outputfolder filesep filenameroot '_BlackBackground_NoTitle.png'];
maketransparentoceans_noant_nogridlinesnostates_removeislands('temp.png',filename,[1 1 1],1);

% now remove units
if isfield(NSS,'units')
    NSS=rmfield(NSS,'units');
end
if isfield(NSS,'Units')
    NSS=rmfield(NSS,'Units');
end
NSSnotitlenounits=NSS;
OS=nsg(raster,NSS);
unix(['cp temp.png ' outputfolder filesep filenameroot '_WhiteBackground_NoTitleNoUnits.png'])
filename=[outputfolder filesep filenameroot '_BlackBackground_NoTitleNoUnits.png'];
maketransparentoceans_noant_nogridlinesnostates_removeislands('temp.png',filename,[1 1 1],1);



% now save data
extranotes=['produced ' datestr(now) ' in ' pwd ]
globalarray2geotiffwithnodatavalue(raster,[outputfolder '/data_geotiff/' filenameroot '_data.tif']);
save([outputfolder '/data_matlabfigure/' filenameroot '_figdata'],'raster','NSSorig','regionlist','filenameroot','outputfolder','extranotes');


if numel(regionlist)>0
    for j=1:numel(regionlist)
        [outputfilename,DataResolution,PrintResolution,Region]=MakeNiceRegionalFigs(raster,regionlist{j},NSSorig,'temp.png');
        unix(['cp ' outputfilename ' ' outputfolder '/regionalfigs/' filenameroot '_' Region 'WhiteBackground.png'])
        maketransparentOcReg_noant_nogridlinesnostates_removeislands...
     (outputfilename,[outputfolder '/regionalfigs/' filenameroot '_' Region '.png'],[1 1 1],1,Region,PrintResolution,DataResolution);
 
        [outputfilename,DataResolution,PrintResolution,Region]=MakeNiceRegionalFigs(raster,regionlist{j},NSSnotitle,'temp.png');
        unix(['cp ' outputfilename ' ' outputfolder '/regionalfigs/' filenameroot '_' Region '_NoTitle_WhiteBackground.png'])
        maketransparentOcReg_noant_nogridlinesnostates_removeislands...
     (outputfilename,[outputfolder '/regionalfigs/' filenameroot '_' Region '_NoTitle.png'],[1 1 1],1,Region,PrintResolution,DataResolution);
 
        [outputfilename,DataResolution,PrintResolution,Region]=MakeNiceRegionalFigs(raster,regionlist{j},NSSnotitlenounits,'temp.png');
        unix(['cp ' outputfilename ' ' outputfolder '/regionalfigs/' filenameroot '_' Region '_NoTitleNoUnits_WhiteBackground.png'])
        maketransparentOcReg_noant_nogridlinesnostates_removeislands...
     (outputfilename,[outputfolder '/regionalfigs/' filenameroot '_' Region '_NoTitleNoUnits.png'],[1 1 1],1,Region,PrintResolution,DataResolution);

    end
end

