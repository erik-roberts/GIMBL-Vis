function makeWindowControls( pluginObj, parentHandle )

uiControlsHandles = struct();

makeTabs();

pluginObj.handles.controls = uiControlsHandles;


%% Nested Fn
  function makeTabs()
    tabPanel = uitabgroup('Parent',parentHandle, 'Tag', [pluginObj.pluginFieldName '_window_' 'tabGroup']);
    uiControlsHandles.tabPanel = tabPanel;
    
    guiPlugins = pluginObj.controller.guiPlugins;
    guiPluginFlds = fieldnames(guiPlugins);
    guiPluginFlds = unique( [{guiPlugins.main.pluginFieldName}; guiPluginFlds] ); % set main to first plugin
    
    uiControlsHandles.tabs = {};
    for k = 1:length(guiPluginFlds)
      thisFld = guiPluginFlds{k};
      thisPlugin = guiPlugins.(thisFld);
      
      % get handle to uitab
      thisTag = [pluginObj.pluginFieldName '_window_tab_' thisPlugin.pluginName];
      thisUItab = uitab(tabPanel, 'title', thisPlugin.pluginName, 'Tag',thisTag);
      uiControlsHandles.tabs{k}.uitab = thisUItab;
      
      % get handle to uitab child
      uiControlsHandles.tabs{k}.controls = thisPlugin.makePanelControls(thisUItab);
    end

  end


  
end

