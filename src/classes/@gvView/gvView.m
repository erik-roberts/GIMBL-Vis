%% gvView - View class for the GIMBL-Vis Model-View-Controller
%
% Author: Erik Roberts
  
classdef gvView < handle
  
  properties
    data = struct()
    mainWindow = struct()
    plotWindow = struct()
    legendWindow = struct()
    imageWindow = struct()
    activeHypercube % current gvArrayRef
  end % public properties
  
  properties %(Access = private)
    app
    model
    controller
    listeners
  end % private properties
  
  events
  end % events
  
  %% Public Methods %%
  methods
    
    function viewObj = gvView(gvObj)
      if exist('gvObj','var') && ~isempty(gvObj)
        viewObj.app = gvObj;
        viewObj.model = gvObj.model;
        viewObj.controller = gvObj.model;
      end
      
      viewObj.setWindowHandlesEmpty();
    end
    
    function setWindowHandlesEmpty(viewObj)
      viewObj.mainWindow.windowHandle = [];
      viewObj.plotWindow.windowHandle = [];
      viewObj.legendWindow.windowHandle = [];
      viewObj.imageWindow.windowHandle = [];
    end

    
    %% Main Window
%     openMainWindow(viewObj)
    
    
    %% Plot Window
    openPlotWindow(viewObj)
    
    
    %% Legend Window
    openLegendWindow(viewObj)
    
    
    %% Image Window
    openImageWindow(viewObj)
    
  end % public methods
  
  %% Protected Methods %%
  methods (Access = protected)
    
    function existBool = checkMainWindowExists(viewObj)
      existBool = isValidFigHandle(viewObj.mainWindow.windowHandle);
      if ~existBool
        wprintf('Main window does not exist yet')
      end
    end
    
  end % protected methods
  
end % classdef