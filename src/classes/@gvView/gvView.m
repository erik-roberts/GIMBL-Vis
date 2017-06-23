%% gvView - View class for the GIMBL-Vis Model-View-Controller
%
% Author: Erik Roberts

% Dev Notes:
%   Window objects are dynamically added
  
classdef gvView < handle
  
  %% Public Properties %%
  properties
    dynamic = struct() % dynamic properties
  end
  
  properties (SetObservable)
    fontSize
  end % public properties
  
  
  %% Dependent Properties %%
  properties (Dependent)
    activeHypercube
    activeHypercubeName
    
    guiPlugins
    windowPlugins
    
    main
    gui
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
    
    function value = get.main(viewObj)
      value = viewObj.windowPlugins.main;
    end
    
    function value = get.gui(viewObj)
      value = viewObj.windowPlugins.main;
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
    end
    
    
    function run(viewObj)
      viewObj.controller.setActiveHypercube();
      
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
    

    function openWindow(viewObj, windowFieldName)
      if isfield(viewObj.windows, windowFieldName)
        viewObj.windowPlugins.(windowFieldName).openWindow;
      else
        wprintf('Window "%s" is not found', windowFieldName)
      end
    end
    
    
    function setup(viewObj)
      % MVC
      viewObj.model = viewObj.app.model;
      viewObj.controller = viewObj.app.controller;
      
      % Fonts
      viewObj.fontSize = viewObj.app.config.baseFontSize;
      viewObj.updateFontWidthHeight;
      addlistener(viewObj,'fontSize','PostSet',@gvView.Callback_fontSize);
    end
    
    
    function updateFontWidthHeight(viewObj)
      [viewObj.fontWidth, viewObj.fontHeight] = getFontSizeInPixels(viewObj.fontSize);
    end

    
    function existBool = checkMainWindowExists(viewObj, warnBool)
      if nargin < 2
        warnBool = false;
      end
      
      existBool = viewObj.windowPlugins.main.checkWindowExists();
      if ~existBool && warnBool
        wprintf('Main window is not open\n')
      end
    end
    
    
    function resetWindows(viewObj)
      windows = viewObj.windowPlugins;
      
      for win = fieldnames(windows)'
        winExistBool = viewObj.windowPlugins.(win{1}).checkWindowExists();
        
        if winExistBool
          viewObj.windowPlugins.(win{1}).openWindow();
        end
      end
    end
    
    
    function closeWindows(viewObj)
      windows = viewObj.windowPlugins;
      
      viewObj.vprintf('Closing All GIMBL-Vis Windows\n')
      
      for win = fieldnames(windows)'
          viewObj.windowPlugins.(win{1}).closeWindow();
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
      
      viewObj.resetWindows;
    end
    
  end
  
end % classdef
