function openMainWindow(viewObj)

if isValidFigHandle(viewObj.mainWindow.handle)
  try
    viewObj.app.vprintf('Reopening main window\n')
  end
  
  viewObj.mainWindow.handle.delete()
end

%% Main Window Fig
viewObj.createMainWindowFig();

%% Layout
spacing = 5;
padding = 5;
panelTitleFontSize = viewObj.baseFontSize;

% main vBox
mainVbox = uix.VBoxFlex('Parent',viewObj.mainWindow.handle, 'Spacing',spacing, 'Padding', padding);

% panel grid
panelGrid = uix.Grid('Parent',mainVbox, 'Spacing',spacing, 'Padding', padding);

% plot panel
plotPanel = uix.Panel(...
  'Tag','plotPanel',...
  'Parent',panelGrid,...
  'Title','Plot Window',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize...
);
viewObj.mainWindow.plotPanel.handle = plotPanel;

% plot marker panel
plotMarkerPanel = uix.Panel(...
  'Tag','plotMarkerOutline',...
  'Parent',panelGrid,...
  'Title','Plot Marker',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize...
);
viewObj.mainWindow.plotMarkerPanel.handle = plotMarkerPanel;


% image panel
imagePanel = uix.Panel(...
  'Tag','imagePanel',...
  'Parent',panelGrid,...
  'Title','Image Window',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize...
);
viewObj.mainWindow.imagePanel.handle = imagePanel;


% hypercube panel
hypercubePanel = uix.Panel(...
  'Tag','hypercubePanel',...
  'Parent',panelGrid,...
  'Title','Current Hypercube',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize...
);
viewObj.mainWindow.hypercubePanel.handle = hypercubePanel;

% data panel
dataPanel = uix.Panel(...
  'Tag','dataPanelBox',...
  'Parent', mainVbox,...
  'Title', 'Hypercube Data',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize ...
);

dataVbox = uix.VBox('Parent',dataPanel); % make box to hold 1)titles and 2)data

createDataPanelTitles(viewObj, dataVbox); % row 1

dataScrollingPanel = uix.ScrollingPanel(...
  'Tag','dataScrollingPanel',...
  'Parent', dataVbox...
); % row 2
viewObj.mainWindow.dataPanel.handle = dataPanel;

%% UI Controls
viewObj.createPlotPanelControls(plotPanel);

viewObj.createPlotMarkerPanelControls(plotMarkerPanel);

viewObj.createImagePanelControls(imagePanel);

dataPanelheight = viewObj.createDataPanelControls(dataScrollingPanel);

viewObj.createHypercubePanelControls(hypercubePanel);

%% Set layout sizes
set(panelGrid, 'Widths',[-1 -1], 'Heights',[-1 -1])
set(mainVbox, 'Heights',[180 -1])
set(dataVbox, 'Heights',[30,-1])
set(dataScrollingPanel, 'Heights',dataPanelheight)


%% Menu
% These handles are arranged in a cell matrix corresponding to the positions in 
% the toolbar and menu columns. The first row contains the toolbar titles.

createMenu(viewObj, viewObj.mainWindow.handle);

end
