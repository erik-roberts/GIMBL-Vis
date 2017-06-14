classdef minimalGuiPlugin2 < gvGuiPlugin
  
  properties
    metadata

    
    handles
  end
  
  properties (Constant)
    pluginName = 'MinimalGuiPlugin2'
    pluginFieldName = 'minimalGuiPlugin2'
  end
  
  methods
    
    function out = makePanelControls(pluginObj, parentHandle)
      out = uix.Empty('Parent',parentHandle);
    end
    
  end
  
end

