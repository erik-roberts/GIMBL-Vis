function panelHandle = makePanelControls(pluginObj, parentHandle)
% makePanelControls - make list of plugins with load checkboxes

% params
spacing = 5;
padding = 5;
fontSize = pluginObj.fontSize;
panelTitleFontSize = fontSize;
pxHeight = 20; % px

% plugin info
loadedPlugins=[];
plugins = [];
nPlugins = [];
getPluginInfo();

uiControlsHandles = struct();

mainVbox = uix.VBox('Parent',parentHandle, 'Spacing',spacing, 'Padding',padding); % make box to hold panels

pluginObj.makeHypercubePanelControls(mainVbox);
makePluginPanel(mainVbox);

set(mainVbox, 'Heights',[50, -1])

panelHandle = mainVbox;


%% Nested Fn
  function getPluginInfo()
    loadedPlugins = pluginObj.controller.plugins;
    loadedPlugins = rmfield(loadedPlugins, 'main');
    loadedPlugins = struct2cell(loadedPlugins);
    
    pluginList = gv.ListPlugins;
    plugins = {};
    for i = 1:length(pluginList)
      thisPlugin = eval(pluginList{i});
      plugins{i} = thisPlugin;
    end
    nPlugins = length(plugins);
  end

  
  function makePluginPanel(parentHandle)
    % pluginPanel
    pluginPanel = uix.Panel(...
      'Tag','pluginPanel',...
      'Parent',parentHandle,...
      'Title','Plugins',...
      'FontUnits','points',...
      'FontSize',panelTitleFontSize...
    );
  
    pluginVbox = uix.VBox('Parent',pluginPanel, 'Spacing',spacing, 'Padding',padding); % make box to hold 1)titles and 2)plugins

    % row 1
    makePluginGridTitles(pluginVbox);
    
    % row 2
    scrollingPanel = uix.ScrollingPanel(...
      'Tag','mainScrollingPanel',...
      'Parent', pluginVbox...
      );
    uiControlsHandles.scrollingPanel = scrollingPanel;
    
    pluginGrid = uix.Grid('Tag','mainPluginGrid', 'Parent',scrollingPanel, 'Spacing',spacing, 'Padding',padding);
    uiControlsHandles.pluginGrid = pluginGrid;
    
    makePluginNamesCol(pluginGrid)
    makeLoadCol(pluginGrid)
    
    set(pluginGrid, 'Heights',pxHeight*ones(1, nPlugins), 'Widths',[-10,-1])
    
    set(pluginVbox, 'Heights',[30, -1])
  end


  function makePluginGridTitles(parentHandle)
    titleFontWeight = 'bold';
    
    pluginGridTitlesHbox = uix.HBox('Parent',parentHandle, 'Padding', padding);
    
    % varTitle
    uiControlsHandles.pluginNameTitle = uicontrol(...
      'Tag','mainPluginNameTitle',...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'FontWeight',titleFontWeight,...
      'String','Plugins',...
      'Value',get(0,'defaultuicontrolValue'),...
      'Parent',pluginGridTitlesHbox);
    
    % valueTitle
    uiControlsHandles.loadPluginTitle = uicontrol(...
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
    %
    % Row 2:nPlugins
    
    for n = 1:nPlugins
      nStr = num2str(n);
      plugin = plugins{n};
      
      uiControlsHandles.(['pluginText' nStr]) = uicontrol(...
        'Tag',['pluginText' nStr],...
        'Style','text',...
        'FontUnits','points',...
        'FontSize',fontSize,...
        'String',plugin.pluginName,...
        'Parent',parentHandle);
    end
  end


  function makeLoadCol(parentHandle)
    % Row 1
    %   titles from 'makePluginGridTitles.m'
    %
    % Row 2:nPlugins
    
    for n = 1:nPlugins
      nStr = num2str(n);
      plugin = plugins{n};
      pluginFieldName = plugin.pluginFieldName;
      pluginClassName = class(plugin);
      loadedBool = any(strcmp(fieldnames(pluginObj.controller.plugins), pluginFieldName));
      
      thisUserData = catstruct(pluginObj.userData,...
        struct('pluginFieldName',pluginFieldName, 'pluginClassName',pluginClassName));
      
      % viewCheckbox
      uiControlsHandles.(['pluginCheckbox' nStr]) = uicontrol(...
        'Tag',['mainLoadCheckbox' nStr],...
        'Style','checkbox',...
        'Value',loadedBool,...
        'UserData',thisUserData,...
        'Callback',@gvMainWindowPlugin.Callback_loadPluginCheckbox,...
        'Parent',parentHandle);
    end
  end

end