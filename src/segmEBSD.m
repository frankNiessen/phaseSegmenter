function [ebsdA,ebsdB,meanEdsG] = segmEBSD(ebsd,grains,eds,opt)
scrPrnt('SegmentStart','Segmenting EBSD data by EDS thresholding')
%% User input - Phase selection
phases = ebsd.mineralList(~strcmp(ebsd.mineralList,'notIndexed'));
[ind,~] = listdlg('PromptString','Which phase should be segmented by EDS-thresholding?',...
                  'SelectionMode','single','ListString',phases,...
                   'ListSize',[300 150]);                                  %Get positive channels
if isempty(ind); error('Terminated by user'); end
phStr = phases{ind};                                                       %Get phase for segmentation
ebsd = ebsd(phStr);                                                        %Reduce EBSD structure to phase
grains = grains(phStr);                                                    %Reduce grain structure to phase
%% Computing grain median EDS Count of 'Processing' EDS channel
outputCnt = 100;                                                           %Update status every 'x' grains
edsVec(1:opt.nrPts) = eds(opt.gridID);                                     %Vectorize EDS data
meanEdsG = nan(size(grains));                                              %Initiate vector with mean EDS level per grain
scrPrnt('Step',['Determining median EDS signal in ''',phStr,''' grains']); 
for i = 1:size(grains,1) %Loop over grains
    if ~mod(i,outputCnt) %Update screen very 'outputCnt'th iteration
        scrPrnt('SubStep',sprintf('%.0f/%.0f grains processed',i,size(grains,1)));
    end
    id = ebsd(grains(i)).id;                                               %Get EBSD ID's of present grain
    meanEdsG(i) = median(edsVec(id));                                      %Get meadian of EDS signal for that EBSD data
   % meanEdsG(i) = median(ebsd(grains(i)).prop.mad);                        %MAD
   % meanEdsG(i) = median(ebsd(grains(i)).prop.bc);                         %bc
   % meanEdsG(i) = median(ebsd(grains(i)).prop.mis2mean.angle/degree);      %mis2mean  
end
%% Plot grain median EDS level
scrPrnt('Step','Plotting grain-median EDS level of ''Processing'' channel'); 
mfig= figure;                                                             %Create new figure
plot(grains,meanEdsG);                                                     %Plot grain median EDS level
colormap('jet');                                                           %Set colormap
caxis([median(meanEdsG)-std(meanEdsG) median(meanEdsG)+std(meanEdsG)]);        %Set color range
h.c = colorbar;                                                            %Add colorbar
h.c.Label.String = 'Rel. grain-median EDS count';                          %Add colorbar label
set(mfig,'name','Rel. grain-median EDS count','units','inch','outerposition',[1,1,7,5]);      
%% Find threshold for segmentation 
segRes = '';
while ~strcmp(segRes,'Accept')
    scrPrnt('Step','Manual Threshold selection');
    answer = inputdlg('Enter threshold for segmentation:',...
                   'Input',1,{num2str(median(meanEdsG))});         %Get threshold value
    thrsh = str2double(answer);                                       %Convert to double
    scrPrnt('SubStep',sprintf('Selected threshold: %.3f',thrsh));
    %% Segmentation
    ebsdA = ebsd(grains(meanEdsG<=thrsh));                                     %ebsdA - Lower threshold
    ebsdB = ebsd(grains(meanEdsG>thrsh));                                      %ebsdB - Upper threshold
    %% Plot seperate subfigures with orientation data of segmented phases
    % *** BC
    scrPrnt('SubStep','Plotting Band-Contrast map');
    h.fig(1) = figure;                                                     %Create new figure
    plot(ebsd,ebsd.prop.bc);                                               %Plot BC-map
    mtexColorMap('black2white');
    set(gcf,'name','Band Contrast Map');                                           
    % *** ebsdA    
    scrPrnt('SubStep','Plotting lower Treshold IPF map');
    h.fig(2) = figure;                                                     %Create new figure
    oM = ipfHSVKey(ebsdA.CS.properGroup);
    oM.inversePoleFigureDirection = xvector;
    color = oM.orientation2color(ebsdA.orientations);
    plot(ebsdA,color);                                                     %Plot IPF-map
    set(gcf,'name',['Lower Threshold <=',num2str(thrsh,'%.3f')]);          
    % *** ebsdB
    scrPrnt('SubStep','Plotting upper Treshold IPF map');
    h.fig(3) = figure;                                                     %Create new figure
    oM = ipfHSVKey(ebsdB.CS.properGroup);
    oM.inversePoleFigureDirection = xvector;
    color = oM.orientation2color(ebsdB.orientations);
    plot(ebsdB,color);                                                     %Plot IPF-map
    set(gcf,'name',['Upper Threshold >',num2str(thrsh,'%.3f')]);           
    tileFigs;
    segRes = questdlg('Accept segmentation result or redefine a new threshold value?','Review segmentation result','Accept','Redefine','Accept');
    if strcmp(segRes,'Redefine')
       close(h.fig);
       set(mfig,'name','Rel. grain-median EDS count','units','inch','outerposition',[1,1,7,5]); 
       clear h
    end
end
