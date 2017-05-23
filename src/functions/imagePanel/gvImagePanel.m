function gvImagePanel(hObject, eventdata, handles)

if ~isValidFigHandle(handles.ImagePanel.handle)
  plotDir = handles.ImagePanel.plotDir;
  
  if exist(plotDir, 'dir')
    %% Find Plots
    dirList = lscell(plotDir, true);
    handles.ImagePanel.plotFiles = dirList;
    
    plotFiles = regexp(dirList, '^([^_]*)_', 'tokens');
    plotFiles = plotFiles(~cellfun(@isempty, plotFiles));
    plotFiles = cellfun(@(x) x{1}, plotFiles);
    
    if isempty(plotFiles)
      wprintf('No plot files found in plots dir.');
      return
    end
    
    plotTypes = unique(plotFiles);
    plotTypes = sort(plotTypes);
    plotTypes = flip(plotTypes); %so waveform first
    
    handles.imageTypeMenu.String = plotTypes;
    handles.imageTypeMenu.UserData.lastVal = 1;
    handles.ImagePanel.plotType = plotTypes{1};
    
    %% Create Image Panel
    createImagePanel()
  else
    wprintf('plots dir not found.');
  end
end

% Update handles structure
guidata(hObject, handles);

%% Sub Functions
  function createImagePanel()
    if ~isValidFigHandle('handles.PlotPanel.figHandle')
      hFig = figure('Name','Image Panel','NumberTitle','off');
    else
      plotPanPos = handles.PlotPanel.figHandle.Position;
      newPos = plotPanPos; % same size as plot panel
      newPos(1) = newPos(1)+newPos(3)+50; % move right
      %       newPos(3:4) = newPos(3:4)*.8; %shrink
      hFig = figure('Name','Image Panel','NumberTitle','off','Position',newPos);
    end
    
    axes(hFig, 'Position', [0 0 1 1], 'XTickLabels',[], 'YTickLabels',[],...
      'XTick',[], 'YTick',[]);
    handles.ImagePanel.handle = hFig;
    hFig.UserData.MainFigH = handles.output;
  end

end