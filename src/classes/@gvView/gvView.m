%% gvView - View class for the GIMBL-Vis Model-View-Controller
%
% Author: Erik Roberts
  
classdef gvView < handle & gvUI % gvUI adds GUI creation methods
  
  %% Public Properties %%
  properties
    % GUI data inherited from gvUI
    % For reference:
    %     mainWindow = struct()
        plotWindow = struct()
        legendWindow = struct()
        imageWindow = struct()
  end
  
  properties (SetObservable)
    % Settings
    activeHypercube % current gvArrayRef
    fontScale = 1; % scale baseFont
  end % public properties
    
  %% Private Properties %%
  properties % TODO (Access = private)
    app
    model
    controller
    listeners
    
    % settings
    baseFontSize = 14 % points
  end % private properties
  
  properties (Dependent) %TODO (Access = private)
    fontSize
  end
  
  
  %% Events %%
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
    
    function value = get.fontSize(viewObj)
      value = viewObj.baseFontSize * viewObj.fontScale;
    end
    
    function value = ndims(viewObj)
      value = ndims(viewObj.activeHypercube);
    end
    
    function setWindowHandlesEmpty(viewObj)
      viewObj.mainWindow.handle = [];
      viewObj.plotWindow.handle = [];
      viewObj.legendWindow.handle = [];
      viewObj.imageWindow.handle = [];
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
      existBool = isValidFigHandle(viewObj.mainWindow.handle);
      if ~existBool
        wprintf('Main window does not exist yet')
      end
    end
    
  end % protected methods
  
end % classdef
