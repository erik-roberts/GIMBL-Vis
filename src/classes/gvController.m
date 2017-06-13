%% gvController - Controller class for the GIMBL-Vis Model-View-Controller
%
% Author: Erik Roberts

classdef gvController < handle
  
  %% Properties %%
  properties
    data = struct()
  end % public properties
  
  properties (Hidden, SetAccess = private)
    app
    model
    view
  end % private properties
  
  properties (SetAccess = private) % read-only
    plugins = struct()
  end % read-only properties
  
  %% Events %%
  events
    pluginAdded
    pluginRemoved
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
            
      notify(cntrlObj, 'pluginAdded', gvEvent('pluginFieldName',pluginFieldName) );
    end
    
    
    function connectPlugin(cntrlObj, pluginSrc)
      % connectPlugin - bidirectional add
      %
      % Inputs:
      %   pluginSrc: pluginFieldName string or pluginObj object
      
      pluginFieldName = getDefaultPropertyValue(pluginSrc, 'pluginFieldName');
      
      % add plugin to controller
      cntrlObj.addPlugin(pluginSrc);
      
      % add controller to plugin
      cntrlObj.plugins.(pluginFieldName).addController(cntrlObj);
      cntrlObj.plugins.(pluginFieldName).setup(cntrlObj);
    end
    
    
    function removePlugin(cntrlObj, pluginFieldName)
      % removePlugin - unidirectional remove
      
      cntrlObj.plugins = rmfield(cntrlObj.plugins, pluginFieldName);
      
      notify(cntrlObj, 'pluginRemoved', gvEvent('pluginFieldName',pluginFieldName) );
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
      
      loadDefaultPlugins(cntrlObj)
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
    
    function loadDefaultPlugins(cntrlObj)
      pluginList = cntrlObj.app.config.defaultPlugins;
      
      for pluginStr = pluginList(:)'
        cntrlObj.connectPlugin(pluginStr{1});
      end
    end
    
  end
  
end % classdef
