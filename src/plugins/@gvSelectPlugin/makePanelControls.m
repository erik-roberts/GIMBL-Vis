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
thisTag = pluginObj.panelTag('vbox');
mainVbox = uix.VBox(...
  'Tag',thisTag,...
  'Spacing',spacing,...
  'Padding', padding,...
  'Parent',parentHandle...
);
uiControlsHandles.parent = mainVbox;

if isempty(pluginObj.controller.activeHypercube.data)
  panelHandle = uiControlsHandles;
  return
end

% 1.1)
% edit mode toggle
makeEditToggle(mainVbox);

% 1.2)
% data panel
uiControlsHandles.dataPanel = pluginObj.makeDataPanelControls(mainVbox);


%% Set layout sizes
set(mainVbox, 'Heights',[fontHeight*1.5, -1])


%% argout
panelHandle = uiControlsHandles;

%% add scroll callback
pluginObj.view.main.addDynamicCallback('WindowScrollWheelFcn', @gvSelectPlugin.Callback_WindowScrollWheelFcn);

%% notify listener
notify(pluginObj, 'panelControlsMade');


%% Nested Fn
  function makeEditToggle(parentHandle)
    thisTag = pluginObj.panelTag('editModeToggle');
    uiControlsHandles.iterateToggle = uicontrol(...
      'Tag',thisTag,...
      'Style','togglebutton',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','Toggle Edit Mode',...
      'UserData',pluginObj.userData,...
      'Callback',pluginObj.callbackHandle(thisTag),...
      'Parent',parentHandle);
  end

end