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
  
%   properties (SetAccess = private) % read-only
%     windows = struct()
%   end
    
  %% Other Properties %%
  properties (Hidden, SetAccess = private)
    app
    model
    controller
  end
  
  properties (Access = private)
    listeners = {}
    
    % settings
    baseFontSize = 14 % points
  end
  
  properties (Hidden)
    nViewDimsLast = 0
    activeHypercube = [] % current gvArrayRef
    activeHypercubeName = []
  end
  
  
  %% Events %%
  events
    activeHypercubeSet
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
      
      fprintf('View Summary:\n')
      
      fprintf('    Active Hypercube:\n        %s\n', viewObj.activeHypercubeName)
      
      fprintf('    Loaded GUI Plugins:\n        %s\n', strjoin(fieldnames(viewObj.guiPlugins),'\n        ') )
      
      fprintf('    Loaded Window Plugins:\n        %s\n', strjoin(fieldnames(viewObj.windowPlugins),'\n        ') )
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
    
    
%     function addWindow(viewObj, pluginObj)
%       windowFieldName = getDefaultPropertyValue(pluginObj, 'windowFieldName');
% 
%       % add window to view
%       if isobject(pluginObj)
%         viewObj.windows.(windowFieldName) = pluginObj;
%       else
%         viewObj.windows.(windowFieldName) = feval(pluginObj);
%       end
%       
%       % add view to window
%       viewObj.windows.(windowFieldName).view = viewObj;
%       
%       notify(viewObj, 'windowAdded', gvEvent('windowFieldName',windowFieldName) );
%     end
%     
%     
%     function removeWindow(viewObj, windowFieldName)
%       viewObj.windows = rmfield(viewObj.windows, windowFieldName);
%       
%       notify(viewObj, 'windowRemoved', gvEvent('windowFieldName',windowFieldName) );
%     end
    
    
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
    end
    
    
    function value = fontSize(viewObj)
      value = viewObj.baseFontSize * viewObj.fontScale;
    end
    
    
    function value = nViewDims(viewObj)
      handleArray = [viewObj.windowPlugins.main.handles.dataPanel.viewCheckboxHandles{:}];
      value = sum([handleArray.Value]);
    end
    
    
    function value = nLockDims(viewObj)
      handleArray = [viewObj.windowPlugins.main.handles.dataPanel.lockCheckboxHandles{:}];
      value = sum([handleArray.Value]);
    end
    
    
    function pluginsOut = guiPlugins(viewObj)
      pluginsOut = viewObj.controller.guiPlugins;
    end
    
    function pluginsOut = windowPlugins(viewObj)
      pluginsOut = viewObj.controller.windowPlugins;
    end
    
    
    function newListener(viewObj, listener)
      viewObj.listeners{end+1} = listener;
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

    
    
  end % protected methods
  
end % classdef
