classdef minimalPlugin < gvPlugin
  
  properties
    metadata
    
    handles
  end
  
  properties (Constant)
    pluginName = 'MinimalPlugin'
    pluginFieldName = 'minimalPlugin'
  end
  
  methods
    
    function out = makePanelControls(pluginObj, parentHandle)
      out = uix.Empty('Parent',parentHandle);
    end
    
  end
  
end

