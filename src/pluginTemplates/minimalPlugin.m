classdef minimalPlugin < gvPlugin
  
  %% Public properties %%
  properties (Constant)
    pluginName = 'MinimalPlugin'
    pluginFieldName = 'minimalPlugin'
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

