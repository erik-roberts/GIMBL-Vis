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
    uiControlsHandles.activeHypercubeText = uicontrol(...
      'Tag','activeHypercubeText',...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','Active Hypercube Name:',...
      'Parent',hypercubeHbox);
    
    % activeHypercubeNameEdit
    thisTag = 'activeHypercubeNameEdit';
    uiControlsHandles.activeHypercubeNameEdit = uicontrol(...
      'Tag',thisTag,...
      'Style','edit',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String',pluginObj.controller.activeHypercubeName,...
      'Callback',eval(['@gvSelectPlugin.Callback_' thisTag]),...
      'UserData',pluginObj.userData,...
      'Parent',hypercubeHbox);
  end

end