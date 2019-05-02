clear all;
A=imread('calibImg.dng');
sigma = 10;
edgeCut = 40;

B = imgaussfilt(A, sigma);
%nRows = length(B(:,1));
%nCols = length(B(1,:));
%B = B(edgeCut:nRows-edgeCut, edgeCut:nCols-edgeCut);
m = max(max(B));
figure(20);
imshow(uint8(B));
calibMat = double(B)/double(m);
save('calibMatrix.mat', 'calibMat');

%{
nRows = length(B(:,1));
nCols = length(B(1,:));
p = polyfit(1:nRows, ,6); %6-order fitting curve
y1 = polyval(p,1:length(A_T1_mean));
figure;
plot(y1)
%}

