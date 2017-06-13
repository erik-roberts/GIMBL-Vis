%% gvMainWindowPlugin - UI Main Window Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis main window

classdef gvMainWindowPlugin < gvWindowPlugin
  
  %% Public properties %%
  properties
    metadata = struct()
    handles = struct()
  end
  
  
  %% Other properties %%
  properties (Hidden)
    controller
    view
  end
  
  properties (Constant, Hidden)
    pluginName = 'Main';
    pluginFieldName = 'main';
    
    windowName = 'GIMBL-Vis Toolbox';
  end
  
  
  %% Public methods %%
  methods
    
    function pluginObj = gvMainWindowPlugin(varargin)
      pluginObj@gvWindowPlugin(varargin{:});
    end
    
    openWindow(pluginObj)
    
  end
  
  
  %% Hidden methods %%
  methods (Hidden)
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
    makeWindowControls(pluginObj, parentHandle)
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
     
    makeFig(pluginObj)
    
    makeMenu(pluginObj, parentHandle)
    
    makeHypercubePanelControls(pluginObj, parentHandle)

  end
  
  %% Callbacks
  methods (Static) % TODO (Access = protected)
    
  end
  
end
