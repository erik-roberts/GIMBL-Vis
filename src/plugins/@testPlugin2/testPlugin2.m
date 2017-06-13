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
    pluginName = 'test'
    pluginFieldName = 'test'
  end
  
  methods
  end
  
  methods (Hidden)
    function makeControls(pluginObj, parentHandle)
      uix.Empty('Parent',parentHandle);
    end
  end
  
end

