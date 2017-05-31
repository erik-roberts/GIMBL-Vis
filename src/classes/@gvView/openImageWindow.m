function openImageWindow(viewObj)

mainWindowExistBool = viewObj.checkMainWindowExists;

if mainWindowExistBool && ~isValidFigHandle(viewObj.imageWindow.windowHandle)
  plotDir = viewObj.app.plotDir;
  
  if exist(plotDir, 'dir')
    %% Find Plots
    dirList = lscell(plotDir, true);
    viewObj.imageWindow.plotFiles = dirList;
    
    plotFiles = regexp(dirList, '^([^_]*)_', 'tokens');
    plotFiles = plotFiles(~cellfun(@isempty, plotFiles));
    plotFiles = cellfun(@(x) x{1}, plotFiles);
    
    if isempty(plotFiles)
      wprintf('No plot files found in plot dir.');
      return
    end
    
    plotTypes = unique(plotFiles);
    
    % Set GUI elements
    viewObj.imageWindow.handles.imageTypeMenu.String = plotTypes;
    viewObj.imageWindow.handles.imageTypeMenu.UserData.lastVal = 1;
    viewObj.imageWindow.handles.ImageWindow.plotType = plotTypes{1};
    
    %% Create Image Window
    createImageWindow(viewObj);
  else
    wprintf('Plot dir not found. Set plot dir using ''gvObj.plotDir'' property.');
  end
end

  %% Nested Functions
  function createImageWindow(viewObj)
    plotPanPos = viewObj.plotWindow.windowHandle.Position;
    newPos = plotPanPos; % same size as plot window
    newPos(1) = newPos(1)+newPos(3)+50; % move right
    %       newPos(3:4) = newPos(3:4)*.8; %shrink
    imageWindowHandle = figure('Name','Image Window','NumberTitle','off','Position',newPos);
    
    axes(imageWindowHandle, 'Position', [0 0 1 1], 'XTickLabels',[], 'YTickLabels',[],...
      'XTick',[], 'YTick',[]);
    
    % set image windowHandle
    viewObj.imageWindow.windowHandle = imageWindowHandle;
  end

end