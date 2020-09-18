function param = getParam(paramStr)
paramStr = strrep(paramStr, '.png', '');
paramStr = strrep(paramStr, '.mat', '');
param = str2double(strrep(paramStr, '-', '.'));

end