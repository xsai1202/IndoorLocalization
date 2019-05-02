function [num_tube,tube] = Tube_Seeking3( I1,num_tube, minIntensityOnTube)
DEBUG = 1;

I2 = medfilt2(uint8(I1/2),[15,15]);
bw1 = im2bw(I2, graythresh(I2)*0.7);

bw2 = bwareaopen(bw1,1000);
if (DEBUG==1)
	%h = figure('Visible', 'Off');
    figure(1);
	imshow(uint8(I1));
	hold on;
end

stats = regionprops(bw2,'ConvexHull', 'PixelIdxList');
ns=numel(stats);
area=zeros(ns,1);
tube_t=zeros(5,2,ns);
for i=1:ns
    % get the minimum rectangular bounding box 
    point = stats(i).ConvexHull;
    pil = stats(i).PixelIdxList; 
    mi = mean(I1(pil));
    if (mi < minIntensityOnTube) continue; end
    
    c = minBoundingBox(point');
	if (DEBUG==1)
    	plot(c(1,[1:end 1]),c(2,[1:end 1]),'g');
		hold on;
	end 
    quadVetices = [c(1,1:4)',c(2,1:4)'];
    quadVetices  = quadVetices;
    [quadVeticesSort,index] = sortrows(quadVetices);
    if quadVeticesSort(1,1) == quadVeticesSort(2,1)
        if quadVeticesSort(1,2) < quadVeticesSort(2,2)
            k = index(1);
        else
            k = index(2);
        end
    else
        k = index(1);
    end
    j = mod((k-1):(k+2),4)+1;
    
    rRect = quadVetices(j,:);
	% calculate edge len
    len = zeros(4,1);
    for j = 1:3
        len(j) = sqrt(power(rRect(j,1)-rRect(j+1,1),2)+power(rRect(j,2)-rRect(j+1,2),2));
    end
    len(4) = sqrt(power(rRect(4,1)-rRect(1,1),2)+power(rRect(4,2)-rRect(1,2),2));
    dsth = (len(1)+len(3))/2;
    dstw = (len(2)+len(4))/2;
    area(i)=dsth*dstw;
    tube_t(:,:,i)=[rRect;[dsth,dstw]];
 
end

[~,index]=sort(area,'descend');

for i=1:num_tube
    tube(:,:,i)=tube_t(:,:,index(i));
end
[~,index]=sort(tube(1,2,:));
tube=tube(:,:,index);

hold off;

end



