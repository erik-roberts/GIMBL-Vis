%% gvWindow - Abstract UI Window Plugin Class for GIMBL-Vis
%
% Description: This abstract class provides a template interface for GIMBL-Vis 
%              window plugins

classdef (Abstract) gvWindowPlugin < gvGuiPlugin

  %% Abstract Properties %%
  properties (Abstract, Constant)
    windowName
  end
  
  
  %% Abstract Methods %%
  methods (Abstract)
     openWindow(pluginObj)
  end
  
  methods (Abstract, Access = protected)
    makeFig(pluginObj)
  end
  
  
  %% Concrete Methods %%
  methods
    
    function pluginObj = gvWindowPlugin(varargin)
      % superclass constructor
      pluginObj@gvGuiPlugin(varargin{:});
      
      % default values
      pluginObj.handles.fig = [];
    end
    
  end
  

  %% Static Methods %%
  methods (Static)
    
    function Callback_resetWindow(src, evnt)
      pluginObj = src.UserData.pluginObj;
      pluginObj.openWindow(); % reopen window
    end
    
  end
  
end
