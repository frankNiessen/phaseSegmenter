function y = nlFuncs(x,mode,varargin)
%function y = nlFuncs(x,mode,varargin)
%Local Neighborhood Density Functions
switch mode
    % *** Distinct block processing for image ***
    case 'blockproc' 
        if x.blockSize(1)-x.blockSize(2)
           y = x.data;
           return
        end
        thrsh = varargin{1};
        mode = varargin{2};
        dil = varargin{3};
        srchLevels = (x.blockSize(1)-1)/2;
        cntr = (x.blockSize(1)+1)./2;
        for i = 1:srchLevels(1)
            rng = 1+2*i;
            ind = [1,round(median(1:rng)),rng];
            srchM(i,:,:) = boolean(zeros(x.blockSize));
            srchM(i,cntr-ind(2)+ind(:),cntr-ind(2)+ind(:)) = 1;
            srchM(cntr,cntr) = 0;
            chkM(:,i) = x.data(srchM(i,:,:));                             %Create Check Vector
        end
        
        % *** Find decision ***
        if strcmp(mode,'lower')
            sw = all(sum(~chkM,1) >= thrsh);
        elseif strcmp(mode,'upper')
            sw = all(sum(chkM,1) >= thrsh);
        else
            error(['Invalid mode ''',mode,'''']);
        end
        % *** Overwrite data ***
        y = x.data;
        if dil>x.blockSize(1)/2
            error('Dilatation larger than neighbour-matrix.');
        end
        if strcmp(mode,'lower')   
            if sw 
               y(cntr-dil:cntr+dil,cntr-dil:cntr+dil) = 0; 
            else
               y(cntr,cntr) = 1; 
            end
        elseif strcmp(mode,'upper')     
            if sw
               y(cntr-dil:cntr+dil,cntr-dil:cntr+dil) = 1;  
            else
               y(cntr,cntr) = 0;
            end
        end
    otherwise
        error(['Invalid Filter choice ''',mode,'''']);
end