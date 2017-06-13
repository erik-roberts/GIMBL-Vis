%% gvGuiPlugin - Abstract GUI Plugin Class for GIMBL-Vis
%
% Description: This abstract class provides a template interface for GIMBL-Vis 
%              gui plugins

classdef (Abstract) gvGuiPlugin < gvPlugin

  %% Abstract Properties %%
  properties (Abstract, Hidden)
    view
    
    handles
  end
  
  properties (Access = protected)
    userData = struct()
  end
  
  
  %% Concrete Methods %%
  methods
    
    function pluginObj = gvGuiPlugin(varargin)
      pluginObj@gvPlugin(varargin{:});
      
      pluginObj.userData.pluginObj = pluginObj;
    end
    
  end
  
  methods (Hidden)
    
    function setup(pluginObj, cntrObj)
      % overload setup to add view
      
      pluginObj.addController(cntrObj);
      
      pluginObj.view = pluginObj.controller.view;
    end
    
    function value = fontSize(pluginObj)
      value = pluginObj.view.fontSize;
    end
    
  end
  
  %% Abstract Methods %%
  methods (Abstract, Hidden)
    panelHandle = makePanelControls(pluginObj, parentHandle)
  end
  
end
