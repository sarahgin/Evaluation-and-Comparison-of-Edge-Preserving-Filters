function [ outImage ] = normImage(image)

minimum = min(image(:));
maximum = max(image(:));

if (minimum == maximum)
    outImage = image;
else
    outImage = (image - minimum) ./ (maximum - minimum);
end

return;
end

