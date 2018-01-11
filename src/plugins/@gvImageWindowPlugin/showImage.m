function showImage(pluginObj, index)

imageDir = pluginObj.getImageDirPath();

% Find images in imageDir
dirList = pluginObj.getImageList();

% Use regexp to parse image type and index
imageFiles = regexp(dirList, pluginObj.metadata.imageRegexp, 'tokens');
imageFiles = imageFiles(~cellfun(@isempty, imageFiles));
imageFiles = cellfunu(@(x) x{1}, imageFiles);

% get tokens
imageTypes = cellfunu(@(x) x{1}, imageFiles);
imageInd = cellfunu(@(x) x{2}, imageFiles);
imageInd = str2double(imageInd);

imageType = pluginObj.getImageTypeFromGUI();

fileLogicalInd = strcmp(imageTypes, imageType) & (index == imageInd);

if any(fileLogicalInd)
  fullFilename = dirList(fileLogicalInd);
  fullFilename = fullFilename{1};
else
  fullFilename = [];
end

figH = pluginObj.handles.fig;
imAxH = findobj(figH.Children,'type','axes');

if ~isempty(fullFilename)
  filePath = fullfile(imageDir, fullFilename);
  if exist(filePath, 'file')
    imshow(filePath, 'Parent', imAxH);
    
    % parse filename
    [~, filename] = fileparts(fullFilename);
    filename = strrep(filename, '_','\_'); % replace '_' with '\_' to avoid subscript
    
    try
      title(imAxH, filename);
    catch
      title(imAxH, sprintf('%s %i', imageType, index));
    end
  end
else
  cla(imAxH);
  xlim(imAxH, [0,1])
  ylim(imAxH, [0,1])
  text(imAxH, 0.1,0.5,sprintf('No %s image found for index %i', imageType, index),...
    'FontUnits','normalized', 'FontSize',0.06)
end

end
