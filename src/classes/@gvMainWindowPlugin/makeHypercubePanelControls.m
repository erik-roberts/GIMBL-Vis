function makeHypercubePanelControls(pluginObj, parentHandle)
%% makeHypercubePanelControls
%
% Input: parentHandle - handle for uicontrol parent

fontSize = pluginObj.fontSize;
panelTitleFontSize = fontSize;
spacing = 2; % px
padding = 2; % px

uiControlsHandles = struct();

% mainData panel
mainDataPanel = uix.Panel(...
  'Tag','mainDataPanel',...
  'Parent',parentHandle,...
  'Title','Data',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize...
);

hypercubeHbox = uix.HBox('Parent',mainDataPanel, 'Spacing',spacing, 'Padding',padding);

% activeHyperCubeLabel
uiControlsHandles.activeHyperCubeLabel = uicontrol(...
  'Tag','activeHyperCubeLabel',...
  'Style','text',...
  'FontUnits','points',...
  'FontSize',fontSize,...
  'String','Active Hypercube:',...
  'Parent',hypercubeHbox);

% hypercubeMenu
menuStr = fieldnames(pluginObj.controller.model.data);
activeHypercubeName = pluginObj.controller.view.activeHypercubeName;
menuValue = find( strcmp( menuStr, activeHypercubeName ) );

if isempty(menuStr)
  menuStr = {'[None]'};
  menuValue = 1;
end

uiControlsHandles.hypercubeMenu = uicontrol(...
  'Tag','hypercubeMenu',...
  'Style','popupmenu',...
  'FontUnits','points',...
  'FontSize',fontSize,...
  'String',menuStr,...
  'Value',menuValue,...
  'UserData',pluginObj.userData,...
  'Callback',@gvMainWindowPlugin.activeHyperCubeMenuCallback,...
  'Parent',hypercubeHbox);

% Store Handles
% pluginObj.handles.hypercubePanel.controls = uiControlsHandles;

end