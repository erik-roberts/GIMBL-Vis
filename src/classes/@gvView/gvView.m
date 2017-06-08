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
  
  properties (SetAccess = protected) % read-only
    windows = struct()
  end
    
  %% Other Properties %%
  properties (Hidden, SetAccess = immutable)
    app
    model
    controller
  end
  
  properties (Access = protected)
    listeners = {}
    
    % settings
    baseFontSize = 14 % points
  end
  
  properties (Constant, Access = protected)
    defaultWindowClasses = {'gvMainWindow', 'gvPlotWindow'}; % TODO add the rest 
  end
  
  properties (Hidden)
    nViewDimsLast = 0
    activeHypercube = [] % current gvArrayRef
    activeHypercubeName = []
  end
  
  
  %% Events %%
  events
    activeHypercubeSet
    windowAdded
    windowRemoved
  end % events
  
  
  %% Public Methods %%
  methods
    
    function viewObj = gvView(gvObj)
      if exist('gvObj','var') && ~isempty(gvObj)
        viewObj.app = gvObj;
        viewObj.model = gvObj.model;
        viewObj.controller = gvObj.controller;
      end
      
      viewObj.addDefaultWindows();
    end
    
    
    function summary(viewObj)
      % summary - print view object summary
      %
      % See also: gv/summary, gvModel/summary, gvArray/summary
      
      fprintf('View Summary:\n')
      
      fprintf('    Active Hypercube:\n        %s\n', viewObj.activeHypercubeName)
      
      fprintf('    Loaded Windows:\n        %s\n', strjoin(fieldnames(viewObj.windows),'\n        ') )
    end
    
    
    function value = ndims(viewObj)
      value = ndims(viewObj.activeHypercube);
    end
    
    
    function setActiveHypercube(viewObj, argin)
      if isobject(argin)
        viewObj.activeHypercube = argin;
        viewObj.activeHypercubeName = argin.hypercubeName;
        
        notify(viewObj, 'activeHypercubeSet', gvEvent('activeHypercubeName',viewObj.activeHypercubeName) );
      elseif ischar(argin)
        viewObj.activeHypercubeName = argin;
        viewObj.activeHypercube = viewObj.model.data.(argin);
        
        notify(viewObj, 'activeHypercubeSet', gvEvent('activeHypercubeName',viewObj.activeHypercubeName) )
      else
        error('Unknown hypercube input')
      end
    end
    
    
    function addWindow(viewObj, windowObj)
      windowName = getDefaultPropertyValue(windowObj, 'windowName');

      % add window to view
      if isobject(windowObj)
        viewObj.windows.(windowName) = windowObj;
      else
        viewObj.windows.(windowName) = feval(windowObj);
      end
      
      % add view to window
      viewObj.windows.(windowName).viewObj = viewObj;
      
      notify(viewObj, 'windowAdded', gvEvent('windowName',windowName) );
    end
    
    
    function removeWindow(viewObj, windowName)
      viewObj.windows = rmfield(viewObj.windows, windowName);
      
      notify(viewObj, 'windowRemoved', gvEvent('windowName',windowName) );
    end
    
    
    function openWindow(viewObj, windowName)
      if isfield(viewObj.windows, windowName)
        viewObj.windows.(windowName).openWindow;
      else
        wprintf('Window "%s" is not found', windowName)
      end
    end

  end % public methods
  
  %% Hidden Methods %%
  methods (Hidden)
    
    function value = fontSize(viewObj)
      value = viewObj.baseFontSize * viewObj.fontScale;
    end
    
    function value = nViewDims(viewObj)
      handleArray = [viewObj.windows.mainWindow.handles.dataPanel.viewCheckboxHandles{:}];
      value = sum([handleArray.Value]);
    end
    
    
    function value = nLockDims(viewObj)
      handleArray = [viewObj.windows.mainWindow.handles.dataPanel.lockCheckboxHandles{:}];
      value = sum([handleArray.Value]);
    end
    
    
    function newListener(viewObj, listener)
      viewObj.listeners{end+1} = listener;
    end
    
    
    function existBool = checkMainWindowExists(viewObj, warnBool)
      if nargin < 2
        warnBool = false;
      end
      
      existBool = isValidFigHandle(viewObj.windows.mainWindow.handles.fig);
      if ~existBool && warnBool
        wprintf('Main window is not open\n')
      end
    end
    
  end
  
  %% Protected Methods %%
  methods (Access = protected)
    
    function addDefaultWindows(viewObj)
      for winName = viewObj.defaultWindowClasses(:)'
        viewObj.addWindow( winName{1} )
      end
    end
    
  end % protected methods
  
end % classdef
