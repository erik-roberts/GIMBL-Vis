classdef testPlugin2 < gvGuiPlugin
  %TESTPLUGIN2
  
  properties
    metadata
  end
  
  properties (Hidden)
    controller
    view
    
    handles
  end
  
  properties (Constant, Hidden)
    pluginName = 'Test2'
    pluginFieldName = 'test2'
  end
  
  methods
  end
  
  methods (Hidden)
    function put = makePanelControls(pluginObj, parentHandle)
      out = uix.Empty('Parent',parentHandle);
    end
  end
  
end

