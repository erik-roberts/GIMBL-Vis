function panelHandle = makePanelControls(pluginObj, parentHandle)
% makePanelControls - make plot panel for tab in main window

% params
spacing = 5;
padding = 5;
fontSize = pluginObj.fontSize;
fontHeight = pluginObj.fontHeight;

uiControlsHandles = struct();

% 1)
% main vBox
mainVbox = uix.VBox('Parent',parentHandle, 'Spacing',spacing, 'Padding', padding);

% 1.1)
% plot panel
plotPanel = uix.Panel(...
  'Tag','plotPanel',...
  'Parent',mainVbox,...
  'Title','Plot Window',...
  'FontUnits','points',...
  'FontSize',fontSize...
);
uiControlsHandles.plotPanel.handle = plotPanel;

% 1.2)
% plot marker panel
plotMarkerPanel = uix.Panel(...
  'Tag','plotMarkerOutline',...
  'Parent',mainVbox,...
  'Title','Plot Marker',...
  'FontUnits','points',...
  'FontSize',fontSize...
);
uiControlsHandles.plotMarkerPanel.handle = plotMarkerPanel;


%% UI Controls
pluginObj.makePlotPanelControls(plotPanel);

pluginObj.makePlotMarkerPanelControls(plotMarkerPanel);

%% Set layout sizes
panelHeight = fontHeight*5 + spacing + padding;
set(mainVbox, 'Heights',[panelHeight panelHeight])

%% argout
panelHandle = mainVbox;

end