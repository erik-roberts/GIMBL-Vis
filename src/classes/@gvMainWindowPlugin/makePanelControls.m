function panelHandle = makePanelControls(pluginObj, parentHandle)
% makePanelControls - make list of plugins with load checkboxes

% params
spacing = 5;
padding = 5;
fontSize = pluginObj.fontSize;
panelTitleFontSize = fontSize;
fontHeight = pluginObj.fontHeight;
pxHeight = fontHeight + spacing; % px

% plugin info
loadedPlugins=[];
plugins = [];
nPlugins = [];
getPluginInfo();

uiControlsHandles = struct();

thisTag = pluginObj.panelTag('vbox');
mainVbox = uix.VBox('Parent',parentHandle, 'Tag',thisTag, 'Spacing',spacing, 'Padding',padding); % make box to hold panels
uiControlsHandles.parent = mainVbox;

uiControlsHandles.hypercubePanel = pluginObj.makeHypercubePanelControls(mainVbox);

makePluginPanel(mainVbox);

set(mainVbox, 'Heights',[fontHeight*3, -1])

panelHandle = uiControlsHandles;


%% Nested Fn
  function getPluginInfo()
    loadedPlugins = pluginObj.controller.plugins;
    loadedPlugins = rmfield(loadedPlugins, 'main');
    loadedPlugins = struct2cell(loadedPlugins);
    
    pluginList = gv.ListPluginsFromDir;
    plugins = {};
    for i = 1:length(pluginList)
      thisPlugin = eval(pluginList{i});
      plugins{i} = thisPlugin;
    end
    nPlugins = length(plugins);
  end

  
  function makePluginPanel(parentHandle)
    % pluginPanel
    thisTag = pluginObj.panelTag('pluginPanel');
    pluginPanel = uix.Panel(...
      'Tag',thisTag,...
      'Parent',parentHandle,...
      'Title','Plugins',...
      'FontUnits','points',...
      'FontSize',panelTitleFontSize...
    );
  
    pluginVbox = uix.VBox('Parent',pluginPanel, 'Spacing',spacing, 'Padding',padding); % make box to hold 1)titles and 2)plugins

    % row 1
    makePluginGridTitles(pluginVbox);
    
    % row 2
    thisTag = pluginObj.panelTag('scrollingPanel');
    scrollingPanel = uix.ScrollingPanel('Tag',thisTag, 'Parent',pluginVbox);
    uiControlsHandles.scrollingPanel = scrollingPanel;
    
    % TODO fix scrolling
    thisTag = pluginObj.panelTag('pluginGrid');
    pluginGrid = uix.Grid('Tag',thisTag, 'Parent',scrollingPanel, 'Spacing',spacing, 'Padding',padding);
    uiControlsHandles.pluginGrid = pluginGrid;
    
    makePluginNamesCol(pluginGrid)
    makeLoadCol(pluginGrid)
    
    %% set layout sizes
    set(pluginGrid, 'Heights',pxHeight*ones(1, nPlugins), 'Widths',[-10,-1]);
    
    pluginPanelheight = (pxHeight+spacing)*nPlugins + padding*2;
    set(scrollingPanel, 'Heights',pluginPanelheight);
    
    set(pluginVbox, 'Heights',[fontHeight*2, -1]);
  end


  function makePluginGridTitles(parentHandle)
    titleFontWeight = 'bold';
    
    pluginGridTitlesHbox = uix.HBox('Parent',parentHandle, 'Padding', padding);
    
    % pluginNameTitle
    thisTag = pluginObj.panelTag('pluginNameTitle');
    uiControlsHandles.pluginNameTitle = uicontrol(...
      'Tag',thisTag,...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'FontWeight',titleFontWeight,...
      'String','Plugins',...
      'Value',get(0,'defaultuicontrolValue'),...
      'Parent',pluginGridTitlesHbox);
    
    % loadPluginTitle
    thisTag = pluginObj.panelTag('loadPluginTitle');
    uiControlsHandles.loadPluginTitle = uicontrol(...
      'Tag',thisTag,...
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
      
      thisTag = pluginObj.panelTag(['pluginText' nStr]);
      uiControlsHandles.(['pluginText' nStr]) = uicontrol(...
        'Tag',thisTag,...
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
      
      % loadCheckbox
      thisTag = pluginObj.panelTag(['loadCheckbox' nStr]);
      uiControlsHandles.(['pluginCheckbox' nStr]) = uicontrol(...
        'Tag',thisTag,...
        'Style','checkbox',...
        'Value',loadedBool,...
        'UserData',thisUserData,...
        'Callback',@gvMainWindowPlugin.Callback_loadPluginCheckbox,...
        'Parent',parentHandle);
    end
  end

end