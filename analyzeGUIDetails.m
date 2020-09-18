function [chosenParam, chosenImage, chosenSSIM] = analyzeGUIDetails...
    (imageDir, originalImage, smoothedImage, method, methodInd, edgeMask, smoothMask, colorPreservationMask, feature, useSmoothedCache, paramsRange, amount, dollarImage)

featureScoreOriginal = getFeatureScore(feature, originalImage, smoothedImage, smoothMask, edgeMask, colorPreservationMask, dollarImage);
binarySearchFig = figure('Visible', 'off');
minParam = paramsRange(methodInd,1);
maxParam = paramsRange(methodInd,2);
scoreThreshold = 0.999;

stepSize = abs(maxParam - minParam)/20; %for iteration steps
absStepSize = abs(maxParam - minParam)/100; %for param too similar only

chosenParam = 1000;
numOfTestedParams = 0;

absoluteMinScore = 1000;
absoluteMaxScore = -1000;

count = 0;
for param = minParam:((maxParam - minParam)/50):maxParam
    count = count + 1;
    smoothedImage = smoothAndDetails(method, originalImage, param, amount, imageDir);
    featureScore = getFeatureScore(feature, originalImage, smoothedImage, smoothMask, edgeMask, colorPreservationMask, dollarImage);
    SSIM = 1 - abs(featureScore - featureScoreOriginal);
    params(count) = param;
    sims(count) = SSIM;
    absoluteMinScore = min([absoluteMinScore SSIM]);
    absoluteMaxScore = max([absoluteMaxScore SSIM]);
end
plot(params, sims, 'b-o');hold on;

while chosenParam == 1000
    
    %%CONTINUE
    midParam = round((minParam+maxParam)/2,5);
    midParamStr = strrep(num2str(midParam, '%.5f'), '.', '-');
    midSmoothedImage = smoothAndDetails(method, originalImage, midParam, amount, imageDir);
    midSSIMFeatureScore = getFeatureScore(feature, originalImage, midSmoothedImage, smoothMask, edgeMask, colorPreservationMask, dollarImage);
    midSSIM = 1 - abs(midSSIMFeatureScore - featureScoreOriginal);
    
    numOfTestedParams = numOfTestedParams + 1;
    
    plot(midParam, midSSIM, 'r-*');hold on;
    text(midParam, midSSIM, num2str(count),'FontSize',15);
    
    %RAND PARAM
    randParam = maxParam.*randi([1 100],1,1)/100;
    randParamStr = strrep(num2str(randParam, '%.5f'), '.', '-');
    randSmoothedImage = smoothAndDetails(method, originalImage, randParam, amount, imageDir);
    randSSIMFeatureScore = getFeatureScore(feature, originalImage, randSmoothedImage, smoothMask, edgeMask, colorPreservationMask, dollarImage);
    randSSIM = 1 - abs(randSSIMFeatureScore - featureScoreOriginal);
    
    plot(randParam, randSSIM, 'g-*');hold on;
    text(randParam, randSSIM, 'RND', 'FontSize',15);
    
    if (midSSIM > scoreThreshold)
        fprintf('MID PARAM FOUND for %s in %d iterations\n', char(method), count);
        chosenParam = midParam;
        chosenImage = midSmoothedImage;
        chosenSSIM = midSSIM;
        break;
    end
    
    
    %in case step size is too large
    stepSize = min([stepSize (maxParam - midParam)/2]);
    
    rightParam = round(midParam + stepSize,5);
    if (rightParam > maxParam)
        rightParam = maxParam;
    end
    if (rightParam > maxParam)
        rightParam = maxParam; %not outside the current interval
    end
    rightParamStr = strrep(num2str(rightParam, '%.5f'), '.', '-');
    rightSmoothedImage = smoothAndDetails(method, originalImage, rightParam, amount, imageDir);
    rightSSIMFeatureScore = getFeatureScore(feature, originalImage, rightSmoothedImage, smoothMask, edgeMask, colorPreservationMask, dollarImage);
    rightSSIM = 1 - abs(rightSSIMFeatureScore - featureScoreOriginal);
    
    numOfTestedParams = numOfTestedParams + 1;
    
    plot(rightParam, rightSSIM, 'b-*');hold on;
    text(rightParam, rightSSIM, num2str(count),'FontSize',15);
    
    leftParam = round(midParam - stepSize,5);
    if (leftParam < minParam)
        leftParam = minParam;
    end
    if (leftParam < minParam)
        leftParam = minParam; %not outside the current interval
    end
    leftParamStr = strrep(num2str(leftParam, '%.5f'), '.', '-');
    leftSmoothedImage = smoothAndDetails(method, originalImage, leftParam, amount, imageDir);
    leftSSIMFeatureScore = getFeatureScore(feature, originalImage, leftSmoothedImage, smoothMask, edgeMask, colorPreservationMask, dollarImage);
    leftSSIM = 1 - abs(leftSSIMFeatureScore - featureScoreOriginal);
    
    numOfTestedParams = numOfTestedParams + 1;
    
    plot(leftParam, leftSSIM, 'b-*');hold on;
    text(leftParam, leftSSIM, num2str(count),'FontSize',15);
    
    absoluteMinScore = min([absoluteMinScore leftSSIM rightSSIM]);
    absoluteMaxScore = max([absoluteMaxScore leftSSIM rightSSIM]);
    
    if (leftSSIM > scoreThreshold)
        fprintf('MIN PARAM FOUND for %s in %d iterations\n', char(method), count);
        chosenParam = leftParam;
        chosenImage = leftSmoothedImage;
        chosenSSIM = leftSSIM;
        break;
    elseif (rightSSIM > scoreThreshold)
        fprintf('MAX PARAM FOUND for %s in %d iterations\n', char(method), count);
        chosenParam = rightParam;
        chosenImage = rightSmoothedImage;
        chosenSSIM = rightSSIM;
        break;
    elseif count >= 100
        fprintf('COUNT OVER for %s in %d iterations\n', char(method), count);
        chosenParam = leftParam; %arbitrary choice
        chosenImage = leftSmoothedImage;
        chosenSSIM = leftSSIM;
        break;
    else
        %another round
        if (leftSSIM <= midSSIM && midSSIM <= rightSSIM)
            minParam = rightParam;
        elseif (leftSSIM >= midSSIM && midSSIM >= rightSSIM)
            maxParam = leftParam;
        elseif (leftSSIM <= midSSIM && midSSIM >= rightSSIM)
            fprintf('Regular triangle ordering handle for params (%.5f,%.5f,%.5f) = (%.5f,%.5f,%.5f)\n', leftParam, midParam, rightParam, leftSSIM, midSSIM, rightSSIM);
            minParam = leftParam;
            maxParam = rightParam;
        else
            fprintf('Upside down triangle ordering handle for params (%.5f,%.5f,%.5f) = (%.5f,%.5f,%.5f)\n', leftParam, midParam, rightParam, leftSSIM, midSSIM, rightSSIM);
            minParam = leftParam;
            maxParam = rightParam;
        end
        
        if (abs(maxParam - minParam) < absStepSize)
            fprintf('PARAM TOO SIMILAR for %s in %d iterations\n',char(method), count);
            chosenParam = minParam; %arbitrary choice
            chosenImage = rightSmoothedImage;
            chosenSSIM = rightSSIM;
            break;
        end
    end
    count = count + 1;
end

chosenParamStr = strrep(num2str(chosenParam, '%.5f'), '.', '-');
chosenSSIMStr = strrep(num2str(chosenSSIM, '%.5f'), '.', '-');
title(strcat(method, '-', chosenParamStr, '-', chosenSSIMStr));
line([chosenParam chosenParam], [absoluteMinScore absoluteMaxScore]);
xlabel('Parameter');
ylabel('Similarity');
saveas(binarySearchFig, 'binarySearch', 'png');
close(binarySearchFig);
end


