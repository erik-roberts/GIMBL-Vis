function panelHandle = makePanelControls(pluginObj, parentHandle)
%% makePanelControls
%
% Input: parentHandle - handle for uicontrol parent

fontSize = pluginObj.fontSize;
spacing = 2; % px
padding = 2; % px

uiControlsHandles = struct();

mainVbox = uix.VBox('Parent',parentHandle, 'Spacing',spacing, 'Padding',padding);

% vbox Row 1
row1hBox = uix.HBox('Parent',mainVbox, 'Spacing',spacing);
makeRow1Hbox(row1hBox);

% vbox Row 2
uix.Empty('Parent', mainVbox);

% Store Handles
% pluginObj.handles.imagePanel.controls = uiControlsHandles;

%% argout
panelHandle = mainVbox;

%% Nested fn
  function makeRow1Hbox(hBox)
    % openImageButton
    thisTag = pluginObj.panelTag('openWindowButton');
    uiControlsHandles.openImageButton = uicontrol(...
      'Tag',thisTag,...
      'Style','pushbutton',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','Open Image',...
      'Callback',pluginObj.callbackHandle(thisTag),...
      'Parent',hBox);
    
    
    % imageTypeLabel
    thisTag = pluginObj.panelTag('imageTypeLabel');
    uiControlsHandles.imageTypeLabel = uicontrol(...
      'Tag',thisTag,...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','Type:',...
      'Parent',hBox);
    
    
    % imageTypeMenu
    thisTag = pluginObj.panelTag('imageTypeMenu');
    uiControlsHandles.imageTypeMenu = uicontrol(...
      'Tag',thisTag,...
      'Style','popupmenu',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','ImageType',...
      'Value',1,...
      'Callback',pluginObj.callbackHandle(thisTag),...
      'Parent',hBox);
    
      set(hBox, 'Widths',[-2 -1 -3]);
  end
end
