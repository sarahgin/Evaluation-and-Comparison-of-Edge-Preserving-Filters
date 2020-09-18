function [ Gmag, Gdir ] = getImageGradients(greyscaleImage)

if (size(greyscaleImage,3) > 1)
    greyscaleImage = convertToGrayscale(greyscaleImage);
end

[Gx, Gy] = imgradientxy(greyscaleImage, 'Sobel');
[Gmag, Gdir] = imgradient(Gx, Gy);

end