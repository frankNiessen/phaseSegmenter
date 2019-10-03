function [grains,ebsd] = cmptGrains(ebsd,varargin)
%% User input - Parameter selection
scrPrnt('SegmentStart','Computing Grains from EBSD data');
answer = inputdlg({'Min. GB angle [°]:','Min. Grain size [pxs]: (keep empty for no removal of small grains)'},...
                   'Grain computation',[1 70],{'2',''});                   %Get min GB angle and Min grain size
if isempty(answer); error('Terminated by user'); end
misOri = str2double(answer{1})*degree;                                     %Threshold misorientation [rad]
minGsz = str2double(answer{2});                                            %Minimum grain size [pxs]
%% Compute Grains
scrPrnt('Step',sprintf('Computing Grains with >%.0f° misorientation',misOri/degree));
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',misOri);     %Compute grains from segmented EBSD data
if check_option(varargin,'rmvSmallGrains') || ~isnan(minGsz)
    %% Delete small Grains
    scrPrnt('Step',sprintf('Deleting EBSD data of grains with <%.0f pxs',minGsz));
    ebsd(grains(grains.grainSize < minGsz)).phase = 0;                     %Assign ebsd data of filtered grains to phase 'noIndexed'
    ebsd(grains(grains.grainSize < minGsz)).rotations = rotation('Euler',0,0,0); %Set orientation of ebsd data of filtered grains to 0
    ebsd(grains(grains.grainSize < minGsz)).prop.error = 3;                %Set error of ebsd data of filtered grains to 3
    ebsd(grains(grains.grainSize < minGsz)).prop.bands = 0;                %Set nr of bands of ebsd data of filtered grains to 0
    ebsd(grains(grains.grainSize < minGsz)).prop.mad = 0;                  %Set mean angular deviation of ebsd data of filtered grains to 0
    %% Recompute Grains
    scrPrnt('Step',sprintf('Recomputing Grains with >%.0f° misorientation',misOri/degree));
    [grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',misOri); %Recompute grains from segmented and filtered EBSD data
end