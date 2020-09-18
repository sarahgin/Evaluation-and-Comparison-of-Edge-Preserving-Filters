function GUI_setup()
close all;
inputDir = '../data/images-common-in/';
outputDir = '../outputs/';

methods = {'WLS','L0','GIF','DOM','Gaussian','MST','FGS'};
features = {'SOSmooth',...
            'SOEdges',...
            'ColorRGB',...
            'GCF',...
            'Luminance',...
            'SSIM'};
        
amountsStr = {'1.1','1.25','1.5','1.75','2','3','4','5','6','7','8','9','10'};
filenames = {};
f = figure('Visible','on');

h = gcf;
set(h, 'Position', [200 200 800 600]);

axes('Units','pixels');
imagesNames = dir(inputDir);
numOfImages = size(imagesNames, 1);
count = 1;
for k=1:numOfImages
    filename = imagesNames(k).name;
    if (strcmp(filename, '.') || strcmp(filename, '..'))
        continue;
    end
    filenameOnly = strrep(filename, '.png', '');
    filenameOnly = strrep(filenameOnly, '.jpg', '');
    imageDir = strcat(inputDir, '/', filename);
    currIm = imread(imageDir);
    currIm = im2double(currIm);
    subplot(5,2,count);imshow(currIm);title(filenameOnly);
    filenames{count} = filenameOnly;
    count = count + 1;
end
title('Select parameters');

popupOriginalMethod = uicontrol('Style', 'popup',...
    'String', methods,...
    'Position', [20 340 100 50],...
    'Callback', @chooseOriginalMethod);
methodControlTxt = uicontrol('Style','text',...
    'FontSize', 10,...
    'Position',[0 400 150 20],...
    'String','Choose base method');



popupMatchedMethod = uicontrol('Style', 'popup',...
    'String', methods,...
    'Position', [20 240 100 50],...
    'Callback', @chooseMatchedMethod);
methodControlTxt = uicontrol('Style','text',...
    'FontSize', 10,...
    'Position',[0 300 150 20],...
    'String','Choose matching method');


popupImageName = uicontrol('Style', 'popup',...
    'String', filenames,...
    'Position', [20 140 100 50],...
    'Callback', @chooseImage);
methodControlTxt = uicontrol('Style','text',...
    'FontSize', 10,...
    'Position',[0 200 150 20],...
    'String','Choose image');

popupFeatureName = uicontrol('Style', 'popup',...
    'String', features,...
    'Position', [20 40 100 50],...
    'Callback', @chooseFeature);
methodControlTxt = uicontrol('Style','text',...
    'FontSize', 10,...
    'Position',[0 100 150 20],...
    'String','Choose feature');

analyzeSmooth = uicontrol('Style', 'pushbutton', 'String', 'Analyze smooth',...
    'Position', [20 20 100 20],...
    'Callback', @analyzeUISmooth);

analyzeDetails = uicontrol('Style', 'pushbutton', 'String', 'Analyze details',...
    'Position', [200 20 100 20],...
    'Callback', @analyzeUIDetails);

finish = uicontrol('Style', 'pushbutton', 'String', 'Finish',...
    'Position', [420 20 100 20],...
    'Callback', @finishUI);

f.Visible = 'on';
chosenFilename = [];
chosenFeature = [];
matchedMethodInd = [];
originalMethodInd = [];

    function chooseImage(source,callbackdata)
        chosenFilenameInd = source.Value;
        chosenFilename = filenames(chosenFilenameInd);
    end

    function chooseFeature(source,callbackdata)
        chosenFeatureInd = source.Value;
        chosenFeature = features(chosenFeatureInd);
    end

    function chooseMatchedMethod(source,callbackdata)
        matchedMethodInd = source.Value;
    end

    function chooseOriginalMethod(source,callbackdata)
        originalMethodInd = source.Value;
    end

    function analyzeUISmooth(source,callbackdata)
        fprintf('Analyzing...');
        
        if (isempty(chosenFilename))
            chosenFilename = 'lighthouse';
            originalMethodInd = 1; %WLS
            matchedMethodInd = 2; %L0
            chosenFeature = 'SO_smooth';
        end
        
        GUI(inputDir, outputDir, char(chosenFilename), originalMethodInd, matchedMethodInd, methods, char(chosenFeature), false, -1, features);
        fprintf('Done.\n');
    end

    function analyzeUIDetails(source,callbackdata)
        fprintf('Analyzing...');
        
        if (isempty(chosenFilename))
            chosenFilename = 'lighthouse';
            originalMethodInd = 1; %WLS
            matchedMethodInd = 2; %L0
            chosenFeature = 'SO_smooth';
        end
        
        [chosenAmountIndex,selectionIsMade] = listdlg('PromptString','Select amount:',...
            'SelectionMode','single',...
            'ListString',amountsStr);
        chosenAmountStr = amountsStr(chosenAmountIndex);
        chosenAmount = str2double(chosenAmountStr);
        
        GUI(inputDir, outputDir, char(chosenFilename), originalMethodInd, matchedMethodInd, methods, char(chosenFeature), true, chosenAmount, features);
        fprintf('Done.\n');
    end

    function finishUI(source,callbackdata)
        fprintf('Thank you!\n');
        close(f);
        return;
    end

waitfor(f);
end