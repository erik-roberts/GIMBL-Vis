%% gvController - Controller class for the GIMBL-Vis Model-View-Controller
%
% Author: Erik Roberts

classdef gvController < handle
  
  %% Properties %%
  properties
    data = struct()
  end % public properties
  
  properties (Access = private)
    app
    model
    view
  end % private properties
  
  properties (SetAccess = protected) % read-only
    plugins = struct()
  end % read-only properties
  
  
  %% Public Methods %%
  methods
    
    function obj = gvController(gvObj)
      if exist('gvObj','var') && ~isempty(gvObj)
        obj.app = gvObj;
        obj.model = gvObj.model;
        obj.view = gvObj.view;
        
        loadDefaultPlugins(obj)
      end
    end
    
    
    function addPlugin(cntrlObj, pluginSrc)
      pluginFieldName = getDefaultPropertyValue(pluginSrc, 'pluginFieldName');

      % add plugin to view
      if isobject(pluginSrc)
        cntrlObj.plugins.(pluginFieldName) = pluginSrc;
      else
        cntrlObj.plugins.(pluginFieldName) = feval(pluginSrc);
      end
      
      % add view to plugin
      cntrlObj.plugins.(pluginFieldName).controller = cntrlObj;
      
      notify(cntrlObj, 'pluginAdded', gvEvent('pluginFieldName',pluginFieldName) );
    end
    
    
    function removePlugin(cntrlObj, pluginName)
      cntrlObj.plugins = rmfield(cntrlObj.plugins, pluginName);
      
      notify(cntrlObj, 'pluginRemoved', gvEvent('pluginFieldName',pluginName) );
    end
    
  end % public methods
  
  %% Other Methods %%
  methods (Access = protected)
    
    function loadDefaultPlugins(cntrlObj)
      pluginList = cntrlObj.app.defaultPlugins;
      
      for pluginStr = pluginList(:)'
        cntrlObj.addPlugin(pluginStr);
      end
    end
    
  end
  
end % classdef
