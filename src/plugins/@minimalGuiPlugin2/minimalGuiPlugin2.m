classdef minimalGuiPlugin2 < gvGuiPlugin
  
  properties
    metadata
  end
  
  properties (Hidden)
    controller
    view
    
    handles
  end
  
  properties (Constant, Hidden)
    pluginName = 'MinimalGuiPlugin2'
    pluginFieldName = 'minimalGuiPlugin2'
  end
  
  methods
  end
  
  methods (Hidden)
    function out = makePanelControls(pluginObj, parentHandle)
      out = uix.Empty('Parent',parentHandle);
    end
  end
  
end

