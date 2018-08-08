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
uiControlsHandles.parent = mainVbox;

% 1.1)
% plot panel
thisTag = pluginObj.panelTag('plotPanel');
plotPanel = uix.Panel(...
  'Tag',thisTag,...
  'Parent',mainVbox,...
  'Title','Plot Window',...
  'FontUnits','points',...
  'FontSize',fontSize...
);
uiControlsHandles.plotPanel.handle = plotPanel;

% 1.2)
% plot marker panel
thisTag = pluginObj.panelTag('plotMarkerOutline');
plotMarkerPanel = uix.Panel(...
  'Tag',thisTag,...
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
panelHeight = fontHeight*8 + spacing + padding;
set(mainVbox, 'Heights',[panelHeight*.45 panelHeight])

%% argout
panelHandle = uiControlsHandles;

%% add scroll callback
pluginObj.view.main.addDynamicCallback('WindowScrollWheelFcn', @gvPlotWindowPlugin.Callback_WindowScrollWheelFcn);

%% notify listener
notify(pluginObj, 'panelControlsMade');

end