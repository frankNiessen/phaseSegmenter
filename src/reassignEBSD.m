function ebsdOut = reassignEBSD(ebsdBase,ebsdUpper,ebsdLower,Dat)
%function ebsdOut = reassignEBSD(ebsdBase,ebsdUpper,ebsdLower,Dat)
%ebsdBase: Base EBSD map from which a certain segment should be replaced by
%          a new set of EBSD data
%ebsdUpper:Upper threshold EBSD data
%          (Must be single phase + optinional 'notIndexed' phase)
%ebsdUpper:Lower threshold EBSD data
%          (Must be single phase + optinional 'notIndexed' phase)
%Dat:      Structure containing data structure information
scrPrnt('SegmentStart','Reassigning EBSD data');
%% User input - Threshold selection
choices = {'Above threshold','Below threshold'};
answer = questdlg('Do you want to assign the EBSD data above or below the EDS-threshold value to a new phase?', ...
	'Reassignment of EBSD data', choices{1},choices{2},choices{1});
if isempty(answer); error('Terminated by user'); end
%% User input - Phase selection
[ind,~] = listdlg('PromptString','Which phase would you like to assign the segmented EBSD data to?',...
                       'SelectionMode','single','ListString',Dat.EBSD.phases,...
                       'ListSize',[450 150]);
if isempty(ind); error('Terminated by user'); end
%% User input - Assigment of EBSD spatial data
if strcmp(answer,choices{1})
    ebsdSegm = ebsdUpper;
    scrPrnt('Step','Reassigning data above EDS threshold level'); 
elseif strcmp(answer,choices{2})
    ebsdSegm = ebsdLower;
    scrPrnt('Step','Reassigning data below EDS threshold level'); 
end
%% User input - Assigment of EBSD orientation data
segmPhase = unique(ebsdSegm.mineralList(ebsdSegm.phaseId));                %Phases of segmented EBSD data
if strcmp(segmPhase,Dat.EBSD.phases(ind)) %Old and new phase agree
   scrPrnt('Step','Keeping phase data and orientations in new EBSD segment unaltered'); 
   ebsdSubs = ebsdSegm;                                                    %Assign data to substitute
   keepOri = 1;                                                            %Keep orientation
else %Old and new phase don't agree
   scrPrnt('Step','Assigning different phase data to new EBSD segment - input of new EBSD data is required'); 
   h = msgbox(['The new EBSD segment contains phase ''',...
               segmPhase{1},''' and should be reassigned to phase ''',...
               Dat.EBSD.phases{ind},'''. Open an EBSD file containing this crystallographic information'],...
               'Open EBSD data-set');                                      %Open EBSD Notice
   uiwait(h);                                                              %Wait for MsgBox to close
   ebsdSubs = readCPR(Dat.EBSD.inPath,Dat.EBSD.phases);                    %Read in EBSD data and rename phases
   % *** User input - Keep or load orientation data
   choices = {'Adapted from new EBSD data','Remain unaltered'};
   answer = questdlg(['Should the orientation data remain unaltered or be adapted from the newly imported EBSD dataset on phase ''',...
                       Dat.EBSD.phases{ind},'''?'],'Channel identification - Name Convention',...
                      choices{1},choices{2},choices{1});                   %EBSD data selection for segmented phase 
    if isempty(answer) %Terminated
        error('Terminated by user');
    end
    keepOri = find(strcmp(answer,choices))-1;                              %Flag 'Keep Orientation'
end
%% User input - Treatment of non-indexed data
if ~keepOri
    answer = questdlg('Would you like to assign the orientations of the new phase to all non-indexed points as well?',...
                           'Treatment of non-indexed data','Yes','No','No');
    if isempty(answer)
        error('Terminated by user')
    elseif strcmp(answer,'Yes')
        ebsdSegm = [ebsdBase(ebsdBase.phase==0) ebsdSegm];                 %Append unindexed points
    end
end
ebsdOut = subsPhase(ebsdBase,ebsdSubs,ebsdSegm,keepOri);                   %Substitute phase
end
function ebsdOut = subsPhase(ebsdBase,ebsdSubs,ebsdSegm,keepOri)
%function ebsdOut = subsPhase(ebsdBase,ebsdSubs,ebsdSegm)
%Based on a base map - reassign a certain segment with a new EBSD data set
%ebsdBase: Base EBSD map from which a certain segment should be replaced by
%          a new set of EBSD data
%ebsdSubs: Substitute EBSD data which should replace a segment in ebsdBase
%          (Must be single phase + optinional 'notIndexed' phase)
%ebsd.Seg: EBSD data set containing ebsd ID's that should be reassigned to 
%          the rotation and phase information in ebsdSubs (Must be single 
%          phase)
%% Prepare ebsd object
scrPrnt('Step','Preparing new EBSD object');                               %ScreenPrint
ebsdOut = ebsdBase;                                                        %Create EBSD object for output based on ebsdBase
phNr = max(ebsdOut.phaseMap)+1;                                            %Find new phase number
ebsdOut.phaseMap(end+1) = phNr;                                            %Assign new phase number to ebsdOut
ebsdOut.CSList{end+1} = ebsdSubs.CSList{end};                              %Add associated Crystal symmetry object to ebsdOut
ebsdOut.CSList{end}.color = 'red';                                         %Give new crystal symmetry a distinct color
ebsdSubs.phaseMap(end+1) = phNr;                                            %Assign new phase number to ebsdOut
ebsdSubs.CSList{end+1} = ebsdSubs.CSList{end};                              %Add associated Crystal symmetry object to ebsdOut
ebsdSubs.CSList{end}.color = 'red';                                         %Give new crystal symmetry a distinct color
%% Assign new phase and orientation
scrPrnt('Step',sprintf('Assigning new phase ''%s'' to segment in phase ''%s''',...
                       ebsdOut.CSList{end}.mineral,ebsdSegm(ebsdSegm.phase~=0).mineral)); %ScreenPrint
ebsdSubs(ebsdSubs.phase~=0).phase = phNr;                                   
ebsdOut(id2ind(ebsdOut,ebsdSegm.id)).phase = ebsdSubs(id2ind(ebsdSubs,ebsdSegm.id)).phase; %Assign phase number   
if ~keepOri %Update rotations
    scrPrnt('Step','Updating orientations');                               %ScreenPrint
    ebsdOut(id2ind(ebsdOut,ebsdSegm.id)).rotations = ...
            ebsdSubs(id2ind(ebsdSubs,ebsdSegm.id)).rotations;              %Assign rotations    
end
%% Plot
scrPrnt('Step','Plotting new phase map');                                  %ScreenPrint
figure;                                                                    %Create figure
plot(ebsdOut);                                                             %Plot new phase map
title('Map of reassigned phases');                                         %Title

figure;
% plot(ebsdOut,ebsdOut.prop.bc);
% hold on
% mtexColorMap('black2white')
% ipfKey = ipfHSVKey(ebsdOut('2'));                                   %Get IPF Key
% ipfKey.inversePoleFigureDirection = xvector;      %Set y-direction reference     
% color = ipfKey.orientation2color(ebsdOut('2').orientations);
% plot(ebsdOut('2'),color);
% hold on
ipfKey = ipfHSVKey(ebsdOut('3').CS.properGroup);                              %Get IPF Key
ipfKey.inversePoleFigureDirection = xvector;      %Set y-direction reference     
color = ipfKey.orientation2color(ebsdOut('3').orientations);
plot(ebsdOut('3'),color);
hold on
end