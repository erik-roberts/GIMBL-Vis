function createPlotPanelControls(pluginObj, parentHandle)
%% createPlotPanelControls
%
% Input: parentHandle - handle for uicontrol parent

fontSize = pluginObj.fontSize;
spacing = 2; % px
padding = 2; % px

uiControlsHandles = struct();

% Make 2x2 grid
grid2x2 = uix.Grid('Parent',parentHandle, 'Spacing',spacing, 'Padding',padding);

% (1,1)
% openPlotButton
uiControlsHandles.openPlotButton = uicontrol(...
'Tag','openPlotButton',...
'Style','pushbutton',...
'FontUnits','points',...
'FontSize',fontSize,...
'String','Open Plot',...
'Callback',@(src, evnt) pluginObj.view.openWindow('plotWindow'),...
'Parent',grid2x2);

% (2,1)
% iterateToggle
uiControlsHandles.iterateToggle = uicontrol(...
'Tag','iterateToggle',...
'Style','togglebutton',...
'FontUnits','points',...
'FontSize',fontSize,...
'String','Iterate',...
'Callback',@(hObject,eventdata)gvMainWindow_export('iterateToggle_Callback',hObject,eventdata,guidata(hObject)),...
'Parent',grid2x2);

% Change iterateToggle String
set(uiControlsHandles.iterateToggle, 'String', sprintf('( %s ) Iterate', char(9654))); %start char (arrow)

% (1,2)
% openLegendButton
uiControlsHandles.openLegendButton = uicontrol(...
'Tag','openLegendButton',...
'Style','pushbutton',...
'FontUnits','points',...
'FontSize',fontSize,...
'String','Show Legend',...
'Callback',@(hObject,eventdata)gvMainWindow_export('legendButton_Callback',hObject,eventdata,guidata(hObject)),...
'Parent',grid2x2);

% (2,2)
% Use Hbox for delay
delayHbox = uix.HBox('Parent',grid2x2, 'Spacing',spacing, 'Padding',padding);
makeDelayHbox(delayHbox);

% Set layout sizes
set(grid2x2, 'Heights',[-1 -1], 'Widths',[-1 -1]);

% Store Handles
pluginObj.handles.plotPanel.controls = uiControlsHandles;


%% Nested fn
  function makeDelayHbox(delayHbox)
    % delayLabel
    uiControlsHandles.delayLabel = uicontrol(...
      'Tag','delayLabel',...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','Delay [s]:',...
      'Parent',delayHbox);
    
    
    % delayValueBox
    uiControlsHandles.delayValueBox = uicontrol(...
      'Tag','delayValueBox',...
      'Style','edit',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','0.5',...
      'Value',0.5,...
      'Callback',@(hObject,eventdata)gvMainWindow_export('delayBox_Callback',hObject,eventdata,guidata(hObject)),...
      'Parent',delayHbox);
    
      set(delayHbox, 'Widths',[-1, -1])
  end

end