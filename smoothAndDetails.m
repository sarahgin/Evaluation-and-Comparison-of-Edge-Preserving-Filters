function DHImage = smoothAndDetails(method, originalImage, param, amount, imageDir)
        smoothImageOriginal = smooth(method, originalImage, param, imageDir, true, false, false);
        DHImage = sharpenImage(originalImage, smoothImageOriginal, amount);
end