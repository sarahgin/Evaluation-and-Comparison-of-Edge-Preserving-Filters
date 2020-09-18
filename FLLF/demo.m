% demonstration of the Local Laplacian Filter
% 
% mathieu.aubry@m4x.org March 2014

%% import image
name='rock';
I_rgb = imread(sprintf('images/%s.png',name));
I_rgb = imread('D:\graphics-data\images-common-in\rock.jpg');
I = rgb2gray(im2double(I_rgb));
I_ratio=double(I_rgb)./repmat(I,[1 1 3])./255;
    
    

%% image enhancement
%sigma=0.1;
%N=10;
%fact=5;
%tic
%I_enhanced=llf(I,sigma,fact,N);
%toc
%I_enhanced=repmat(I_enhanced,[1 1 3]).*I_ratio;


%% image smoothing
for sigma=0:0.1:1
    N=5;
    fact=-1 ;
    I_smoothed=llf(I,sigma,fact,N);
    I_smoothed=repmat(I_smoothed,[1 1 3]).*I_ratio;
    figure;imshow(I_smoothed);title(num2str(sigma));
end
disp('here');

%% image enhancement using a general remapping function
%N=20;
%tic
%I_enhanced2=llf_general(I,@remapping_function,N);
%toc
%I_enhanced2=repmat(I_enhanced2,[1 1 3]).*I_ratio;


% plot
%figure;imshow(I_rgb);
%figure;imshow(I_smoothed);
%subplot(2,2,1); imshow(I_rgb); title('Input photograph');
%subplot(2,2,2); imshow(I_enhanced); title('Edge-aware enhacement with LLF');
%subplot(2,2,3); imshow(I_smoothed); title('Edge-aware smoothing with LLF');
%subplot(2,2,4); imshow(I_enhanced2); title('Edge-aware enhancement with a general LLF');
   
