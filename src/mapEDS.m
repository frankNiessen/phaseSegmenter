function h = mapEDS(ebsd,eds,Ind,Dat)
cMap = 'hot';
%% Contour Plot
n = 20;
h(1).fig = figure; h(1).ax = axes(h(1).fig);                               %Create figure and axes
[C,h(1).plt] = contourf(ebsd.prop.x,ebsd.prop.y,eds,n);               %Contour plot of EDS data
axis tight
set(h(1).ax,'Color','k');                                                  %Make background black
set(h(1).plt,'LineColor','none');                                          %Remove contour lines           
daspect(h(1).ax,[1 1 1]);                                                  %Enforce true data aspect ratio
colormap(h(1).ax,cMap);                                                    %Set colormap
h(1).cb = colorbar;                                                        %Show colorbar
%Labels
title(h(1).ax,['EDS contour map for ',Dat.EDS.names{Ind.chNr},...
            ' in ',ebsd.mineral]);                                         %Print title
xlabel(h(1).ax,['x [',ebsd.scanUnit,']']);                                 %Print xLabel
ylabel(h(1).ax,['y [',ebsd.scanUnit,']']);                                 %Print yLabel
ylabel(h(1).cb,'Relative count');                                          %Print colorBarLabel
%% Scatter Plot
h(2).fig = figure; h(2).ax = axes(h(2).fig);                               %Create figure and axes
h(2).plt = surf(ebsd.prop.x,ebsd.prop.y,eds,'EdgeColor','none');
axis tight
set(h(2).ax,'Color','k');                                                  %Make background black
view(2);
daspect(h(2).ax,[1 1 1]);                                                  %Enforce true data aspect ratio
colormap(h(2).ax,cMap);                                                    %Set colormap
h(2).cb = colorbar;                                                        %Show colorbar
%Labels
title(h(2).ax,['EDS surface map for ',Dat.EDS.names{Ind.chNr},...
            ' in ',ebsd.mineral]);                                         %Print title
xlabel(h(2).ax,['x [',ebsd.scanUnit,']']);                                 %Print xLabel
ylabel(h(2).ax,['y [',ebsd.scanUnit,']']);                                 %Print yLabel
ylabel(h(2).cb,'Relative count');                                          %Print colorBarLabel
%% EBSD orientation data
% h(3).fig = figure; h(3).ax = axes(h(3).fig);                               %Create figure and axes
% h(3).plt = plot(ebsd,ebsd.orientations);                                   %Plot orientation data
% h(3).ax = gca; set(h(3).ax,'Color','k');                                   %Make background black
%% PostProc
tileFigs();                                                                %Tile figures