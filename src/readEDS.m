function [ebsd,eds] = readEDS(ebsd,Dat,fac)
%function [ebsd,eds] = readEDS(ebsd,Dat,fac)
%ebsd:  object of class ebsd in MTEX
%Dat:   Data structure from main script
%fac:   Cutting the distribution of EDS signal at 'fac'*std
%eds:   Structure containing EDS data
scrPrnt('SegmentStart','Reading in EDS data')
%% Find EDS channels in EBSD structure
propFields = fieldnames(ebsd.prop);                                        %Fieldnames of Property field
indEDS = find(cellfun(@(x) contains(x,Dat.EDS.identifier),propFields));    %Indices of EDS field names
answer = '';                                                               %Initialize answer for QuestDlg
modes = {'EBSD data','''csv'' files'};                                     %Choices of QuestDlg
if ~isempty(indEDS)
    scrPrnt('Step',sprintf('Found %.0f EDS channels in EBSD structure',size(indEDS,1)));
    answer = questdlg('EDS data was found with the EBSD data-set. Select which EDS data source to use',...
                      'Import EDS-data',modes{:},modes{1});                % User input
    if isempty(answer); error('Terminated by user'); end
end

%% Import EDS
eds.all = zeros(size(ebsd.prop.x));                                        %Initialize EDS All field
if strcmp(answer,modes{1})                                                 %Import EDS data from EBSD structure
    scrPrnt('Step','Importing EBSD data from EBSD structure');
    %Assign and rename fields
    for i = 1:size(indEDS,1) %Loop over EDS channels
        if Dat.EDS.act(i) %is active channel
            eds.(Dat.EDS.names{i}) = ebsd.prop.(propFields{indEDS(i)});    %Assign to field of 'eds' structure
            eds.all = eds.all + eds.(Dat.EDS.names{i});                    %Add channel to field 'all'
        end
    end
elseif isempty(answer) || strcmp(answer,modes{2})                          %Import EDS data from csv file structure
    scrPrnt('Step','Importing EDS data from folder of ''csv'' files');
    %Obtain file info
    h = msgbox(['Choose the folder containing the ''csv'' files. The filenames '...
                'must unambiguously contain the channel names ',sprintf('%s ',...
                 Dat.EDS.names{:}),' beginning with a capital letter and followed by whitespace for correct identification.'],...
                'Channel identification - Name Convention');               %Name convention Notice
    uiwait(h);                                                             %Wait for MsgBox to close
    [pathName] = uigetdir([Dat.EDS.inPath],...
                   'EDS-Data Input - Open folder containing *.csv files'); %Get folder with csv files
    if isempty(pathName); error('Terminated by user'); end
    fInfo = dir(pathName);                                                 %Get file info 
    fNames = {fInfo(contains({fInfo.name},'.csv')).name};                  %Find 'csv' files
    %Read in csv files 
    for i = 1:length(fNames) %Loop over EDS channels
        if Dat.EDS.act(i) %is active channel
            ind = find(contains(fNames,[Dat.EDS.names{i},' ']));           %Find corresponding csv file to EDS channel
            if isempty(ind) %Error - no file found
                error(['Did not find ''csv'' file matching channel ''',Dat.EDS.names{i},'''']);
            elseif size(ind,2)>1 %Error  too many files found
                error(['More than one ''csv'' file matching channel ''',Dat.EDS.names{i},'''']); 
            else
                scrPrnt('SubStep',sprintf('Reading EDS data from file ''%s''',fNames{ind}));
            end                       
            eds.(Dat.EDS.names{i}) = csvread([pathName,'/',fNames{ind}]);  %Read in data
            %Check conformity of spatial data with EBSD data set
            chkSz = size(eds.(Dat.EDS.names{i})) - size(eds.all);          %Size difference to EBSD data-set        
            if chkSz(1) == 0 && chkSz(2) == 1                              %Csv file contains extra column
               if any(eds.(Dat.EDS.names{i})(:,end))                       %Check that last column is all zeros
                  error(['EDS-data from ''ctf'' file ''',fNames{ind},''' does not match EBDS data set']);
               end
               eds.(Dat.EDS.names{i}) = eds.(Dat.EDS.names{i})(:,1:end-1); %Remove common column of zeros
            elseif chkSz(1) ~= 0 || ~any(chkSz(2) == [0,1])                %Csv file has wrong format
               error(['EDS-data from ''ctf'' file ''',fNames{ind},''' does not match EBDS data set']);
            end
            eds.(Dat.EDS.names{i}) = limitSignal(eds.(Dat.EDS.names{i}),fac);%Normalize and remove spikes
            eds.all = eds.all + eds.(Dat.EDS.names{i});                    %Add to EDS All
        end
    end    
else
    error('No valid choice.');
end
%% Creating EDS channel for processing
scrPrnt('Step','Creating EDS channel for processing');
Dat.EDS.names = Dat.EDS.names(find(Dat.EDS.act));                          %Remove inactive channel names
procInd = zeros(size(Dat.EDS.names));                                      %Initialize processing Index array
%% Get positive EDS channels for processing
scrPrnt('Step','Choosing EDS channels with POSITIVE weighting in processing');
[indP,~] = listdlg('PromptString','Choose EDS channels for POSITIVE weighting in Segmentation process:',...
                       'SelectionMode','multiple','ListString',Dat.EDS.names,...
                       'ListSize',[450 150]);                              %Get positive channels
if isempty(indP)
    scrPrnt('SubStep',sprintf('Positively weighted channels: none'));
else                   
    scrPrnt('SubStep',sprintf('Positively weighted channels: %s',sprintf('%s ',Dat.EDS.names{indP})));
end
procInd(indP) = 1;                                                         %Set processing state
unusedInd = find(~procInd);                                                %Remaining channels
%% Get negative EDS channels for processing
scrPrnt('Step','Choosing EDS channels with NEGATIVE weighting in processing');
[indN,~] = listdlg('PromptString','Choose EDS channels for NEGATIVE weighting in Segmentation process:',...
                       'SelectionMode','multiple','ListString',Dat.EDS.names(unusedInd),...
                       'ListSize',[450 150]);
if isempty(indN)
    scrPrnt('SubStep',sprintf('Negatively weighted channels: none'));
else
    scrPrnt('SubStep',sprintf('Negatively weighted channels: %s',sprintf('%s ',Dat.EDS.names{unusedInd(indN)})));
end
%% Determine channel weighting
procInd(unusedInd(indN)) = -1;                                             %Set processing status
chNr = -find(procInd==-1);                                                 %Get negative channel numbers for processing
chNr = [chNr, find(procInd==1)];                                           %Get negative channel numbers for processing
%% Assemble processing EDS channel
scrPrnt('Step','Assembling processing EDS channel');
% eds.all(eds.all == 0) = 0.01;
eds.proc = zeros(size(eds.all));                                           %Initialize EDS Processing array
for i = 1:size(chNr,2)
    tmp = eds.(Dat.EDS.names{abs(chNr(i))});                               %Get EDS channel
    if chNr(i)<0
       tmp = 1-tmp;                                                        %Invert
    end
%     tmp = tmp./eds.all;                                                  %Normalize pixel intensities
    tmp = (tmp-min(min(tmp)))/(max(max(tmp))-min(min(tmp)));               %Normalize intensity [0 1]
    eds.proc = eds.proc + tmp;                                             %Add EDS channel to processing channel
end
%% Normalizing processing EDS channel
scrPrnt('Step','Normalizing EDS channel');
eds.proc = limitSignal(eds.proc,fac);                                        %Normalize and remove spikes
eds.opt.procName = sprintf('%s ',Dat.EDS.names{chNr(chNr>0)});             %Name of EDS profile for processing
if any(chNr<0) %Check for negatively weighted channels
    eds.opt.procName = [eds.opt.procName,'and inverted ',sprintf('%s ',...
                        Dat.EDS.names{abs(chNr(chNr<0))})];                %Add inverted channels to Name string
end
%% Remove EDS data from EBSD structure
if ~isempty(indEDS) %Check if EDS data is in EBSD structure
    scrPrnt('Step','Removing EDS data from EBSD structure');
    for i = 1:size(indEDS,1) %Loop over channels  
         ebsd.prop = rmfield(ebsd.prop,propFields{indEDS(i)});             %Remove ebsd field
    end
end