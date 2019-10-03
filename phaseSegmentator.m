% *************************************************************************
%                        phaseSegmentator
%
% Program for discrimination and segmentation of crystallographically similar
% phases in an EBSD dataset by grain-median EDS thresholding
% *************************************************************************
% Dr. Frank Niessen, University of Wollongong, Australia, 2019
% contactnospam@fniessen.com (remove the nospam to make this email address 
% work)
% License provided in root directory
clear all; clear hidden; clc; close all; warning('off','all');
scrPrnt('StartUp','phaseSegmentator');                                     %StartUp Screen Print
%% User Input
Dat.EBSD.phases = {'alpha','alphaDP','beta'};                              %List of all phase names that are used in the segmentation and reassignment process
Dat.EDS.names = {'Ti','V','Al','Fe','C'};                                  %EDS channel names 
Dat.EDS.act =   [  1   1    1    1   0];                                   %State of EDS channels [1: Active 0: Inactive]
Dat.EDS.identifier = 'unknown';                                            %Identifier-string of EDS channels in mTex ebsd structure field 'ebsd.prop' (not required for read in via 'csv' files)
% ... Editing of the code below this line not recommended ...
%% Initialization
startup_mtex;                                                              %StartUp m-tex
% *** FilePaths
Dat.EBSD.inPath = [fileparts(mfilename('fullpath')),'\data\input\EBSD'];   %Default input folder EBSD data
Dat.EBSD.outPath = [fileparts(mfilename('fullpath')),'\data\output\EBSD']; %Output folder EBSD data
Dat.EDS.inPath = [fileparts(mfilename('fullpath')),'\data\input\EDS'];     %Default input folder EDS data
%% Import EBSD and EDS data
ebsd.all = readCPR(Dat.EBSD.inPath,Dat.EBSD.phases);                       %Read in EBSD data and rename phases
[ebsd.all,eds] = readEDS(ebsd.all,Dat,3);                                  %Read in EDS data and rename channels
[~,eds.opt.gridID ] = ebsd.all.gridify;                                    %Get IDs to link vector and matrix notation
eds.opt.gridID = flip(eds.opt.gridID,1);                                   %Transform IDs to match EDS and EBSD data
eds.opt.nrPts = size(eds.proc,1)*size(eds.proc,2);                         %Get Nr of points
%% Process EDS data (uncomment to use image filtering capabilities)
%Seg.h = mapEDS(ebsd.all,eds.proc,Seg,Dat);                                %Map EDS data
%Seg.imFilt = {'Norm','Median','Laplace','Norm'};                          %Indicate sequential filtering steps [choose from 'Norm'||'Median'||'Laplace','Thresh','Binarize']
%eds.proc = imFiltering(eds.proc,Seg);                                     %Filtering of image data
%% Process EBSD data
[grains,ebsd.all] = cmptGrains(ebsd.all);                                  %Computing grains and filtering out small grains 
%% EBSD segmentation by grain-median EDS-thresholding
[ebsd.lower,ebsd.upper,meanEdsG] = segmEBSD(ebsd.all,grains,eds.proc,eds.opt);  %Segment EBSD data by EDS-threshold
%% EBSD Reassignment
ebsd.out = reassignEBSD(ebsd.all,ebsd.upper,ebsd.lower,Dat);               %Reassign phase to ebsd map
ebsd.out = reduce(ebsd.out,1);                                             %Reformat to list
tileFigs;                                                                  %Tile all open figures
%% Output
outName = [Dat.EBSD.outPath,'\',strtok(ebsd.all.opt.fName,'.'),...
           '_Processed.ctf'];                                              %Output filename  
ebsd.out.opt = ebsd.all.opt;                                               %Transfer structure 'options' to ebsd.out
exportCTF(ebsd.out,outName,'Params',ebsd.out.opt.cprData);                 %Export ctf file
scrPrnt('SegmentEnd');                                                     %ScreenPrint