function showImage(pluginObj, index)

if isempty(pluginObj.metadata.matchedImageIndList)
  pluginObj.updateMatchedImageList();
end

% find file matching index
fileLogicalInd = (pluginObj.metadata.matchedImageIndList == index);

if any(fileLogicalInd)
  filePath = pluginObj.metadata.matchedImageList{fileLogicalInd};
else
  filePath = [];
end

figH = pluginObj.handles.fig;
imAxH = findobj(figH.Children,'type','axes');

imageType = getImageTypeFromGUI(pluginObj);

if ~isempty(filePath) && exist(filePath, 'file')
  imshow(filePath, 'Parent', imAxH);
  
  % parse filename
  [~, filename] = fileparts(fullFilename);
  filename = strrep(filename, '_','\_'); % replace '_' with '\_' to avoid subscript
  
  try
    title(imAxH, filename);
  catch
    title(imAxH, sprintf('%s %i', imageType, index));
  end
else
  cla(imAxH);
  xlim(imAxH, [0,1])
  ylim(imAxH, [0,1])
  text(imAxH, 0.1,0.5,sprintf('No ''%s'' image found for index %i', imageType, index),...
    'FontUnits','normalized', 'FontSize',0.06)
end

end
