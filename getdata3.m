clear all;
warning('off','all');
% load background2.mat;%xyz
load calibMatrix.mat;
% tic;
MODE = 1; % 1: Training; 2: Testing
numLights = 2;
numPicsPerLight = 10;
maxTubesPerLight = 2;
maxSegsPerTube = 42;
rowsPerSeg=20;
colsPerSeg=100;

extraRowCut = 1;
extraColCut = 10;

Input_img_num = numPicsPerLight*numLights;%Total number of input images
%Spatial Features
num_tube=zeros(Input_img_num,1);
data=zeros(Input_img_num,rowsPerSeg*colsPerSeg*maxTubesPerLight*maxSegsPerTube);

% Picture order: light 1, light 2, light 3, light 1, light 2, light 3...
for index_img = 1:Input_img_num %read image in a for loop. 
    index_img
	if (MODE == 1)
      eval(sprintf('t=imread(''./train/%d.jpg'');',index_img));
	elseif (MODE == 2)
      eval(sprintf('t=imread(''./test/%d.jpg'');',index_img));
	end
%     AA = read(t);
%     AAA=demosaic(AA,'rggb');
%     close(t);
    [r1,c1,~]=size(t);
    if r1>c1
        t=permute(t,[2,1,3]);
    end
    A=rgb2gray(t);
    A_backup=(double(A)./calibMat);%devignetting
    %A_backup=(double(A));%xyz: disable devignetting
%     A_Green=A(1:2:end,1:2:end);
    A_Green=t(:,:,2);
    % find the light in the image   
    [num_tube(index_img),tube] = Tube_Seeking2( A_Green,2);
    A = double(A_backup); %restore the original 2-D image
    
    %divide the dng picture into 4 channels
%     A_Red = A(1:2:end,1:2:end);
%     A_Blue = A(2:2:end,2:2:end);
%     A_Green1 = A(1:2:end,2:2:end);
%     A_Green2 = A(2:2:end,1:2:end);
    A_Red=t(:,:,1);
    A_Blue=t(:,:,3);
    
%     [r,c] = size(A_Red);
%     A_new=zeros(r,c,4);
%     A_new(:,:,1) = A_Red;
%     A_new(:,:,2) = A_Blue;
%     A_new(:,:,3) = A_Green1;
%     A_new(:,:,4) = A_Green1;
    
      
    for tube_index = 1:num_tube(index_img)
        %rotate the light
        rRect = tube(1:4,:,tube_index);
        dsth = tube(5,1,tube_index);
        dstw = tube(5,2,tube_index);
        dstRect  = [0,dsth;0,0;dstw,0;dstw,dsth;];
        tform = estimateGeometricTransform(rRect, dstRect,'projective');
%         imgBp = imwarp(A_new, tform,'OutputView',imref2d([floor(dsth),floor(dstw)]));
        imgBp = imwarp(t, tform,'OutputView',imref2d([floor(dsth),floor(dstw)]));
        
        [r,c,~] = size(imgBp);
        if mod(r,2)==1
            imgBp=imgBp(1:end-1,:,:);
        end
        if mod(c,2)==1
            imgBp=imgBp(:,1:end-1,:);
        end
        if r>c
            imgBp=rot90(imgBp,3);
        end
%         A_T1=rgb2gray(imgBp);

        [r,c,~] = size(imgBp);
        A_T1 = zeros(2*r,2*c);
        A_T1(1:2:end,1:2:end) = imgBp(:,:,1);
%         A_T1(2:2:end,2:2:end) = imgBp(:,:,3);
        A_T1(2:2:end,2:2:end)=rgb2gray(imgBp);
        A_T1(1:2:end,2:2:end) = imgBp(:,:,2);
        A_T1(2:2:end,1:2:end) = imgBp(:,:,3);
        
        
        Red_T1 = imgBp(:,:,1);
        Red_T1 = Red_T1(Red_T1>70);
%         Green_T1 = [imgBp(:,:,3);imgBp(:,:,4)];
        Green_T1=imgBp(:,:,2);
        Green_T1 = Green_T1(Green_T1>70);
        Blue_T1 = imgBp(:,:,3);
        Blue_T1 = Blue_T1(Blue_T1>70);
        
        Red_avg = mean(Red_T1(:));
        Green_avg = mean(Green_T1(:));
        Blue_avg = mean(Blue_T1(:));
        
        
		%Color compensation
        %{
        A_T1(1:2:end,1:2:end) = A_T1(1:2:end,1:2:end)/Red_avg;
        A_T1(1:2:end, 2:2:end) = A_T1(1:2:end, 2:2:end)/Green_avg;
        A_T1(2:2:end, 1:2:end) = A_T1(2:2:end, 1:2:end)/Green_avg;
        A_T1(2:2:end, 2:2:end) = A_T1(2:2:end, 2:2:end)/Blue_avg;
		%}
        
		%xyz: disable color compensation
		%
		mC = (Red_avg+Green_avg+Blue_avg)/3.0;
% 		A_T1(1:2:end,1:2:end) = A_T1(1:2:end,1:2:end)/mC;
%         A_T1(1:2:end, 2:2:end) = A_T1(1:2:end, 2:2:end)/mC;
%         A_T1(2:2:end, 1:2:end) = A_T1(2:2:end, 1:2:end)/mC;
%         A_T1(2:2:end, 2:2:end) = A_T1(2:2:end, 2:2:end)/mC; 
	 	%}
		A_T1=double(A_T1)/mC;
        % find the segments in tube. 
        [num_tube_2,tube_2] = Tube_Seeking( A_T1*200, tube_index);
        
        %convert the 2-D image to an arrary
        for index_tube=1:min(maxSegsPerTube,num_tube_2)
            A_T1=tube_2{index_tube}/200;
            if index_tube>1&&index_tube<num_tube_2
                A_T1=A_T1(extraRowCut:end-extraRowCut,extraColCut:end-extraColCut);
            end
            A_T1=((A_T1/max(max(A_T1))).^3);
            
            A_T1=imresize(A_T1,[rowsPerSeg colsPerSeg],'bicubic');
            if tube_index == 1
                data(index_img,(index_tube-1)*rowsPerSeg*colsPerSeg+1:index_tube*rowsPerSeg*colsPerSeg)=reshape(A_T1',[1,rowsPerSeg*colsPerSeg]);
            else
                data(index_img,(index_tube+maxSegsPerTube-1)*rowsPerSeg*colsPerSeg+1:(index_tube+maxSegsPerTube)*rowsPerSeg*colsPerSeg)=reshape(A_T1',[1,rowsPerSeg*colsPerSeg]);
            end
        end
    end
end
%%

if (MODE == 2)
	test_x=data;
	test_y=[];
	for k=1:numPicsPerLight
		test_y=[test_y; eye(numLights)];
	end 
	save('light_test.mat', 'test_x', 'test_y');%xyz
 	%test_y=[test_y;test_y;test_y;test_y;]
end


% training part
if (MODE == 1)
	train_x=data;
	train_y = [];
	for k=1:numPicsPerLight
		train_y=[train_y; eye(numLights)];
	end
	train_x=[train_x;train_x+randn(size(train_x))/10;train_x+randn(size(train_x))/10;train_x+randn(size(train_x))/10;train_x+randn(size(train_x))/10];
	% train_x=[train_x;train_x;train_x;train_x;train_x];
	%train_y=[train_y;train_y];
	train_y=[train_y;train_y;train_y;train_y;train_y];
	save('light_train.mat', 'train_x', 'train_y');%xyz
end
