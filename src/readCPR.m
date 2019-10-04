function ebsd = readCPR(inPath,phStr)
scrPrnt('SegmentStart','Reading in EBSD data')
%% Define Mtex plotting convention as X = right, Y = up
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize',16);
%% Loading Cpr file
scrPrnt('Step',sprintf('Loading ''cpr'' file containing EBSD and optionally EDS data'));
[FileName,inPath] = uigetfile([inPath,'/','*.cpr'],'EBSD-Data Input - Open *.cpr file');
if FileName == 0
    error('The program was terminated by the user');
else
    scrPrnt('Step',sprintf('Loading file ''%s''',FileName));
    [ebsd,cpr] = loadEBSD_crc([inPath FileName],'interface','crc','convertSpatial2EulerReferenceFrame');
    ebsd = ebsd.gridify;
    scrPrnt('Step',sprintf('Loaded file ''%s'' succesfully',FileName));
end
%% Renaming Phases (Minerals)
phaseIDs = unique(ebsd('indexed').phaseId);
phases = unique(ebsd('indexed').phase);
if ~isempty(intersect(ebsd('indexed').mineralList,phStr)) && all(contains(intersect(ebsd('indexed').mineralList,phStr),phStr)) %Check if all phase names agree with name in EBSD data set
    scrPrnt('Step',sprintf('Phases %sautomatically identified',sprintf('''%s'' ',phStr{:}))); 
else
    scrPrnt('Step','Identifying phases');
    for i = 1:size(phases,1)
       mineral = ebsd(num2str(phases(i))).mineral;
       scrPrnt('SubStep',sprintf('''%s''',mineral));
       [ind,~] = listdlg('PromptString',['Find phase name corresponding to ''',mineral,''':'],...
                               'SelectionMode','single','ListString',phStr,...
                               'ListSize',[300 150]);
        ebsd.CSList{phaseIDs(i)}.mineral = phStr{ind};                %Rename phases
    end
end
%% Save output data
ebsd.opt.fName = FileName;                                                 %Save filename
ebsd.opt.cprData = cpr;                                                    %Save cpr data