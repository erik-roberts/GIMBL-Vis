%% gvPlugin - Abstract Plugin Class for GIMBL-Vis
%
% Description: This abstract class provides a template interface for GIMBL-Vis 
%              plugins

classdef (Abstract) gvPlugin < handle

  %% Abstract Properties %%
  properties (Abstract)
    metadata 
  end
  
  properties (Abstract, Constant)
    pluginName
    pluginFieldName
  end
  
  
  %% Concrete Properties %%
  properties
    pluginClassName
    
    pluginType = []
  end
  
  properties (SetAccess = protected)
    controller
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
    
    
    function setup(pluginObj, cntrObj)
      pluginObj.addController(cntrObj);
    end
    
    
    function vprintf(pluginObj, str)
      pluginObj.controller.app.vprintf(str);
    end
    
    
    function addController(pluginObj, cntrlObj)
      % uni add
      %
      % use connectToController for bi
      
      pluginObj.controller = cntrlObj;
    end
    
    
    function connectToController(pluginObj, cntrlObj)
      % See also: gvController/connectPlugin
      
      pluginObj.addController(cntrlObj);
      cntrlObj.addPlugin( pluginObj );
    end
    
    
    function removeController(pluginObj)
      % uni remove
      %
      % use disconnect for bi
      
      pluginObj.controller = [];
    end
    
    
    function disconnectFromController(pluginObj)
      % See also: gvController/disconnectPlugin
      
      pluginObj.controller.removePlugin( pluginObj.pluginFieldName );
      pluginObj.removeController();
    end
    
  end
  
  %% Concrete Static Methods %%
  methods (Static)
    
  end
  
end
