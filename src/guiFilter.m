function I = guiFilter(I,f)
%% Ini
%Figure size
Sz.Scr = get(0,'screensize');                                              %Get Screen size
Sz.Fac = 0.8;                                                              %Figure size reduction
Sz.Offs = 100;                                                             %Figure size offset
Sz.Fig = [Sz.Offs Sz.Offs 0 0] + Sz.Fac*[0 0 Sz.Scr(3) Sz.Scr(4)];         %Figure size
%Slider size
Sz.Sl = [0 0 300 27];                                                      %Slider dimensions
Sz.SlOffs = 30;                                                            %Slider offset
Sz.Lb.Offs = 80;                                                           %Label offset 
Sz.Lb.s = [0 0 60 34];                                                     %Small label
Sz.Lb.l = [0 0 150 34];                                                    %Large label
Sz.But = [0 0 80 37];
FntSz = 16;                                                                %Font size
%% Creating gui Elements
h.fig = figure('units','pixels','position',Sz.Fig,...
               'CloseRequestFcn',@closefunction);                          %Create figure
%Loop over Nr of sliders
for i = 1:length(f.params)
    if ~all(f.val(i) == f.lims(i,:))
        Pos.sl = [100,20,0,0] + Sz.Sl + (i-1)*[0 (Sz.Sl(4)+Sz.SlOffs) 0 0];    %Slider Position
        Pos.l(1,:) = [Pos.sl(1)-Sz.Lb.Offs Pos.sl(2) 0 0] + Sz.Lb.s;           %Label 1 Position
        Pos.l(2,:) = Pos.l(1,:) + [Sz.Sl(3)+Sz.Lb.Offs 0 0 0];                 %Label 2 Position
        Pos.l(3,:) = [Pos.sl(1) Pos.sl(2) 0 0] + Sz.Lb.l + ...
                     [(Sz.Sl(3)-Sz.Lb.l(3))/2 Sz.Sl(4) 0 0];                   %Label 3 Position
        h.sl(i) = uicontrol('Parent',h.fig,'Style','slider','units','pix','Position',...
                  Pos.sl,'value',f.val(i), 'min',f.lims(i,1),'max',f.lims(i,2),...
                  'string',f.params{i},'callback',@callbackFunc);              %Create Slider   
        h.l(i,1) = uicontrol('Parent',h.fig,'Style','text','units','pixels',...
                       'Position',Pos.l(1,:),'String',num2str(f.lims(i,1)),...
                       'fontsize',FntSz,'BackgroundColor', h.fig.Color);       %Lower limit label
        h.l(i,2) = uicontrol('Parent',h.fig,'Style','text','units','pixels',...
                       'Position',Pos.l(2,:),'String',num2str(f.lims(i,2)),...
                       'fontsize',FntSz,'BackgroundColor', h.fig.Color);       %Upper limit label
        h.l(i,3) = uicontrol('Parent',h.fig,'Style','text','units','pixels',...
                       'Position',Pos.l(3,:),'String',[f.params{i},': ',...
                       num2str(f.val(i),f.form{i})],'fontsize',FntSz,...
                       'BackgroundColor', h.fig.Color);       %Parameter Name label
    end
end
Pos.ax = [Pos.l(3,1) Pos.l(1,2) -Pos.l(3,1) -Pos.l(3,2)] + ...
         [0 100 Sz.Fig(3)-50 Sz.Fig(4)-150];                               %Axis position
Pos.clBut = [Pos.l(2,1)+50 Pos.l(2,2) 0 0] + Sz.But;                       %Close button position 
h.ax = axes(h.fig,'units','pixel','pos',Pos.ax);                           %Create axes
h.clBut = uicontrol('unit','pix','pos',Pos.clBut ,'string','Close',...
                    'fontsize',FntSz,'callback',@closefunction);           %Close button
%% Plotting image
h.im = imagesc(h.ax,I);                                                    %Plot image
colormap('gray');                                                          %Colormap
daspect([1 1 1]);                                                          %Fixed Data Aspect Ratio
title([f.label,' - Unprocessed']);                                         %Title
Iorig = I;                                                                 %Backup original image
%% Functions
% *** SliderCallback ***
function callbackFunc(hObject,eventdata)  
    %Update status
    h.ax.Title.String = '... PROCESSING ...';
    h.ax.Title.Color = 'r';
    drawnow;
    %Filter image
    paramName = hObject.String; 
    paramNr = find(strcmp(paramName,f.params));
    f.val(paramNr) = hObject.Value;
    if strcmp(f.form,'%.0f')
        f.val(paramNr) = int8(f.val(paramNr));
    end
    funcStr = 'f.func(Iorig';
    for j = 1:size(f.val,2)
        funcStr = [funcStr,',f.val(',num2str(j),')'];
    end
    funcStr = [funcStr,');'];
    I = eval(funcStr);    
    %Update plot
    h.im.CData = I;
    %Update status
    h.ax.Title.String = f.label;
    h.ax.Title.Color = 'k';
    h.l(paramNr,3).String = [f.params{paramNr},': ',...
                            num2str(f.val(paramNr),f.form{paramNr})];
end

% *** Close function ***
function closefunction(hObject,eventdata) 
    %Close GUI
    delete(h.fig);                                                      
end
%% Pause until figure is closed
waitfor(h.fig);    
end
