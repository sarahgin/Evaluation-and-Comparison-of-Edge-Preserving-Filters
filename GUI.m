function GUI(inputDir, outputDir, filenameOnly, originalMethodInd, matchedMethodInd, methods, feature, isDHMode, amount, features)

inImagePath = char(strcat(inputDir, filenameOnly, '.jpg'));
inImage = imread(inImagePath);
inImage = im2double(inImage);
useSmoothCache = true;
colorPreservationMasksDir = '../data/images-common-color-preservation-masks/';
edgeMasksDir = '../data/images-common-salient-edges/';
smoothMasksDir = '../data/images-common-smooth-masks/';
dollarImagesDir = '../data/images-common-dollars/';

imageDir = strcat(outputDir, '/', filenameOnly);
paramsRange = [
                %ORIGINAL
                0.001,10;... %WLS
                0.001, 0.3;... %L0
                0.1 10;... %GIF
                0.001 5;... %DOM
                1 10;... %Gaussian
                
                %NEW FAST
                0.001,3;...%MST very fast
                0.001,0.1;...%FGS very fast
                ];

methods = {'WLS',...
            'L0',...
            'GIF',...
            'DOM',...
            'Gaussian',...
            'MST',...
            'FGS'};            
            
originalMethod = methods(originalMethodInd);
matchedMethod = methods(matchedMethodInd);

originalImage = smooth(originalMethod, inImage, paramsRange(originalMethodInd,1), imageDir, useSmoothCache, true, true);
matchedImage = smooth(matchedMethod, inImage, paramsRange(matchedMethodInd,1), imageDir, useSmoothCache, true, true);

colorPreservationMaskPath = strcat(colorPreservationMasksDir, filenameOnly, '.png');
colorPreservationMask = imread(colorPreservationMaskPath);
colorPreservationMask = im2double(colorPreservationMask);

salientEdgesPath = strcat(edgeMasksDir, filenameOnly, '.png');
edgeMask = imread(salientEdgesPath);
edgeMask = im2double(edgeMask);
edgeMask = edgeMask(:,:,1);

smoothMasksPath = strcat(smoothMasksDir, filenameOnly, '.png');
smoothMask = imread(smoothMasksPath);
smoothMask = im2double(smoothMask);

dollarImagesPath = strcat(dollarImagesDir, filenameOnly, '.png');
dollarImage = imread(dollarImagesPath);
dollarImage = im2double(dollarImage);

% Create a figure and axes
f = figure('Visible','off');
axes('Units','pixels');
subplot(1,2,1);imshow(originalImage);title(strcat(originalMethod, ' image'));
subplot(1,2,2);imshow(matchedImage);title(strcat(matchedMethod, ' image'));

regularStr = strcat('Feature: ', char(feature));
analyzingStr = strcat('Feature: ', char(feature), ' - Analyzing........');
doneStr = strcat('Feature: ', char(feature), ' - Done!');

title(regularStr);

originalControl = uicontrol('Style', 'slider',...
    'Min',paramsRange(originalMethodInd,1),'Max',paramsRange(originalMethodInd,2),'Value',paramsRange(originalMethodInd,1),...
    'Position', [200 50 450 20],...
    'Callback', @updateOriginal);
originalControlTxt = uicontrol('Style','text',...
    'FontSize', 10,...
    'Position',[200 80 450 20],...
    'String',strcat(originalMethod, ':[', num2str(paramsRange(originalMethodInd,1)), ' - ', num2str(paramsRange(originalMethodInd,2)), ']'));


matchedControl = uicontrol('Style', 'slider',...
    'Min',paramsRange(matchedMethodInd,1),'Max',paramsRange(matchedMethodInd,2),'Value',paramsRange(matchedMethodInd,1),...
    'Position', [900 50 450 20],...
    'Callback', @updateMatched);
matchedControlTxt = uicontrol('Style','text',...
    'FontSize', 10,...
    'Position',[900 80 450 20],...
    'String',strcat(matchedMethod, ':[', num2str(paramsRange(matchedMethodInd,1)), ' - ', num2str(paramsRange(matchedMethodInd,2)), ']'));

%image details to the side
leftImageDetailsTxt = uicontrol('Style','text',...
    'FontSize', 10,...
    'Position',[50 150 200 100],...
    ...
    'String','');
rightImageDetailsTxt = uicontrol('Style','text',...
    'FontSize', 10,...
    'Position',[700 150 200 100],...
    ...
    'String','');

finish = uicontrol('Style', 'pushbutton', 'String', 'Finish',...
    'Position', [20 20 50 20],...
    'Callback', @finishUI);

f.Visible = 'on';
h = gcf;
set(h, 'Position', [0 100 2000 600]);

    function updateOriginal(source,callbackdata)
        method = methods(matchedMethodInd);
        title(analyzingStr);
        if (isDHMode)
            originalImage = smoothAndDetails(originalMethod, inImage, source.Value, amount, imageDir);
            [chosenParam, chosenImage, chosenSSIM] = analyzeGUIDetails...
            (imageDir, inImage, originalImage, method, matchedMethodInd, edgeMask, smoothMask, colorPreservationMask, feature, useSmoothCache, paramsRange, amount, dollarImage);
            matchedImage = smoothAndDetails(matchedMethod, inImage, chosenParam, amount, imageDir);
        else
            originalImage = smooth(originalMethod, inImage, source.Value, imageDir, useSmoothCache, true, true);
            [chosenParam, chosenImage, chosenSSIM] = analyzeGUISmooth...
            (imageDir, inImage, originalImage, method, matchedMethodInd, edgeMask, smoothMask, colorPreservationMask, feature, useSmoothCache, paramsRange, dollarImage);
            matchedImage = smooth(matchedMethod, inImage, chosenParam, imageDir, useSmoothCache, true, true);
        end
        
        subplot(1,2,1);imshow(originalImage);title(strcat(originalMethod, ': ', num2str(source.Value)));
        subplot(1,2,2);imshow(matchedImage);title(strcat(matchedMethod, ': ', num2str(chosenParam), '-SSIM: ', num2str(chosenSSIM), '%'));
        binarySearchIm = imread('binarySearch.png');
        set(matchedControl, 'Value', chosenParam);
        title(doneStr);
        
        [scores_original, scoresMapTxt_original] = getFeaturesText(inImage, originalImage, edgeMask, smoothMask, colorPreservationMask, dollarImage, features);
        [scores_matched, scoresMapTxt_matched] = getFeaturesText(inImage, matchedImage, edgeMask, smoothMask, colorPreservationMask, dollarImage, features);
        set(rightImageDetailsTxt,'String', scoresMapTxt_original);
        set(leftImageDetailsTxt,'String', scoresMapTxt_matched);
        
        figure(4);
        bar([scores_original; scores_matched]');
        set(gca,'XTickLabel',features);
        xlabel('Features');
        ylabel('Scores');
        title('Left-Right Comparison');
        legend({char(originalMethod),char(matchedMethod)});
    end

    function updateMatched(source,callbackdata)
        method = methods(originalMethodInd);
        title(analyzingStr);
        if (isDHMode)
            matchedImage = smoothAndDetails(matchedMethod, inImage, source.Value, amount, imageDir);
            [chosenParam, chosenImage, chosenSSIM] = analyzeGUIDetails...
            (imageDir, inImage, originalImage, method, matchedMethodInd, edgeMask, smoothMask, colorPreservationMask, feature, useSmoothCache, paramsRange, amount, dollarImage);
            originalImage = smoothAndDetails(originalMethod, inImage, chosenParam, amount, imageDir);
        else
            matchedImage = smooth(matchedMethod, inImage, source.Value, imageDir, useSmoothCache, true, true);
            [chosenParam, chosenImage, chosenSSIM] = analyzeGUISmooth...
            (imageDir, inImage, matchedImage, method, originalMethodInd, edgeMask, smoothMask, colorPreservationMask, feature, useSmoothCache, paramsRange, dollarImage);
            originalImage = smooth(originalMethod, inImage, chosenParam, imageDir, useSmoothCache, true, true);
        end
        
        subplot(1,2,2);imshow(matchedImage);title(strcat(matchedMethod, ': ', num2str(source.Value)));
        subplot(1,2,1);imshow(originalImage);title(strcat(originalMethod, ': ', num2str(chosenParam), '-SSIM: ', num2str(chosenSSIM), '%'));
        binarySearchIm = imread('binarySearch.png');
        set(originalControl, 'Value', chosenParam);
        title(doneStr);
        
        [scores_original, scoresMapTxt_original] = getFeaturesText(inImage, originalImage, edgeMask, smoothMask, colorPreservationMask, dollarImage, features);
        [scores_matched, scoresMapTxt_matched] = getFeaturesText(inImage, matchedImage, edgeMask, smoothMask, colorPreservationMask, dollarImage, features);
        set(leftImageDetailsTxt,'String', scoresMapTxt_original);
        set(rightImageDetailsTxt,'String', scoresMapTxt_matched);
        
        figure(4);
        bar([scores_original; scores_matched]');
        set(gca,'XTickLabel',features);
        xlabel('Features');
        ylabel('Scores');
        title('Left-Right Comparison');
        legend({char(originalMethod),char(matchedMethod)});
    end

    function finishUI(source,callbackdata)
       fprintf('Thank you!\n');
       close(f);
       close all;
       return;
    end

waitfor(f);
end