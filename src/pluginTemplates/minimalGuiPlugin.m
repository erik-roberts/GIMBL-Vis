classdef minimalGuiPlugin < gvGuiPlugin
  
  %% Public properties %%
  properties (Constant)
    pluginName = 'MinimalGuiPlugin'
    pluginFieldName = 'minimalGuiPlugin'
  end
  
  properties
    metadata
    
    handles
  end
  
  %% Public methods %%
  methods
    
    function out = makePanelControls(pluginObj, parentHandle)
      out = uix.Empty('Parent',parentHandle);
    end
    
  end
  
end