function openWindow(pluginObj)

mainWindowExistBool = pluginObj.view.checkMainWindowExists(true);

if mainWindowExistBool && ~isValidFigHandle(pluginObj.imageWindow.handle)
  plotDir = pluginObj.plotDir;
  
  if exist(plotDir, 'dir')
    %% Find Plots
    dirList = lscell(plotDir, true);
    pluginObj.imageWindow.plotFiles = dirList;
    
    plotFiles = regexp(dirList, '^([^_]*)_', 'tokens');
    plotFiles = plotFiles(~cellfun(@isempty, plotFiles));
    plotFiles = cellfun(@(x) x{1}, plotFiles);
    
    if isempty(plotFiles)
      wprintf('No plot files found in plot dir.');
      return
    end
    
    plotTypes = unique(plotFiles);
    
    % Set GUI elements
    pluginObj.imageWindow.handles.imageTypeMenu.String = plotTypes;
    pluginObj.imageWindow.handles.imageTypeMenu.UserData.lastVal = 1;
    pluginObj.imageWindow.handles.ImageWindow.plotType = plotTypes{1};
    
    %% Create Image Window
    pluginObj.createFig();
  else
    wprintf('Plot dir not found. Set plot dir using ''gvObj.plotDir'' property.');
  end
end

end
