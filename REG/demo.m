addpath(genpath('ext'));

I=imread('images/zeugma.jpg');
I=I(200:400,250:450,:);% about M1:60second % M2:70second % M3:60second
tic
S=regcovsmooth(I,10,4,0.2,'M1');
toc
T=double(I)-double(S);

figure,
subplot(1,3,1);
imshow(I);
title('Input');
subplot(1,3,2);
imshow(uint8(S));
title('Structure');
subplot(1,3,3);
imshow(mat2gray(T));
title('Texture');
