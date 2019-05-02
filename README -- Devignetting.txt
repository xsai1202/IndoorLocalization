Dear Prof. Zhang,

I think the file I sent to you yesterday is what is shown in README file. I might write the wrong extension. Attached is the code to produce the Background2.mat. It is need to note that the 1.jpg and 2.jpg are only examples to show how to take the photos. They are not the pictures we used to do the vignetting compensation in summer.

We can produce the Background2.mat as follows:
1. Take a photo of a pure white rectangular object(Xunchao and I used the lights in the Lab in summer). The object is parallel to one side of the picture and exceeds the picture(for example, 1.jpg). 
2. Use the test1.m to get a vector.
3. Take another photo ofa pure white rectangular object. The object is parallel to another side of the picture and exceeds the picture(for example, 2.jpg). 
3. Use the test1.m to get another vector.
4. Multiple the two vectors to get the matrix we need to do the vignetting compensation.

If you still have some problems, you can email to me or Xunchao.

Best Wishes,
Liren

