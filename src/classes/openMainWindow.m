function viewObj = openMainWindow(viewObj) % openMainWindow(viewObj)

% TODO remove me
viewObj = struct();
viewObj.mainWindow.handle = [];

if isValidFigHandle(viewObj.mainWindow.handle)
  % TODO: add vprintf
  % viewObj.app.vprintf('mainWindow already exists')
  
  return
end

%% Main Window Fig
mainWindowHandle = gvUI.createMainWindowFig();

% Set mainWindow windowHandle
viewObj.mainWindow.handle = mainWindowHandle;

%% Layout
spacing = 5;
padding = 5;
panelTitleFontSize = .15; % norm

% main vBox
mainVbox = uix.VBox('Parent',mainWindowHandle, 'Spacing',spacing, 'Padding', padding);

% panel grid
panelGrid = uix.Grid('Parent',mainVbox, 'Spacing',spacing, 'Padding', padding);

% plot panel
plotPanel = uix.Panel(...
  'Tag','plotPanel',...  
  'Parent',panelGrid,...
  'Title','Plot Window',...
  'FontUnits','normalized',...
  'FontSize',panelTitleFontSize...
);
viewObj.mainWindow.plotPanel.handle = plotPanel;

% plot marker panel
plotMarkerPanel = uix.Panel(...
  'Tag','plotMarkerOutline',...
  'Parent',panelGrid,...
  'Title','Plot Marker',...
  'FontUnits','normalized',...
  'FontSize',panelTitleFontSize...
);
viewObj.mainWindow.plotMarkerPanel.handle = plotMarkerPanel;


% image panel
imagePanel = uix.Panel(...
  'Tag','imagePanel',...  
  'Parent',panelGrid,...
  'Title','Image Window',...
  'FontUnits','normalized',...
  'FontSize',panelTitleFontSize...
);
viewObj.mainWindow.imagePanel.handle = imagePanel;


% hypercube panel
hypercubePanel = uix.Panel(...
  'Tag','hypercubePanel',...  
  'Parent',panelGrid,...
  'Title','Current Hypercube',...
  'FontUnits','normalized',...
  'FontSize',panelTitleFontSize...
);
viewObj.mainWindow.hypercubePanel.handle = hypercubePanel;

% data panel
dataPanel = uix.Panel(...
  'Tag','dataPanelBox',...  
  'Parent', mainVbox,...
  'Title', 'Hypercube Data',...
  'FontUnits','normalized',...
  'FontSize',panelTitleFontSize/4 ...
);

dataVbox = uix.VBox('Parent',dataPanel); % make box to hold 1)titles and 2)data

gvUI.mainWindow.createDataPanelTitles(dataVbox); % row 1

dataScrollingPanel = uix.ScrollingPanel(...
  'Tag','dataScrollingPanel',...  
  'Parent', dataVbox...
); % row 2
viewObj.mainWindow.dataPanel.handle = dataPanel;
viewObj.mainWindow.dataPanel.scrollHandle = get(dataScrollingPanel);

%% UI Controls
viewObj.mainWindow.plotPanel.controlHandles = gvUI.mainWindow.createPlotPanelControls(plotPanel);

viewObj.mainWindow.plotMarkerPanel.controlHandles = gvUI.mainWindow.createPlotMarkerPanelControls(plotMarkerPanel);

viewObj.mainWindow.imagePanel.controlHandles = gvUI.mainWindow.createImagePanelControls(imagePanel);

[viewObj.mainWindow.dataPanel.controlHandles, dataPanelheight] = gvUI.mainWindow.createDataPanelControls(dataScrollingPanel);

viewObj.mainWindow.hypercubePanel.controlHandles = gvUI.mainWindow.createHypercubePanelControls(hypercubePanel);

%% Set layout sizes
set(panelGrid, 'Widths',[-1 -1], 'Heights',[-1 -1])
set(mainVbox, 'Heights',[-1 -2])
set(dataVbox, 'Heights',[30,-1])
set(dataScrollingPanel, 'Heights',dataPanelheight)


%% Menu
% These handles are arranged in a cell matrix corresponding to the positions in 
% the toolbar and menu columns. The first row contains the toolbar titles.

viewObj.mainWindow.menu.handles = gvUI.mainWindow.createMenu(mainWindowHandle);

end
