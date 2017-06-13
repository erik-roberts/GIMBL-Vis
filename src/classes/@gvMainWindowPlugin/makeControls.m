function makeControls( pluginObj, parentHandle )

spacing = 5;
padding = 5;
fontSize = pluginObj.fontSize;
pxHeight = 20; % px

uiControlsHandles = struct();

loadedPlugins = pluginObj.controller.plugins;
loadedPlugins = rmfield(loadedPlugins, 'main');
loadedPlugins = struct2cell(loadedPlugins);

pluginList = gv.ListPlugins;
lugins = {};
for i = 1:length(pluginList)
  thisPlugin = eval(pluginList{i});
  plugins{i} = thisPlugin;
end
nPlugins = length(plugins);

makeTabs();

% main vBox
% mainVbox = uix.VBoxFlex('Parent',pluginObj.handles.fig, 'Spacing',spacing, 'Padding', padding);

% % panel grid
% panelGrid = uix.Grid('Parent',mainVbox, 'Spacing',spacing, 'Padding', padding);

% % hypercube panel
% hypercubePanel = uix.Panel(...
%   'Tag','hypercubePanel',...
%   'Parent',panelGrid,...
%   'Title','Current Hypercube',...
%   'FontUnits','points',...
%   'FontSize',panelTitleFontSize...
% );
% pluginObj.handles.hypercubePanel.handle = hypercubePanel;

% % data panel
% dataPanel = uix.Panel(...
%   'Tag','dataPanelBox',...
%   'Parent', mainVbox,...
%   'Title', 'Hypercube Data',...
%   'FontUnits','points',...
%   'FontSize',panelTitleFontSize ...
% );

% dataVbox = uix.VBox('Parent',dataPanel); % make box to hold 1)titles and 2)data

% createDataPanelTitles(pluginObj, dataVbox); % row 1

% dataScrollingPanel = uix.ScrollingPanel(...
%   'Tag','dataScrollingPanel',...
%   'Parent', dataVbox...
% ); % row 2
% pluginObj.handles.dataPanel.handle = dataPanel;

%% UI Controls
% dataPanelheight = pluginObj.createDataPanelControls(dataScrollingPanel);

% pluginObj.createHypercubePanelControls(hypercubePanel);

%% Set layout sizes
% set(panelGrid, 'Widths',[-1 -1], 'Heights',[-1 -1])
% set(mainVbox, 'Heights',[180 -1])
% set(dataVbox, 'Heights',[30,-1])
% set(dataScrollingPanel, 'Heights',dataPanelheight)

pluginObj.handles.controls = uiControlsHandles;


%% Nested Fn
  function makeTabs()
    tabPanel = uix.TabPanel('Parent',parentHandle, 'Padding', padding);
    uiControlsHandles.tabPanel = tabPanel;
    
    guiPlugins = pluginObj.controller.guiPlugins;
    guiPlugins = struct2cell(guiPlugins);
    
    flds = {};
    uiControlsHandles.tabs = {};
    for k = 1:length(guiPlugins)
      if k == 1
        uiControlsHandles.tabs{k} = makeMainTabControls(tabPanel);
      else
        uiControlsHandles.tabs{k} = uix.Empty('Parent',tabPanel);
      end
      
      flds{end+1} = guiPlugins{k}.pluginName;
    end
    
    tabPanel.TabTitles = unique([{'Main'}, flds] );
  end


  function pluginVbox = makeMainTabControls(parentHandle)
    pluginVbox = uix.VBox('Parent',parentHandle); % make box to hold 1)titles and 2)plugins
    
    makePluginGrid(pluginVbox)
    
    set(pluginVbox, 'Heights',[30,-1])
  end


  function makePluginGrid(parentHandle)
    % row 1
    makePluginGridTitles(parentHandle); 
    
    % row 2
    scrollingPanel = uix.ScrollingPanel(...
      'Tag','mainScrollingPanel',...
      'Parent', parentHandle...
      );
    uiControlsHandles.main.scrollingPanel = scrollingPanel;
    
    pluginGrid = uix.Grid('Tag','mainPluginGrid', 'Parent',scrollingPanel, 'Spacing',spacing, 'Padding',padding);
    uiControlsHandles.main.pluginGrid = pluginGrid;
    
    makePluginNamesCol(pluginGrid)
    makeLoadCol(pluginGrid)
    
    set(pluginGrid, 'Heights',pxHeight*ones(1, nPlugins), 'Widths',[-10,-1])
  end


  function makePluginGridTitles(parentHandle)
    titleFontWeight = 'bold';

    pluginGridTitlesHbox = uix.HBox('Parent',parentHandle, 'Padding', padding);

    % varTitle
    uiControlsHandles.main.pluginNameTitle = uicontrol(...
      'Tag','mainPluginNameTitle',...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'FontWeight',titleFontWeight,...
      'String','Plugins',...
      'Value',get(0,'defaultuicontrolValue'),...
      'Parent',pluginGridTitlesHbox);
    
    % valueTitle
    uiControlsHandles.main.loadPluginTitle = uicontrol(...
      'Tag','mainLoadPluginTitle',...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'FontWeight',titleFontWeight,...
      'String','Load',...
      'Parent',pluginGridTitlesHbox);
    
    set(pluginGridTitlesHbox, 'Widths',[-6,-1])
  end


  function makePluginNamesCol(parentHandle)
    % Row 1
    %   titles from 'makePluginGridTitles.m'
    
    % Row 2:nPlugins+1
    for n = 1:nPlugins
      nStr = num2str(n);
      plugin = plugins{n};
      
      uiControlsHandles.main.(['pluginText' nStr]) = uicontrol(...
        'Tag',['pluginText' nStr],...
        'Style','text',...
        'FontUnits','points',...
        'FontSize',fontSize,...
        'String',plugin.pluginName,...
        'Parent',parentHandle);
    end
  end


  function makeLoadCol(parentHandle)
    % Row 2:nPlugins+1
    for n = 1:nPlugins
      nStr = num2str(n);
      
      pluginFieldName = plugins{n}.pluginFieldName;
      loadedBool = any(strcmp(fieldnames(pluginObj.controller.plugins), pluginFieldName));
      
      % viewCheckbox
      uiControlsHandles.main.(['pluginCheckbox' nStr]) = uicontrol(...
        'Tag',['mainLoadCheckbox' nStr],...
        'Style','checkbox',...
        'Value',loadedBool,...
        'Callback',@(hObject,eventdata)gvMainWindow_export('viewDim1_Callback',hObject,eventdata,guidata(hObject)),...
        'Parent',parentHandle);
    end
  end
end

