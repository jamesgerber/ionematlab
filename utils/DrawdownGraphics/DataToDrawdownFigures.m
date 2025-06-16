function DataToDrawdownFigures(raster,NSS,filenameroot,outputfolder,regionlist);
% DataToDrawdownFigures - make a bunch of figures, save output
%
%  DataToDrawdownFigures(raster,NSS,filenameroot,outputfolder,regionlist)
%
% Example
% DataToDrawdownFigures(area2020*100,NSS,'RiceCultivationArea','finalfigsanddata/',{'SEAsia'});
%
%  DataToDrawdownFigures(area2020*100,'','RiceCultivationArea','finalfigsanddata/','');
%   without 2nd argument, just output the data and return
%
%  if outputfolder is empty, return doing nothing (this allows a hack to
%  run through a script without actually doing the outputs)


if isempty(outputfolder)
    disp(['outputfolder argument is empty, returning']);
    return
end



if nargin<4
    outputfolder='figures/';
end
mkdir(outputfolder);
mkdir([outputfolder '/data_geotiff']);
mkdir([outputfolder '/data_matlabfigure']);
mkdir([outputfolder '/figs_blackbackground']);
mkdir([outputfolder '/figs_whitebackground']);
mkdir([outputfolder '/figs_whitebackground_notitle']);
mkdir([outputfolder '/figs_blackbackground_notitle']);
mkdir([outputfolder '/figs_blackbackground_notitlenounits']);
mkdir([outputfolder '/figs_whitebackground_notitlenounits']);
mkdir([outputfolder '/regionalfigs'])
mkdir([outputfolder '/regionalfigs/figs_blackbackground']);
mkdir([outputfolder '/regionalfigs/figs_whitebackground']);
mkdir([outputfolder '/regionalfigs/figs_whitebackground_notitle']);
mkdir([outputfolder '/regionalfigs/figs_blackbackground_notitle']);
mkdir([outputfolder '/regionalfigs/figs_blackbackground_notitlenounits']);
mkdir([outputfolder '/regionalfigs/figs_whitebackground_notitlenounits']);

if nargin<5
    regionlist={};
end

if ~iscell(regionlist)
    regionlist={regionlist};
end

% let's output data in front, then if NSS is empty return

% now save data
extranotes=['produced ' datestr(now) ' in ' pwd ]
globalarray2geotiffwithnodatavalue(raster,[outputfolder '/data_geotiff/' filenameroot '_data.tif']);

if isempty(NSS)
    disp(['NSS is empty, returning after outputting data'])
    return
end


if isfield(NSS,'plotflag')
    if isequal(lower(NSS.plotflag),'off');
        disp(['plotflag=off, returning'])
   return
    end
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

if numel(raster)<=prod(2160*4320*4)
% only make this if size is 2.5 minutes or larger

    OS=nsg(raster,NSS);
    unix(['cp temp.png ' outputfolder '/figs_whitebackground' filesep filenameroot '_WhiteBackground.png'])
    filename=[outputfolder '/figs_blackbackground' filesep filenameroot '_BlackBackground.png'];
    maketransparentoceans_noant_nogridlinesnostates_removeislands('temp.png',filename,[1 1 1],1);

    % now remove units
    if isfield(NSS,'title')
        NSS=rmfield(NSS,'title');
    end
    if isfield(NSS,'Title')
        NSS=rmfield(NSS,'Title');
    end
    NSSnotitle=NSS;

    OS=nsg(raster,NSS);
    unix(['cp temp.png ' outputfolder '/figs_whitebackground_notitle' filesep filenameroot '_WhiteBackground_NoTitle.png'])
    filename=[outputfolder '/figs_blackbackground_notitle' filesep filenameroot '_BlackBackground_NoTitle.png'];
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
    unix(['cp temp.png ' outputfolder '/figs_whitebackground_notitlenounits' filesep filenameroot '_WhiteBackground_NoTitleNoUnits.png'])
    filename=[outputfolder '/figs_blackbackground_notitlenounits' filesep filenameroot '_BlackBackground_NoTitleNoUnits.png'];
    maketransparentoceans_noant_nogridlinesnostates_removeislands('temp.png',filename,[1 1 1],1);

    % let's save data for future matlab figure
    save([outputfolder '/data_matlabfigure/' filenameroot '_figdata'],'raster','NSSorig','regionlist','filenameroot','outputfolder','extranotes');
else



    if isfield(NSS,'title')
        NSS=rmfield(NSS,'title');
    end
    if isfield(NSS,'Title')
        NSS=rmfield(NSS,'Title');
    end
    NSSnotitle=NSS;
    % now remove units
    if isfield(NSS,'units')
        NSS=rmfield(NSS,'units');
    end
    if isfield(NSS,'Units')
        NSS=rmfield(NSS,'Units');
    end
    NSSnotitlenounits=NSS;

end

if numel(regionlist)>0
    if ~isempty(regionlist{1})   % in case get passed an empty region
        for j=1:numel(regionlist)
            [outputfilename,DataResolution,PrintResolution,Region]=MakeNiceRegionalFigs(raster,regionlist{j},NSSorig,'temp.png');
            unix(['cp ' outputfilename ' ' outputfolder '/regionalfigs/figs_whitebackground/' filenameroot '_' Region 'WhiteBackground.png'])
            maketransparentOcReg_noant_nogridlinesnostates_removeislands...
                (outputfilename,[outputfolder '/regionalfigs/figs_blackbackground/' filenameroot '_' Region '.png'],[1 1 1],1,Region,PrintResolution,DataResolution);

            [outputfilename,DataResolution,PrintResolution,Region]=MakeNiceRegionalFigs(raster,regionlist{j},NSSnotitle,'temp.png');
            unix(['cp ' outputfilename ' ' outputfolder '/regionalfigs/figs_whitebackground_notitle/' filenameroot '_' Region '_NoTitle_WhiteBackground.png'])
            maketransparentOcReg_noant_nogridlinesnostates_removeislands...
                (outputfilename,[outputfolder '/regionalfigs/figs_blackbackground_notitle/' filenameroot '_' Region '_NoTitle.png'],[1 1 1],1,Region,PrintResolution,DataResolution);

            [outputfilename,DataResolution,PrintResolution,Region]=MakeNiceRegionalFigs(raster,regionlist{j},NSSnotitlenounits,'temp.png');
            unix(['cp ' outputfilename ' ' outputfolder '/regionalfigs/figs_whitebackground_notitlenounits/' filenameroot '_' Region '_NoTitleNoUnits_WhiteBackground.png'])
            maketransparentOcReg_noant_nogridlinesnostates_removeislands...
                (outputfilename,[outputfolder '/regionalfigs/figs_blackbackground_notitlenounits/' filenameroot '_' Region '_NoTitleNoUnits.png'],[1 1 1],1,Region,PrintResolution,DataResolution);
        end
    end
end



