%% gvController - Controller class for the GIMBL-Vis Model-View-Controller
%
% Author: Erik Roberts

classdef gvController < handle
  
  %% Public Properties %%
  properties
    metadata = struct()
  end % public properties
  
  properties (SetAccess = private) % read-only
    plugins = struct()
  end % read-only properties
  
  %% Hidden Properties %%
  properties (Hidden)
    activeHypercube = [] % current gvArrayRef
    activeHypercubeName = ''
    prior_activeHypercubeName = ''
  end
  
  properties (Hidden, SetAccess = private)
    app
    model
    view
    
    listeners
  end % private properties
  
  
  %% Events %%
  events
    % model events
    
    % controller events
    pluginAdded
    pluginRemoved
    
    % view events
    activeHypercubeSet
  end
  
  %% Public Methods %%
  methods
    
    function obj = gvController(gvObj)
      if exist('gvObj','var') && ~isempty(gvObj)
        obj.app = gvObj;
      end
    end
    
    
    function summary(cntrlObj)
    % summary - print ontroller object summary
      %
      % See also: gv/summary, gvModel/summary, gvView/summary,gvArray/summary
      
      fprintf('Controller Summary:\n')

      fprintf('    Loaded Plugins:\n        %s\n', strjoin(fieldnames(cntrlObj.plugins),'\n        ') )
    end
    
    
    function addPlugin(cntrlObj, pluginSrc)
      % addPlugin - unidirectional add
      %
      % Inputs:
      %   pluginSrc: pluginFieldName string or pluginObj object
      
      pluginFieldName = getDefaultPropertyValue(pluginSrc, 'pluginFieldName');
      
      % check if plugin exists already
      if isfield(cntrlObj.plugins, pluginFieldName)
        error('Plugin ''%s'' is already loaded', pluginFieldName)
      end

      % add plugin to controller
      if isobject(pluginSrc)
        cntrlObj.plugins.(pluginFieldName) = pluginSrc;
      else
        cntrlObj.plugins.(pluginFieldName) = feval(pluginSrc);
      end
      
      pluginClassName = cntrlObj.plugins.(pluginFieldName).pluginClassName;
            
      notify(cntrlObj, 'pluginAdded',...
        gvEvent('pluginFieldName',pluginFieldName, 'pluginClassName',pluginClassName) );
      
      cntrlObj.vprintf('Plugin ''%s'' added.\n', pluginFieldName);
    end
    
    
    function connectPlugin(cntrlObj, pluginSrc)
      % connectPlugin - bidirectional add
      %
      % Inputs:
      %   pluginSrc: plugin class name string or pluginObj object
      
      pluginFieldName = getDefaultPropertyValue(pluginSrc, 'pluginFieldName');
      
      % add plugin to controller
      cntrlObj.addPlugin(pluginSrc);
      
      % add controller to plugin
      cntrlObj.plugins.(pluginFieldName).addController(cntrlObj);
      cntrlObj.plugins.(pluginFieldName).setup(cntrlObj);
    end
    
    
    function removePlugin(cntrlObj, pluginFieldName)
      % removePlugin - unidirectional remove
      
      cntrlObj.vprintf('Plugin ''%s'' removed.\n', pluginFieldName);
      
      pluginClassName = cntrlObj.plugins.(pluginFieldName).pluginClassName;
      
      cntrlObj.plugins = rmfield(cntrlObj.plugins, pluginFieldName);
      
      notify(cntrlObj, 'pluginRemoved',...
        gvEvent('pluginFieldName',pluginFieldName, 'pluginClassName',pluginClassName) );
    end
    
    
    function disconnectPlugin(cntrlObj, pluginFieldName)
      % disconnectPlugin - bidirectional remove
      
      % remove controller from plugin
      cntrlObj.plugins.(pluginFieldName).removeController();
      
      % remove plugin from controller
      removePlugin(cntrlObj, pluginFieldName);
    end
    
  end % public methods
  
  %% Hidden Methods %%
  methods (Hidden)
    
    function setup(cntrlObj)
      cntrlObj.model = cntrlObj.app.model;
      cntrlObj.view = cntrlObj.app.view;
      
      cntrlObj.loadDefaultPlugins()
      
      cntrlObj.addDefaultListeners()
    end
    
    
    function addDefaultListeners(cntrlObj)
      % model events
      
      % controller events
      cntrlObj.newListener('pluginAdded', @gvController.pluginChangeCallback);
      cntrlObj.newListener('pluginRemoved', @gvController.pluginChangeCallback);
      
      % view events
      cntrlObj.newListener('activeHypercubeSet', @gvController.activeHypercubeChangeCallback);
    end
    
    
    function newListener(obj, varargin)
      % newListener - call addlistener and add to listerners property
      
      obj.listeners{end+1} = addlistener(obj, varargin{:});
    end
    
    
    function pluginsOut = guiPlugins(cntrlObj)
      pluginsOut = struct();
      for pluginName = fieldnames(cntrlObj.plugins)'
        pluginName = pluginName{1};
        plugin = cntrlObj.plugins.(pluginName);
        if isa(plugin, 'gvGuiPlugin')
          pluginsOut.(pluginName) = plugin;
        end
      end
    end
    
    
    function pluginsOut = windowPlugins(cntrlObj)
      pluginsOut = struct();
      for pluginName = fieldnames(cntrlObj.plugins)'
        pluginName = pluginName{1};
        plugin = cntrlObj.plugins.(pluginName);
        if isa(plugin, 'gvWindowPlugin')
          pluginsOut.(pluginName) = plugin;
        end
      end
    end
    
  end
  
  
  %% Protected Methods %%
  methods (Access = protected)
    
    function vprintf(obj, varargin)
      obj.app.vprintf(varargin{:});
    end
    
    
    function loadDefaultPlugins(cntrlObj)
      pluginList = cntrlObj.app.config.defaultPlugins;
      
      for pluginStr = pluginList(:)'
        cntrlObj.connectPlugin(pluginStr{1});
      end
    end
    
  end
  
  %% Static Methods %%
  
  %% Callbacks %%
  methods (Static, Access = protected)
    
    function pluginChangeCallback(src, evnt)
      pluginClassName = evnt.data.pluginClassName;
      if isa(feval(pluginClassName), 'gvGuiPlugin')
        src.plugins.main.openWindow(); % reset window
      end
    end
    
    function activeHypercubeChangeCallback(src, evnt)
      cntrlObj = src;
      new_activeHypercubeName = evnt.data.activeHypercubeName;
      prior_activeHypercubeName = cntrlObj.prior_activeHypercubeName;
      if ~strcmp(new_activeHypercubeName, prior_activeHypercubeName)
        cntrlObj.vprintf('New activeHypercube: %s\n',new_activeHypercubeName);
        
        if cntrlObj.view.checkMainWindowExists()
          cntrlObj.plugins.main.openWindow(); % reopen window
        end
      end
    end
    
  end
  
end % classdef
