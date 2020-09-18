function [sharpenedImage] = sharpenImage(image, smoothedImage, amount)

useTonemap = true;
useLumAdj = true;

%compute LAB of input image (L is image)
lab = rgb2lab(image);
L = lab(:,:,1);

%compute LAB of smoothedImage (L0 is base)
labL0 = rgb2lab(smoothedImage);
L0 = labL0(:,:,1);

%compute detail layers D0
D0 = amount.*(double(L)-double(L0));
base = double(L0);

%new lightness channel is base with added detail layers
L_new = base + D0;

%replace lightness channel with new one
lab(:,:,1) = L_new;
lab(:,:,2) = lab(:,:,2);
lab(:,:,3) = lab(:,:,3);

%convert back to RGB
sharpenedImage = lab2rgb(lab);

if (useTonemap)
    Lcurr = 0.2126 * sharpenedImage(:,:,1) + 0.7152 * sharpenedImage(:,:,2) + 0.0722 * sharpenedImage(:,:,3);
    LMax = max(Lcurr(:));
    Ld = log10(1 + Lcurr) / log10(1 + LMax);
    sharpenedImageNew = zeros(size(sharpenedImage));
    for i=1:size(sharpenedImage, 3)
        sharpenedImageNew(:,:,i) = (sharpenedImage(:,:,i) .* Ld) ./ (Lcurr + eps);
    end
    sharpenedImage = sharpenedImageNew;
end

if (useLumAdj)
    labOfSI = rgb2lab(sharpenedImage);
    LTM = labOfSI(:,:,1);
    lumAvgReduction = mean(L(:)) - mean(LTM(:));
    LTM = LTM + lumAvgReduction;
    labFinal(:,:,1) = LTM;
    labFinal(:,:,2) = labOfSI(:,:,2);
    labFinal(:,:,3) = labOfSI(:,:,3);
    sharpenedImage = lab2rgb(labFinal);
end

end