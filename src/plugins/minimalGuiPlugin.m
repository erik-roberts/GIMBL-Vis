classdef minimalGuiPlugin < gvGuiPlugin
  
  properties
    metadata

    handles
  end
  
  properties (Constant)
    pluginName = 'MinimalGuiPlugin'
    pluginFieldName = 'minimalGuiPlugin'
  end
  
  methods

    function out = makePanelControls(pluginObj, parentHandle)
      out = uix.Empty('Parent',parentHandle);
    end
    
  end
  
end

