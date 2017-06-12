function gvShowImage(handles)

plotDir = handles.ImageWindow.plotDir;
plotFiles = handles.ImageWindow.plotFiles;
plotType = handles.ImageWindow.plotType;
simID = handles.ImageWindow.simID;

simFiles = regexp(plotFiles, [plotType '.*sim' num2str(simID)]);
filenameCell = plotFiles(~cellfun(@isempty, simFiles));


imgPanelH = handles.ImageWindow.handle;
imAxH = findobj(imgPanelH.Children,'type','axes');

if ~isempty(filenameCell)
  filePath = fullfile(plotDir, filenameCell{1});
  if exist(filePath, 'file')
    imshow(filePath, 'Parent', imAxH);
  end
else
  cla(imAxH);
  xlim(imAxH, [0,1])
  ylim(imAxH, [0,1])
  text(imAxH, 0.1,0.5,sprintf('No %s plot found for simID %i',plotType, simID),...
    'FontUnits','normalized', 'FontSize',0.06)
end

end