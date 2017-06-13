%% gvView - View class for the GIMBL-Vis Model-View-Controller
%
% Author: Erik Roberts

% Dev Notes:
%   Window objects are dynamically added
  
classdef gvView < handle
  
  %% Public Properties %%
  properties (SetObservable)
    % Settings
    fontScale = 1; % scale baseFont
  end % public properties
  
  properties (Dependent)
    activeHypercubeName
  end
  
  methods
    function value = get.activeHypercubeName(viewObj)
      value = viewObj.controller.activeHypercubeName;
    end
  end

  %% Other Properties %%
  properties (Hidden, SetAccess = private)
    app
    model
    controller
    
%     listeners = {}
  end
  
  properties (Hidden)
%     nViewDimsLast = 0
%     activeHypercube = [] % current gvArrayRef
%     activeHypercubeName = []
    
    baseFontSize
  end
  
  
  %% Events %%
  events
%     activeHypercubeSet
  end % events
  
  
  %% Public Methods %%
  methods
    
    function viewObj = gvView(gvObj)
      if exist('gvObj','var') && ~isempty(gvObj)
        viewObj.app = gvObj;
      end
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
    
    
    function value = ndims(viewObj)
      value = ndims(viewObj.activeHypercube);
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

  end % public methods
  
  %% Hidden Methods %%
  methods (Hidden)
    
    function setup(viewObj)
      viewObj.model = viewObj.app.model;
      viewObj.controller = viewObj.app.controller;
      
      viewObj.baseFontSize = viewObj.app.config.baseFontSize;
    end
    
    
    function value = fontSize(viewObj)
      value = viewObj.baseFontSize * viewObj.fontScale;
    end
    
    
    function obj = activeHypercube(viewObj)
      obj = viewObj.controller.activeHypercube;
    end
    
%     function value = nViewDims(viewObj)
%       handleArray = [viewObj.windowPlugins.main.handles.dataPanel.viewCheckboxHandles{:}];
%       value = sum([handleArray.Value]);
%     end
%     
%     
%     function value = nLockDims(viewObj)
%       handleArray = [viewObj.windowPlugins.main.handles.dataPanel.lockCheckboxHandles{:}];
%       value = sum([handleArray.Value]);
%     end
    
    
    function pluginsOut = guiPlugins(viewObj)
      pluginsOut = viewObj.controller.guiPlugins;
    end
    
    function pluginsOut = windowPlugins(viewObj)
      pluginsOut = viewObj.controller.windowPlugins;
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
    
  end
  
  %% Protected Methods %%
  methods (Access = protected)

    function vprintf(obj, varargin)
      obj.app.vprintf(varargin{:});
    end
    
  end % protected methods
  
end % classdef
