function score = getFeatureScore(feature, originalImage, smoothedImage, smoothMask, edgeMask, colorPreservationMask, dollarImage)

originalGreyscalImage = convertToGrayscale(originalImage);
[GmagOriginal, GdirOriginal] = getImageGradients(originalGreyscalImage);

greyscaleSmoothedImage = convertToGrayscale(smoothedImage);
[GmagSmoothed, GdirSmoothed] = getImageGradients(greyscaleSmoothedImage);

rows = size(originalImage,1);
cols = size(originalImage,2);

if (strcmp(feature, 'SOSmooth'))
    [SOImage,zero,new,reduced,strengthened,eliminated,same] = getDiffGradientsImage(rows, cols, GmagOriginal, GmagSmoothed);
    score = mean(SOImage(smoothMask == 1));
elseif (strcmp(feature, 'SOEdges'))
    [SOImage,zero,new,reduced,strengthened,eliminated,same] = getDiffGradientsImage(rows, cols, GmagOriginal, GmagSmoothed);
    score = mean(SOImage(edgeMask == 1));
elseif (strcmp(feature, 'ColorRGB'))
    imageLab = rgb2lab(originalImage);
    smoothedImageLab = rgb2lab(smoothedImage);
    diffIm_a = (imageLab(:,:,2) - smoothedImageLab(:,:,2)).^2;
    diffIm_b = (imageLab(:,:,3) - smoothedImageLab(:,:,3)).^2;
    distance_ab = sqrt(diffIm_a + diffIm_b);
    score = mean(distance_ab(:));
elseif (strcmp(feature, 'GCF'))
    [originalContrastScore, resolutionScores] = getGlobalContrastFactor(originalGreyscalImage);
    [contrastScore, resolutionScores] = getGlobalContrastFactor(greyscaleSmoothedImage);
    score = contrastScore./originalContrastScore;
elseif(strcmp(feature, 'Luminance'))
    imageLab = rgb2lab(originalImage);
    smoothedImageLab = rgb2lab(smoothedImage);
    imageL = imageLab(:,:,1);
    smoothedImageL = smoothedImageLab(:,:,1);
    diffLMatrix = smoothedImageL./imageL;
    score = mean(diffLMatrix(imageL ~= 0));
elseif (strcmp(feature, 'SSIM'))
    originalImageU = im2uint8(originalImage);
    smoothedImageU = im2uint8(smoothedImage);
    originalImageU = rgb2gray(originalImageU);
    smoothedImageU = rgb2gray(smoothedImageU);
    [score, ssimMap] = ssim(originalImageU, smoothedImageU);
else
    disp('error');
end

end