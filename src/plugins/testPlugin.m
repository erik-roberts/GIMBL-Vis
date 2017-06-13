classdef testPlugin < gvGuiPlugin
  %TESTPLUGIN
  
  properties
    metadata
  end
  
  properties (Hidden)
    controller
    view
    
    handles
  end
  
  properties (Constant, Hidden)
    pluginName = 'Test'
    pluginFieldName = 'test'
  end
  
  methods
  end
  
  methods (Hidden)
    function out = makePanelControls(pluginObj, parentHandle)
      out = uix.Empty('Parent',parentHandle);
    end
  end
  
end

