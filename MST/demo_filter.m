clear; close all;

I1 = imread('../images-common-in/flower.jpg');
tic;
J1 = TreeFilterRGB_Uint8(I1, 0.001, 4);figure;imshow([I1,J1]);
J1 = TreeFilterRGB_Uint8(I1, 1, 4);figure;imshow([I1,J1]);
J1 = TreeFilterRGB_Uint8(I1, 3, 4);figure;imshow([I1,J1]);

toc;
figure;imshow([I1,J1]);

I2 = imread('../images-common-in/bflower.jpg');
tic;
J2 = TreeFilterRGB_Uint8(I2, 0.01, 3, 0.08, 4);
toc;
figure;imshow([I2,J2]);
