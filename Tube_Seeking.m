function [numSegs,segs] = Tube_Seeking(I1, tubeID)
DEBUG = 1;
minPixPerSeg = 1800;
numSegs=0;
%minObjSize = 1000; % minimum object size in pixels
gapRatio = 5; % ratio between the size of separator between lights and within one light's body

I2 = (uint8(I1));
bw1 = im2bw(I2, graythresh(I2)*1.4);%OTSU thresholding with a scalar

%removes all connected components (objects) that have fewer than minPixPerSeg pixels  
bw2 = bwareaopen(bw1, double(minPixPerSeg/10.0));
%
if (DEBUG==1)
	%h = figure('Visible', 'Off');
	%h.PaperPositionMode = 'auto'; 
    figure(8);
	imshow(uint8(I1))
	hold on;
end
%
%stats = regionprops(bw2,'BoundingBox','ConvexHull');
stats = regionprops(bw2,'ConvexHull');
for i=1:numel(stats)
    % stats is struct array containing a struct for each object in the image. 
    point = stats(i).ConvexHull;
    % get the minimum rectangular bounding box 
    c = minBoundingBox(point'); 

	if (DEBUG==1)
    	plot(c(1,[1:end 1]),c(2,[1:end 1]),'g');
	end
    %%
    quadVetices = [c(1,1:4)',c(2,1:4)']; % x axis, y axis
	
	 
    %quadVetices  = quadVetices;
	% Sort the rows of a matrix in ascending order based on the elements in the first column.  
    [quadVerticesSortR,index] = sortrows(quadVetices);
		 
    if quadVerticesSortR(1,1) == quadVerticesSortR(2,1)
        if quadVerticesSortR(1,2) < quadVerticesSortR(2,2)
            k = index(1);
        else
            k = index(2);
        end
    else
        k = index(1);
    end
    j = mod((k-1):(k+2),4)+1;
    
    rRect = quadVetices(j,:);
    %Compute the edge length
    len = zeros(4,1);
    for j = 1:3
        len(j) = sqrt(power(rRect(j,1)-rRect(j+1,1),2)+power(rRect(j,2)-rRect(j+1,2),2));
    end
    len(4) = sqrt(power(rRect(4,1)-rRect(1,1),2)+power(rRect(4,2)-rRect(1,2),2));
     dsth = (len(1)+len(3))/2;
    dstw = (len(2)+len(4))/2;
    dstRect  = [0,dsth;0,0;dstw,0;dstw,dsth;];    
    area=dsth*dstw;
    if area>1%0
        numSegs=numSegs+1;
		 
		if (i==1)
			recBoxesSortedByX = quadVetices;
			recBoxesSortedByY = [c(2,1:4)',c(1,1:4)'];
		else
			recBoxesSortedByX = vertcat(recBoxesSortedByX, quadVetices);
			recBoxesSortedByY = vertcat(recBoxesSortedByY, [c(2,1:4)',c(1,1:4)']);
		end 
		 
        % Compensate for perspective transformation due to orientation variation
        % fit rRect into rectangle dstRect (equivalent to rotation)
        tform = estimateGeometricTransform(rRect, dstRect,...
            'projective');
        imgBp = imwarp(I1, tform,...
            'OutputView',imref2d([floor(dsth),floor(dstw)]));
		
        if mod(size(imgBp,1),2)==1
            imgBp=imgBp(1:end-1,:);
        end
        if mod(size(imgBp,2),2)==1
            imgBp=imgBp(:,1:end-1);
        end
        if size(imgBp,1)>size(imgBp,2)
            imgBp=rot90(imgBp,3);
        end
         
        segs{numSegs}=imgBp;%imgBp is the final rectangle image of this seg
        %nR = length(imgBp(:,1));
        %nC = length(imgBp(1,:));
        %segs{numSegs}=imgBp(min(nR,5):max(5,nR-5), min(10, nC):max(10, nC-10));%imgBp is the final rectangle image of this seg
        %figure(3);
        %imshow(uint8(imgBp));
    end
    %min area bounding rectangle
    %     [qx,qy] = minboundquad(point(:,1),point(:,2));
    %     h3=impoly(gca,[qx',qy']);
    %     api = iptgetapi(h3);
    %     api.setColor('yellow');
end

if (DEBUG==1)
	%fn = sprintf('serverTubeSeeking%d.jpg', tubeID);
	%saveas(gcf, fn);
    hold off;
end

%xyz: remove segments that belong to a different light (separated a bit far away)
recBoxesSortedByX = sortrows(recBoxesSortedByX);
i = 2;
sepX=[];
% Calculate separation between segments, along X and Y directions
for k = 5:4:length(recBoxesSortedByX(:,1))
	sepX(i) = recBoxesSortedByX(k,1) - recBoxesSortedByX(k-1,1);
	i = i + 1;
end
recBoxesSortedByY = sortrows(recBoxesSortedByY);
i = 2;
sepY=[];
for k = 5:4:length(recBoxesSortedByY(:,1))
	sepY(i) = recBoxesSortedByY(k,1) - recBoxesSortedByY(k-1,1);
	i = i + 1;
end

toDelete = [];
%xyz FIXME: Generalize this to handle more than 2 lights
if (length(sepX)>0)
	minSepX = mean(sepX(sepX>0));
	for k = 2:length(sepX)
		if (sepX(k) > minSepX*gapRatio)
			% cut the small part, leave the large part
			if (k-1 <= length(sepX)-k)
				toDelete = [toDelete 1:k-1];
				if(DEBUG) fprintf(1, 'Delete segs 1:%d\n',k-1); end
				% also delete edge segments that tend to introduce errors
				%if (length(sepX)-1 > 1) toDelete = [toDelete length(sepX)]; end
				%if (length(sepX)-2 > 1) toDelete = [toDelete length(sepX)-1]; end
				break;
			else
				toDelete = [toDelete k:length(sepX)];
				if(DEBUG) fprintf(1, 'Delete segs %d:%d\n', k, length(sepX)); end
				% Also delete edge segments that tend to introduce errors
				%if (length(sepX)-k > 1) toDelete = [toDelete 1]; end
				%if (length(sepX)-k-1 > 1) toDelete = [toDelete 2]; end
				break; 
			end
		end
	end
end

segs(toDelete) = [];
numSegs = numSegs - length(toDelete);
% also delete edge segments that tend to introduce errors
if (length(segs) >= 3)
	toDelete = [1 length(segs)];
	segs(toDelete) = [];
	numSegs = numSegs - length(toDelete);
end

if(DEBUG) 
    fprintf(1, 'numSegs=%d\n', numSegs);
end

end
