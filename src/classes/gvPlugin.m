%% gvPlugin - Abstract Plugin Class for GIMBL-Vis
%
% Description: This abstract class provides a template interface for GIMBL-Vis 
%              plugins

classdef (Abstract) gvPlugin < handle

  %% Abstract Properties %%
  properties (Abstract)
    metadata
  end
  
  properties (Abstract, Hidden)
    controller
  end
  
  properties (Abstract, Constant, Hidden)
    pluginName
    pluginFieldName
  end
  
  
  %% Abstract Methods %%
  methods (Abstract)
     
  end
  
  %% Concrete Methods %%
  methods
    
    function pluginObj = gvPlugin(cntrlObj)
      if nargin
        pluginObj.addPluginToController(cntrlObj);
      end
    end
    
  end
    
  methods (Hidden)
    
    function vprintf(pluginObj, str)
      pluginObj.cntrlObj.app.vprintf(str);
    end
    
    
    function addPluginToController(pluginObj, cntrlObj)
      cntrlObj.addPlugin( pluginObj );
    end
    
    
    function removePlugin(pluginObj)
      pluginObj.controller.removePlugin( pluginObj.pluginFieldName );
    end
    
  end
  
  %% Concrete Static Methods %%
  methods (Static, Hidden)
    
  end
  
end
