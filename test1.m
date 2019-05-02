
clear all;
% eval(sprintf('t=Tiff(''./open_camera/%d.dng'');',3));
% A=(read(t));
% close(t);
A=imread('1.jpg');
% figure;
% imshow(uint8(A));
[num_tube,tube] = Tube_Seeking( A, 1 );

A_T1=double(tube{1});
len=length(A_T1(1,:));
A_T1=A_T1(:,1:len/3);
%max(max(A_T1));
m=mean(mean(A_T1));

A_T1=A_T1(150:end-150,:)/m;
%Dark area elimination before vignetting compensation (otherwise the fitted curve will be very ugly)
%Here 0.6 needs to be configured with different types of lights.
% index_A_2 = A_T1>0.6;
% A_T1 = A_T1.*index_A_2;
%Vignetting compensation for each light tube area
A_T1_mean = mean(A_T1);
index_3 = find(A_T1_mean>0); %mask of columns which correspond to real light tube area
A_T1_mean = A_T1_mean(index_3(1):index_3(end));

p = polyfit(1:length(A_T1_mean),A_T1_mean,6); %6-order fitting curve
y1 = polyval(p,1:length(A_T1_mean));
figure;
plot(y1)
% save('background.mat','BG');
