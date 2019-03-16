function makeWindowControls( pluginObj, parentHandle )

uiControlsHandles = struct();

makeTabs();

pluginObj.handles.controls = uiControlsHandles;


%% Nested Fn
  function makeTabs()
    tabPanel = uitabgroup('Parent',parentHandle, 'Tag', pluginObj.windowTag('tabGroup'));
    uiControlsHandles.tabPanel = tabPanel;
    
    guiPlugins = pluginObj.controller.guiPlugins;
    guiPluginFlds = fieldnames(guiPlugins);
    guiPluginFlds = unique( [{guiPlugins.main.pluginFieldName}; unique(guiPluginFlds)], 'stable' ); % set main to first plugin
    
    uiControlsHandles.tabs = {};
    for k = 1:length(guiPluginFlds)
      thisFld = guiPluginFlds{k};
      thisPlugin = guiPlugins.(thisFld);
      
      % get handle to uitab
      thisTag = pluginObj.windowTag(['tab_' thisPlugin.pluginName]);
      thisUItab = uitab(tabPanel, 'title', thisPlugin.pluginName, 'Tag',thisTag,...
        'UserData',struct('plugin',thisPlugin));
      uiControlsHandles.tabs{k}.uitab = thisUItab;
      
      % get handle to uitab child
      uiControlsHandles.tabs{k}.controls = thisPlugin.makePanelControls(thisUItab);
      
      % store handle
      pluginObj.metadata.tabs.pluginName2tabHandle.(thisPlugin.pluginName) = thisUItab;
      pluginObj.metadata.tabs.pluginClassName2tabHandle.(thisPlugin.pluginClassName) = thisUItab;
    end

  end


  
end
