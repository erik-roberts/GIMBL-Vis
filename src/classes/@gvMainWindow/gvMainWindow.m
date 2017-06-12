%% gvMainWindow - UI Main Window Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMB-Vis main window

classdef gvMainWindow < gvWindow
  
  %% Public properties %%
  properties
    metadata = struct()
    handles = struct()
    
    viewObj
  end
  
  
  %% Other properties %%
  properties (Constant, Hidden)
    windowName = 'Main';
    windowFieldName = 'mainWindow';
  end
  
  
  %% Public methods %%
  methods
    
    function windowObj = gvMainWindow(varargin)
      windowObj@gvWindow(varargin{:});
    end
    
    openWindow(viewObj)
    
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    function value = fontSize(windowObj)
      value = windowObj.viewObj.fontSize;
    end
    
    createFig(windowObj)
    
    createMenu(windowObj, parentHandle)
    
    dataPanelheight = createDataPanelControls(windowObj, parentHandle)
    
    createDataPanelTitles(windowObj, parentHandle)
    
    createHypercubePanelControls(windowObj, parentHandle)
    
    createImagePanelControls(windowObj, parentHandle)
    
    createPlotMarkerPanelControls(windowObj, parentHandle)
    
    createPlotPanelControls(windowObj, parentHandle)
    
  end
  
  %% Callbacks
  methods (Static) % TODO (Access = protected)
    
  end
  
end
