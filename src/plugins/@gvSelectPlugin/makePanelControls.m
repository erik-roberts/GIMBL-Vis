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

if isempty(pluginObj.controller.activeHypercube) || isempty(pluginObj.controller.activeHypercube.data)
  panelHandle = uiControlsHandles;
  pluginObj.view.dynamic.nViewDims = 0;
  pluginObj.view.dynamic.nViewDimsLast = 0;
  return
end

% 1.1)
% edit mode toggle
makeEditToggle(mainVbox);

% 1.2)
% data panel
uiControlsHandles.dataPanel = pluginObj.makeDataPanelControls(mainVbox);

% 1.3)
% iterate toggle
makeIterateControls(mainVbox)

%% Set layout sizes
set(mainVbox, 'Heights',[fontHeight*1.5, -1, fontHeight*2])


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


  function makeIterateControls(parentHandle)
    thisHbox = uix.HBox('Parent',parentHandle, 'Spacing',spacing, 'Padding',padding);
    
    % iterateToggle
    thisTag = pluginObj.panelTag('iterateToggle');
    uiControlsHandles.iterateToggle = uicontrol(...
      'Tag',thisTag,...
      'Style','togglebutton',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','Iterate',...
      'UserData',pluginObj.userData,...
      'Callback',pluginObj.callbackHandle(thisTag),...
      'Parent',thisHbox);
    
    % Change iterateToggle String
    set(uiControlsHandles.iterateToggle, 'String', sprintf('Iterate ( %s )', char(9654))); %start char (arrow)

    
    % delayControls
    makeDelayControls(thisHbox);
    
    set(thisHbox, 'Widths',[-1, -1]);
  end


  function makeDelayControls(parentHandle)
    thisHbox = uix.HBox('Parent',parentHandle);
    
    % delayLabel
    thisTag = pluginObj.panelTag('delayLabel');
    uiControlsHandles.delayLabel = uicontrol(...
      'Tag',thisTag,...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','Delay [s]:',...
      'Parent',thisHbox);
    
    
    % delayValueBox
    thisTag = pluginObj.panelTag('delayValueBox');
    uiControlsHandles.delayValueBox = uicontrol(...
      'Tag',thisTag,...
      'Style','edit',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','0.5',...
      'Value',0.5,...
      'UserData',pluginObj.userData,...
      'Callback',pluginObj.callbackHandle(thisTag),...
      'Parent',thisHbox);
    
      set(thisHbox, 'Widths',[-3, -1.3]);
  end

end