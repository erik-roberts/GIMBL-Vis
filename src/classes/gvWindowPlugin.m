%% gvWindow - Abstract UI Window Plugin Class for GIMBL-Vis
%
% Description: This abstract class provides a template interface for GIMBL-Vis 
%              window plugins

classdef (Abstract) gvWindowPlugin < gvGuiPlugin

  %% Abstract Properties %%
  properties (Abstract, Constant, Hidden)
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
      pluginObj.userData.pluginObj = pluginObj; % for use with figure/control objects
    end
    
  end

  
  methods (Hidden)
    
%     function addWindowToView(pluginObj, viewObj)
%       pluginObj.addWindow( pluginObj );
%     end
%     
%     
%     function removeWindowFromView(pluginObj)
%       pluginObj.view.removeWindow( pluginObj.windowFieldName );
%     end
    
  end
  

  methods (Static, Hidden)
    
    function resetWindowCallback(src, evnt)
      pluginObj = src.UserData.pluginObj;
      pluginObj.openWindow(); % reopen window
    end
    
  end
  
end
