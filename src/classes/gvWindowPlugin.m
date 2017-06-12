%% gvWindow - Abstract UI Window Plugin Class for GIMBL-Vis
%
% Description: This abstract class provides a template interface for GIMBL-Vis 
%              window plugins

classdef (Abstract) gvWindowPlugin < gvGuiPlugin

  %% Abstract Properties %%
  properties (Abstract, Constant, Hidden)
    windowName
    windowFieldName
  end
  
  properties (Access = private)
    userData = struct()
  end
  
  %% Abstract Methods %%
  methods (Abstract)
     openWindow(windowObj)
  end
  
  %% Concrete Methods %%
  methods
    
    function pluginObj = gvWindowPlugin(cntrlObj)
      % superclass constructor
      pluginObj@gvGuiPlugin(cntrlObj);
      
      % default values
      pluginObj.handles.fig = [];
      pluginObj.userData.pluginObj = pluginObj; % for use with figure/control objects
    end
    
  end
    
  methods (Hidden)
    
%     function addWindowToView(windowObj, viewObj)
%       viewObj.addWindow( windowObj );
%     end
%     
%     
%     function removeWindowFromView(windowObj)
%       windowObj.viewObj.removeWindow( windowObj.windowFieldName );
%     end
    
  end
  
  %% Concrete Static Methods %%
  methods (Static, Hidden)
    
    function resetWindowCallback(src, evnt)
      pluginObj = src.UserData.pluginObj;
      pluginObj.openWindow(); % reopen window
    end
    
  end
  
end
