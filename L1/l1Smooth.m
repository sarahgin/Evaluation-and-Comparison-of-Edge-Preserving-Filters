function [smoothedImage] = l1Smooth(im, p)
im = im2uint8(im);
addpath('./l1-smoothing/src');
param = struct(); 
param.alpha = p;
param.itr_num = 1;
param.local_param.edge_preserving = true; 
smoothedImage = l1flattening(im, param);
return;
end