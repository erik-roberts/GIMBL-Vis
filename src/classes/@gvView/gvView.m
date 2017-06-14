%% gvView - View class for the GIMBL-Vis Model-View-Controller
%
% Author: Erik Roberts

% Dev Notes:
%   Window objects are dynamically added
  
classdef gvView < handle
  
  %% Public Properties %%
  properties (SetObservable)
    fontSize
  end % public properties
  
  
  %% Dependent Properties %%
  properties (Dependent)
    activeHypercube
    activeHypercubeName
    
    guiPlugins
    windowPlugins
  end
  
  methods
    
    function value = get.activeHypercube(viewObj)
      value = viewObj.controller.activeHypercube;
    end
    
    function value = get.activeHypercubeName(viewObj)
      value = viewObj.controller.activeHypercubeName;
    end   
    
    function pluginsOut = get.guiPlugins(viewObj)
      pluginsOut = viewObj.controller.guiPlugins;
    end
    
    function pluginsOut = get.windowPlugins(viewObj)
      pluginsOut = viewObj.controller.windowPlugins;
    end
    
    
  end

  
  %% Read-only Properties %%
  properties (SetAccess = private)
    app
    model
    controller
    
    fontHeight
    fontWidth
  end
  
  
  %% Public Methods %%
  methods
    
    function viewObj = gvView(gvObj)
      if exist('gvObj','var') && ~isempty(gvObj)
        viewObj.app = gvObj;
      end
      
      addlistener(viewObj,'fontSize','PostSet',@gvView.Callback_fontSize);
    end
    
    
    function run(viewObj)
      viewObj.windowPlugins.main.openWindow();
    end
    
    
    function summary(viewObj)
      % summary - print view object summary
      %
      % See also: gv/summary, gvModel/summary, gvArray/summary
      
      fprintf('View Summary:\n');
      
      fprintf('    Active Hypercube:\n        %s\n', viewObj.activeHypercubeName);
      
      fprintf('    Loaded GUI Plugins:\n        %s\n', strjoin(fieldnames(viewObj.guiPlugins),'\n        ') );
      
      fprintf('    Loaded Window Plugins:\n        %s\n', strjoin(fieldnames(viewObj.windowPlugins),'\n        ') );
    end
    
    
    function setActiveHypercube(viewObj, argin)
      if isobject(argin)
        viewObj.controller.activeHypercube = argin;
        viewObj.controller.activeHypercubeName = argin.hypercubeName;
        
        notify(viewObj.controller, 'activeHypercubeSet', gvEvent('activeHypercubeName',viewObj.activeHypercubeName) );
        
        viewObj.controller.prior_activeHypercubeName = viewObj.controller.activeHypercubeName;
      elseif ischar(argin)
        if strcmp(argin, '[None]')
          wprintf('Import data before selecting a hypercube.')
          return
        end
        
        viewObj.controller.activeHypercubeName = argin;
        viewObj.controller.activeHypercube = viewObj.model.data.(argin);
        
        notify(viewObj.controller, 'activeHypercubeSet', gvEvent('activeHypercubeName',viewObj.activeHypercubeName) );
        
        viewObj.controller.prior_activeHypercubeName = viewObj.controller.activeHypercubeName;
      else
        error('Unknown hypercube input')
      end
    end
    

    function openWindow(viewObj, windowFieldName)
      if isfield(viewObj.windows, windowFieldName)
        viewObj.windowPlugins.(windowFieldName).openWindow;
      else
        wprintf('Window "%s" is not found', windowFieldName)
      end
    end

    
    function setup(viewObj)
      viewObj.model = viewObj.app.model;
      viewObj.controller = viewObj.app.controller;
      
      viewObj.fontSize = viewObj.app.config.baseFontSize;
    end
    
    
    function updateFontWidthHeight(viewObj)
      [viewObj.fontWidth, viewObj.fontHeight] = getFontSizeInPixels(viewObj.fontSize);
    end

    
    function existBool = checkMainWindowExists(viewObj, warnBool)
      if nargin < 2
        warnBool = false;
      end
      
      existBool = isValidFigHandle(viewObj.windowPlugins.main.handles.fig);
      if ~existBool && warnBool
        wprintf('Main window is not open\n')
      end
    end
    
    
    function vprintf(obj, varargin)
      obj.app.vprintf(varargin{:});
    end
    
  end
  
  
  %% Protected Methods %%
  methods (Access = protected)
    
  end % protected methods
  
  methods (Static)
    
    function Callback_fontSize(src, evnt)
      viewObj = evnt.AffectedObject;
      viewObj.updateFontWidthHeight;
    end
    
  end
  
end % classdef
