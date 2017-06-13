classdef minimalGuiPlugin < gvGuiPlugin
  
  properties
    metadata
  end
  
  properties (Hidden)
    controller
    view
    
    handles
  end
  
  properties (Constant, Hidden)
    pluginName = 'MinimalGuiPlugin'
    pluginFieldName = 'minimalGuiPlugin'
  end
  
  methods
  end
  
  methods (Hidden)
    function out = makePanelControls(pluginObj, parentHandle)
      out = uix.Empty('Parent',parentHandle);
    end
  end
  
end

