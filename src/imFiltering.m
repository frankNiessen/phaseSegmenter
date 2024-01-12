function eds = imFiltering(eds,Seg)
%function ebsd = procEDS(ebsd,Dat)
figure; imagesc(eds); colormap('gray'); daspect([1 1 1]); title('Unprocessed image');
%% Loop over filtering steps
scrPrnt('SegmentStart','Image filtering')
for i = 1:length(Seg.imFilt)
   scrPrnt('Step',sprintf('%.0f/%.0f: ',i,length(Seg.imFilt)));
   switch Seg.imFilt{i}           
       case 'Norm' %Normalization
            fprintf('Normalizing');
            eds = (eds - min(min(eds)))/(max(max(eds))-min(min(eds))); 
       case 'Median' %2-D Median Filter
            fprintf('Median filtering');
            f.label = '2-D median filtering';
            f.func = @(I,wndw) medfilt2(I,[wndw,wndw]);
            f.params = {'Window'};
            f.val = 3;
            f.form = {'%.0f'};
            f.lims = [1 20];
            eds = guiFilter(eds,f); 
       case 'Laplace' %Fast Local Laplacian Filter
            fprintf('Laplace filtering');
            f.label = 'Fast Local Laplacian Filtering';
            f.func = @(I,sigma,alpha,beta) locallapfilt(I,sigma,alpha,beta);
            f.params = {'Sigma','Alpha','Beta'};
            f.val = [0.9 1.5 1];
            f.form = {'%.2f','%.2f','%.0f'};
            f.lims = [0 1; .01 2; 1 1];
            eds = guiFilter(single(eds),f);
       case 'Thresh' %Thresholding
            fprintf('Thresholding');
            eds = thresholding(eds,Seg);
            figure; imagesc(eds); colormap('gray'); daspect([1 1 1]); title('GS - After Thresholding');
       case 'Binarize' %Binarizing
            fprintf('Binarizing');
            eds = applyThrsh(eds,Seg.thrsh);
       otherwise
           error(['Invalid processing step ''',Seg.imFilt{i},'''']);
   end  
end
%% Tile Figures
figure; imagesc(eds); colormap('gray');  daspect([1 1 1]); title('Final processed image');
scrPrnt('SegmentEnd');
tileFigs;
drawnow;
%% Unused filters code
% %% Neighbourhood filtering
% wndw = [17 17];                                                            %Window for local neighbourhood filtering
% thrsh = 6;                                                                 %Threshold (>=) for positive neighbourhood
% dil = 3;                                                                   %Dilation in nr of pixels
% %Local Neighbourhood Density filter
% fun = @(x) nlFuncs(x(:),'blockproc',thrsh,Seg.thrsh,dil);                  %Filter function
% %eds = nlfilter(eds,wndw,fun);                                             %Local neighbourhood median filter
% eds = blockproc(eds,wndw,fun);
% figure; imagesc(eds); colormap('gray');  daspect([1 1 1]); title('Neighboorhood filtered Binarized Image');
% %% Median Filter
% wndw = [3 3]; 
% eds = medfilt2(eds,wndw);
% figure; imagesc(eds); colormap('gray');  daspect([1 1 1]); title('Median Filter Binarized Image');

end
%% Functions
function eds = thresholding(eds,Seg)
%% Question DGL
modes = {'Gauss','Acc. Intensity','Interactive'};
answer = questdlg('Choose a Thresholding mode','Choice',modes{:},modes{1});%User input
switch answer
    case modes{1}
         rng = gaussSeg(eds,Seg);
    case modes{2}
         rng = accIntSeg(eds,Seg);      
    case modes{3}
         rng = interactSeg(eds,Seg);
end
eds(~isnan(eds)) = imadjust(eds(~isnan(eds)),rng,[0 1]);
fprintf('The intensity range %.2f - %.2f is scaled to 0.00 - 1.00\n',rng(1),rng(2));
if strcmp(Seg.thrsh,'lower')
    eds(isnan(eds)) = 1;
elseif strcmp(Seg.thrsh,'upper')
    eds(isnan(eds)) = 0;
else
    error(['Invalid Threshold choice ''',Seg.thrsh,'''']);
end
end

function eds = applyThrsh(eds,thrsh)
%function eds = applyThrsh(eds,thrsh)
if strcmp(thrsh,'lower')
    eds(eds<1) = 0;
elseif strcmp(thrsh,'upper')
    eds(eds>0) = 1;
end
end

function rng = gaussSeg(eds,Seg)
% *** Make histogram fit and Gauss function
h = imhist(eds(~isnan(eds)));                                              %Histogram
h = (h - min(min(h)))/(max(max(h))-min(min(h)));
h = smooth(h,'sgolay',1);
x = linspace(0,1,size(h,1))';
f = fit(x,h,'gauss1');
coeff = coeffvalues(f);
FWHM = 2*sqrt(log(2))*coeff(3);
cntr = coeff(2);
% *** Determine Intensity Range
if strcmp(Seg.thrsh,'lower')
    rng = [0 cntr+FWHM/2];
elseif strcmp(Seg.thrsh,'upper')
    rng = [cntr-FWHM/2 1];
else
    error(['Invalid Threshold choice ''',Seg.thrsh,'''']);
end
% *** Plot
figure;
plot(x,h,'.'); hold on; plot(f); 
plot([rng(1) rng(1);rng(2) rng(2)]',...
[min(min(h)) max(max(h));min(min(h)) max(max(h))]','--');
legend('Measurement', 'Fit','Range');
end

function rng = accIntSeg(eds,Seg)
% *** Make histogram fit and Gauss function
h = imhist(eds(~isnan(eds)));                                             
h = smooth(h,'sgolay',1);
h = cumsum(h);                                                             %Cumulative histogram.
h = (h - min(min(h)))/(max(max(h))-min(min(h)));
x = linspace(0,1,size(h,1))';
figure;
plot(x,h,'.'); hold on;
hMsg = msgbox(['Please draw a vertical line to define the ',...
               'threshold (2x LeftClick + ''Enter'')']);  
uiwait(hMsg);
pts = getline(gcf);
xThrsh = (pts(1,1)+pts(2,1))/2;                                            %Threshold value y
% *** Determine Intensity Range
if strcmp(Seg.thrsh,'lower')
    rng = [0 xThrsh];
elseif strcmp(Seg.thrsh,'upper')
    rng = [xThrsh 1];
else
    error(['Invalid Threshold choice ''',Seg.thrsh,'''']);
end
% *** Plot
plot([rng(1) rng(1);rng(2) rng(2)]',...
[min(min(h)) max(max(h));min(min(h)) max(max(h))]','--');
legend('Measurement','Range');
end

function rng = interactSeg(eds,Seg)
if strcmp(Seg.thrsh,'lower')
    eds = imcomplement(eds);
end
xThrsh = thresh_tool(eds);            
% *** Determine Intensity Range
if strcmp(Seg.thrsh,'lower')
    rng = [0 1-xThrsh];
elseif strcmp(Seg.thrsh,'upper')
    rng = [xThrsh 1];
else
    error(['Invalid Threshold choice ''',Seg.thrsh,'''']);
end
end
