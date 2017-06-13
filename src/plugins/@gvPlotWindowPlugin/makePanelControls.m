function panelHandle = makePanelControls(pluginObj, parentHandle)
% makePanelControls - make plot panel for tab in main window

% params
spacing = 5;
padding = 5;
panelTitleFontSize = pluginObj.fontSize;

uiControlsHandles = struct();

% 1)
% main vBox
mainVbox = uix.VBoxFlex('Parent',parentHandle, 'Spacing',spacing, 'Padding', padding);

% 1.1)
% panel grid
panelGrid = uix.Grid('Parent',mainVbox, 'Spacing',spacing, 'Padding', padding);

% 1.1.1)
% plot panel
plotPanel = uix.Panel(...
  'Tag','plotPanel',...
  'Parent',panelGrid,...
  'Title','Plot Window',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize...
);
uiControlsHandles.plotPanel.handle = plotPanel;

% 1.1.2)
% plot marker panel
plotMarkerPanel = uix.Panel(...
  'Tag','plotMarkerOutline',...
  'Parent',panelGrid,...
  'Title','Plot Marker',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize...
);
uiControlsHandles.plotMarkerPanel.handle = plotMarkerPanel;


% 1.2)
% data panel
dataPanel = uix.Panel(...
  'Tag','dataPanelBox',...
  'Parent', mainVbox,...
  'Title', 'Hypercube Data',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize ...
);

dataVbox = uix.VBox('Parent',dataPanel); % make box to hold 1)titles and 2)data

% 1.2.1)
createDataPanelTitles(pluginObj, dataVbox); % row 1

% 1.2.2)
dataScrollingPanel = uix.ScrollingPanel(...
  'Tag','dataScrollingPanel',...
  'Parent', dataVbox...
); % row 2
uiControlsHandles.dataPanel.handle = dataPanel;

%% UI Controls
pluginObj.createPlotPanelControls(plotPanel);

pluginObj.createPlotMarkerPanelControls(plotMarkerPanel);

dataPanelheight = pluginObj.createDataPanelControls(dataScrollingPanel);

% pluginObj.createHypercubePanelControls(hypercubePanel);

%% Set layout sizes
set(mainVbox, 'Heights',[100 -1])
set(panelGrid, 'Widths',[-1 -1], 'Heights',[-1])
set(dataVbox, 'Heights',[30,-1])
set(dataScrollingPanel, 'Heights',dataPanelheight)

%% argout
panelHandle = mainVbox;

end