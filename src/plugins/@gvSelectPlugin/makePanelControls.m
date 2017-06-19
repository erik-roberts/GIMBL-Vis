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

% 1.1)
% active hypercube name edit
makeActiveHypercubeEdit(mainVbox)

% 1.2)
% data panel
uiControlsHandles.dataPanel.handle = pluginObj.makeDataPanelControls(mainVbox);


%% Set layout sizes
set(mainVbox, 'Heights',[fontHeight*2, -1])


%% argout
panelHandle = mainVbox;


%% Nested Fn
  function makeActiveHypercubeEdit(parentHandle)
    hypercubeHbox = uix.HBox('Parent',parentHandle, 'Spacing',spacing, 'Padding',padding);
    
    % activeHypercubeLabel
    thisTag = pluginObj.panelTag('activeHypercubeText');
    uiControlsHandles.activeHypercubeText = uicontrol(...
      'Tag',thisTag,...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','Active Hypercube Name:',...
      'Parent',hypercubeHbox);
    
    % activeHypercubeNameEdit
    thisTag = pluginObj.panelTag('activeHypercubeNameEdit');
    uiControlsHandles.activeHypercubeNameEdit = uicontrol(...
      'Tag',thisTag,...
      'Style','edit',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String',pluginObj.controller.activeHypercubeName,...
      'Callback',pluginObj.callbackHandle(thisTag),...
      'UserData',pluginObj.userData,...
      'Parent',hypercubeHbox);
  end

end