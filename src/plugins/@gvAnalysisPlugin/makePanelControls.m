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
% input panel
thisTag = pluginObj.panelTag('input');
inputPanel = uix.Panel(...
  'Tag',thisTag,...
  'Title','Input',...
  'FontUnits','points',...
  'FontSize',fontSize,...
  'Parent',mainVbox...
);
uiControlsHandles.plotPanel.handle = inputPanel;

% 1.2)
% output panel
thisTag = pluginObj.panelTag('output');
outputPanel = uix.Panel(...
  'Tag',thisTag,...
  'Title','Output',...
  'FontUnits','points',...
  'FontSize',fontSize,...
  'Parent',mainVbox...
);
uiControlsHandles.plotMarkerPanel.handle = outputPanel;

% 1.3)
% applybutton
thisTag = pluginObj.panelTag('applyButton');
uiControlsHandles.openPlotButton = uicontrol(...
  'Tag',thisTag,...
  'Style','pushbutton',...
  'FontUnits','points',...
  'FontSize',fontSize,...
  'String','Apply',...
  'UserData',pluginObj.userData,...
  'Callback',pluginObj.callbackHandle(thisTag),...
  'Parent',mainVbox);


%% UI Controls
pluginObj.makeInputPanelControls(inputPanel);

pluginObj.makeOutputPanelControls(outputPanel);

%% Set layout sizes
% panelHeight = fontHeight + spacing + padding;
set(mainVbox, 'Heights',[-1, -1, fontHeight*1.5]);

%% argout
panelHandle = uiControlsHandles;

%% notify listener
notify(pluginObj, 'panelControlsMade');

end