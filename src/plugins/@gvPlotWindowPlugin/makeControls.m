function makeControls(pluginObj, parentHandle)

%% Layout
spacing = 5;
padding = 5;
panelTitleFontSize = pluginObj.fontSize;

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
pluginObj.handles.plotPanel.handle = plotPanel;

% 1.1.2)
% plot marker panel
plotMarkerPanel = uix.Panel(...
  'Tag','plotMarkerOutline',...
  'Parent',panelGrid,...
  'Title','Plot Marker',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize...
);
pluginObj.handles.plotMarkerPanel.handle = plotMarkerPanel;


% 1.1.3)
% hypercube panel
hypercubePanel = uix.Panel(...
  'Tag','hypercubePanel',...
  'Parent',panelGrid,...
  'Title','Active Hypercube',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize...
);
pluginObj.handles.hypercubePanel.handle = hypercubePanel;

% 1.1.4)
pluginObj.handles.hypercubePanel.handle = uix.empty;

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
pluginObj.handles.dataPanel.handle = dataPanel;

%% UI Controls
pluginObj.createPlotPanelControls(plotPanel);

pluginObj.createPlotMarkerPanelControls(plotMarkerPanel);

dataPanelheight = pluginObj.createDataPanelControls(dataScrollingPanel);

% pluginObj.createHypercubePanelControls(hypercubePanel);

%% Set layout sizes
set(panelGrid, 'Widths',[-1 -1], 'Heights',[-1 -1])
set(mainVbox, 'Heights',[180 -1])
set(dataVbox, 'Heights',[30,-1])
set(dataScrollingPanel, 'Heights',dataPanelheight)

end