function [I] = limitSignal(I,fac)
%function [I] = limitSignal(I,fac)
%Cutting of spikes in (image) array I by thresholding at 'fac' times the
%standard deviation
%% Processing
%Normalize signal
I = (I-min(min(I)))/(max(max(I))-min(min(I)));
%Find upper and lower bounds
B.upper = mean(I(:))+std(I(:))*fac;
B.upper(B.upper>1) = 1;
B.lower = mean(I(:))-std(I(:))*fac;
B.lower(B.lower<0) = 0;
%Rescale image array
I = imadjust(I,[B.lower; B.upper],[0; 1]);
