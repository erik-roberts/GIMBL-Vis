%% gvWindow - Abstract UI Window Class for GIMBL-Vis
%
% Description: This abstract class provides a template interface for GIMBL-Vis 
%              window plugins

classdef (Abstract) gvWindow < handle

  %% Abstract Properties %%
  properties (Abstract)
    metadata
  end
  
  properties (Abstract, Hidden)
    view
    handles
  end
  
  properties (Abstract, Constant, Hidden)
    windowName
    windowFieldName
  end
  
  properties (Access = protected)
    userData = struct()
  end
  
  %% Abstract Methods %%
  methods (Abstract)
     openWindow(windowObj)
  end
  
  %% Concrete Methods %%
  methods
    
    function windowObj = gvWindow(viewObj)
      windowObj.handles.fig = [];
      
      windowObj.userData.windowObj = windowObj; % for use with figure/control objects
      
      if nargin
        windowObj.addWindowToView(viewObj);
      end
    end
    
  end
    
  methods (Hidden)
    
    function vprintf(windowObj, str)
      windowObj.viewObj.app.vprintf(str);
    end
    
    
    function addWindowToView(windowObj, viewObj)
      viewObj.addWindow( windowObj );
    end
    
    
    function removeWindowFromView(windowObj)
      windowObj.viewObj.removeWindow( windowObj.windowFieldName );
    end
    
  end
  
  %% Concrete Static Methods %%
  methods (Static, Hidden)
    
    function resetWindowCallback(src, evnt)
      windowObj = src.UserData.windowObj;
      windowObj.openWindow(); % reopen window
    end
    
  end
  
end
