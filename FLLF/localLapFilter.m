function smoothedImage = localLapFilter(I_rgb, param)

%I_rgb = imread(sprintf('images/%s.png','rock'));
I = rgb2gray(im2double(I_rgb));
I_ratio=double(I_rgb)./repmat(I,[1 1 3])./255;
sigma = param;
N=5;
fact=-1 ;
I_smoothed=llf(I,sigma,fact,N);
I_smoothed=repmat(I_smoothed,[1 1 3]).*I_ratio;
smoothedImage = I_smoothed;
end