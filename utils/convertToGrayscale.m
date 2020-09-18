function grayscaleImage = convertToGrayscale(image)

if (size(image,3) == 1)
    grayscaleImage = image;
    return;
end
grayscaleImage = rgb2gray(image);

end