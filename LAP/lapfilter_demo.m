function [smoothedImage] = lapfilter_demo(im, sigma_r)
%im = im(1:50,1:50,:);
alpha = 0.25;
beta = 1;
colorRemapping = 'rgb';
domain = 'lin';
smoothedImage = lapfilter(im,sigma_r,alpha,beta,colorRemapping,domain);
return;
end