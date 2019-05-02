
--------------
List of files:

getdata3.m is a program to get the data of light after the preprocess.All train and test image should be preprossed by the program firstly.

Tube_Seeking2.m is a function to find the whole light in a image

Tube_Seeking.m finds individual segments on each tube. 

Light_deep3.py is a program to train and test the nerual network. I have commented out the training step. Just run the code and get the acuracy of 200 test images.

The model of nerual network is saved in the folder tmp41.

If you want to do vignet compensation, follow README--devignetting.txt

An alternative way of running devignetting: Take a picture of a *UNIFORMLY
ILLUMINATED surface* (e.g., a smooth white wall or paper). The picture should
be taken under the same ISO as your experiment, but with a bit longer exposure
time (so that the picture is still visible). Rename the .dng file to
calibImg.dng, and run devigCalib.m. In getdata3.m, make sure calibMatrix.mat
is loaded, and devignetting is enabled on the line: 
A_backup=(double(A)./calibMat);%devignetting

-------------
To run training:

First use opencamera to capture raw pictures (.dng) and put them in folder
train/. The pictures should be named by 1.dng, 2.dng, 3.dng, 4.dng.
Suppose there are two lights, then each of the picture should belong to:
light1, light2, light1, light2...
Similarly, interleave the lights when you have N lights. 

Then, configure the parameters in getdata3.m, and run getdata3.m to get
training data.  Then, configure parameters in Light_deep3.py, and run it.

To run testing: 
Capture raw pictures and put them in folder test/.

configure parameters in getdata3.m, and get testing data. Reset MODE to 2 in
Light_deep3.py, and then run it.
The output corresponds to the list of recognized light indices.

---------------
Tips for configuring the camera and other parameters:

1) Low ISO, low exposure (100, 1/10764.1s) is better than
high ISO, low exposure (1600, 1/16778s).
(low noise, high resolution picture is more important)
Exposure MUST be locked (otherwise the opencamera will set it automatically)
Scene: auto
white-balance: fluorescent
(Use opencamera 1.37; latest version has some whitebalancing problem.)
2) It's most critical to ensure ONLY light body is extracted, and no dark
edges (some extra edge cropping may be needed)
Vignet compensation is important, because some edge segments may be darkened
and may not be cropped correctly.
For the same reason, setting a larger OTSU threshold scalar (instead of 1.3) in
bw1 = im2bw(I2, graythresh(I2)*1.3); %Tube_Seeking.m
and a relatively small threshold in:
bw1 = im2bw(I2, graythresh(I2)*0.85); %Tube_Seeking2.m
improves accuracy.
3) If the above are enabled, whether color compensation is enabled or not
seems not so critical. 






