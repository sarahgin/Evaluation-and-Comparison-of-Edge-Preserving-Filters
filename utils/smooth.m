function [smoothImage] = smooth(method, image, param, imageDir,useCache, doSave, doRound)

        if (param < 0)
            throw ex;
        end

        if (param == 0)
            smoothImage = image;
            return;
        end

        basePath = strcat(imageDir, '/', method, '/');
        if (~exist(char(basePath),'dir'))
            mkdir(char(basePath));
        end
        
        fileExtension = '.mat';
        
        if (doRound)
            param = getParam(num2str(param, '%.3f'));
            smoothedPathMat = char(strcat(basePath, strrep(num2str(param, '%.3f'), '.', '-'), fileExtension));
        else
            smoothedPathMat = char(strcat(basePath, strrep(num2str(param), '.', '-'), fileExtension));
        end
        
        
        smoothedPathMatChosen = strrep(smoothedPathMat, 'images-berkeley-out','images-berkeley-chosen-params-no-mask');
        %TRY IN OUT
        if exist(smoothedPathMat, 'file') && useCache == true
            fprintf('ALREADY SMOOTHED %s\n', smoothedPathMat);
            smoothImageMat = load(smoothedPathMat);
            smoothImage = smoothImageMat.smoothImage;
            if (isa(smoothImage, 'uint8'))
                smoothImage = im2double(smoothImage);
            end
            %save(smoothedPathMatChosen, 'smoothImage');
            return;
        elseif exist(strrep(smoothedPathMat, '.mat', '-000.mat'), 'file') && useCache == true
            fprintf('ALREADY SMOOTHED %s\n', smoothedPathMat);
            smoothImageMat = load(strrep(smoothedPathMat, '.mat', '-000.mat'));
            smoothImage = smoothImageMat.smoothImage;
            if (isa(smoothImage, 'uint8'))
                smoothImage = im2double(smoothImage);
            end
            %save(smoothedPathMatChosen, 'smoothImage');
            return;
        end
        
        %TRY IN CHOSEN
        if exist(smoothedPathMatChosen, 'file') && useCache == true
            fprintf('ALREADY SMOOTHED %s\n', smoothedPathMatChosen);
            smoothImageMat = load(smoothedPathMatChosen);
            smoothImage = smoothImageMat.smoothImage;
            if (isa(smoothImage, 'uint8'))
                smoothImage = im2double(smoothImage);
            end
            %save(smoothedPathMat, 'smoothImage');
            return;
        elseif exist(strrep(smoothedPathMatChosen, '.mat', '-000.mat'), 'file') && useCache == true
            fprintf('ALREADY SMOOTHED %s\n', smoothedPathMatChosen);
            smoothImageMat = load(strrep(smoothedPathMatChosen, '.mat', '-000.mat'));
            smoothImage = smoothImageMat.smoothImage;
            if (isa(smoothImage, 'uint8'))
                smoothImage = im2double(smoothImage);
            end
            %save(smoothedPathMat, 'smoothImage');
            return;
        end
             
        %---------------------------------------

        fprintf('NEWLY SMOOTHED %s %.5f\n', char(method), param);
        if (strcmp(method,'GIF') == 1)
            %smoothImage = imguidedfilter(image, 'DegreeOfSmoothing', param); 
            p = image;
            %r = 4;
            %eps = param^2;
            r = round(param);
            eps = param^2;
            smoothImage(:, :, 1) = guidedfilter(image(:, :, 1), p(:, :, 1), r, eps);
            if size(image,3) > 1
                smoothImage(:, :, 2) = guidedfilter(image(:, :, 2), p(:, :, 2), r, eps);
                smoothImage(:, :, 3) = guidedfilter(image(:, :, 3), p(:, :, 3), r, eps);
            end
        elseif (strcmp(method,'L0') == 1)
            smoothImage = L0Smoothing(image,param);
        elseif (strcmp(method,'WLS') == 1)
            smoothImage(:,:,1) = wlsFilter(image(:,:,1), param);
            if size(image,3) > 1
                smoothImage(:,:,2) = wlsFilter(image(:,:,2), param);
                smoothImage(:,:,3) = wlsFilter(image(:,:,3), param);
            end
        elseif (strcmp(method,'DOM') == 1)
            smoothImage = IC(image, 60, param);
        elseif (strcmp(method, 'Gaussian') == 1)
            smoothImage = getGaussianImage(image, param);
        elseif (strcmp(method, 'EXT') == 1)
            if (param < 0.5)
                param = 0.5;
            end
            [smoothImage, Sminima, Smaxima, Eminima, Emaxima] = localExtrema(image,round(param));
        elseif (strcmp(method, 'L1') == 1)
            smoothImage = l1Smooth(image, param);
        elseif (strcmp(method, 'LAP') == 1)
            smoothImage = lapfilter_demo(image, param);
        elseif (strcmp(method, 'REG') == 1)
            image = im2uint8(image);
            S = regcovsmooth(image,10,4,param,'M2');
            smoothImage = uint8(S);
            smoothImage = im2double(smoothImage);
        elseif (strcmp(method, 'MST') == 1)
            image = im2uint8(image);
            smoothImage = TreeFilterRGB_Uint8(image, param, 4);
            smoothImage = im2double(smoothImage);
        elseif (strcmp(method, 'FGS') == 1)
            image = im2uint8(image);
            smoothImage = FGS(image, param, 30^2);
            smoothImage = im2double(smoothImage);
        elseif (strcmp(method, 'BLFN') == 1)
            smoothImage = bfilter2(image,5,[param param./20]);
        elseif (strcmp(method, 'AD') == 1)
            %OLD
            smoothImage(:,:,1) = anisodiff(image(:,:,1), param, 50, 0.25, 2);
            smoothImage(:,:,2) = anisodiff(image(:,:,2), param, 50, 0.25, 2);
            smoothImage(:,:,3) = anisodiff(image(:,:,3), param, 50, 0.25, 2);
            
            %NEW
            %smoothImage = anisotropic_diffusion(image(:,:,1), param, 40);
            %smoothImage(:,:,2) = anisotropic_diffusion(image(:,:,2), param, 40);
            %smoothImage(:,:,3) = anisotropic_diffusion(image(:,:,3), param, 40);
        elseif (strcmp(method, 'RTV') == 1)
            smoothImage = tsmooth(image, param, 3);
        elseif (strcmp(method, 'FLLF') == 1)
            image = im2uint8(image);
            smoothImage = localLapFilter(image, param);
            smoothImage = im2double(smoothImage);
        end
        
        if (isa(smoothImage, 'uint8'))
            smoothImage = im2double(smoothImage);
        end
        
        if (doSave)
            save(smoothedPathMat, 'smoothImage');
        end
end