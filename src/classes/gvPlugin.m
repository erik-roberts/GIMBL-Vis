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
  
  %% Concrete Properties %%
  properties
    pluginClassName
  end
  
  
  %% Abstract Methods %%
  methods (Abstract)
     
  end
  
  %% Concrete Methods %%
  methods
    
    function pluginObj = gvPlugin(cntrObj)
      pluginObj.pluginClassName = class(pluginObj);
      
      if nargin
        setup(pluginObj, cntrObj);
      end
    end
    
  end
    
  methods (Hidden)
    
    function setup(pluginObj, cntrObj)
      pluginObj.addController(cntrObj);
    end
    
    
    function vprintf(pluginObj, str)
      pluginObj.controller.app.vprintf(str);
    end
    
    
    function addController(pluginObj, cntrlObj)
      pluginObj.controller = cntrlObj;
    end
    
    
    function connectToController(pluginObj, cntrlObj)
      pluginObj.addController(cntrlObj);
      cntrlObj.addPlugin( pluginObj );
    end
    
    
    function removeController(pluginObj)
      pluginObj.controller = [];
    end
    
    
    function disconnect(pluginObj)
      pluginObj.controller.removePlugin( pluginObj.pluginFieldName );
      pluginObj.removeController();
    end
    
  end
  
  %% Concrete Static Methods %%
  methods (Static, Hidden)
    
  end
  
end
