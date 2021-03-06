%% gvController - Controller class for the GIMBL-Vis Model-View-Controller
%
% Author: Erik Roberts

classdef gvController < handle
  
  %% Public Properties %%
  properties
    metadata = struct()
    
    activeHypercube = [] % current gvArrayRef
    activeHypercubeName = ''
    prior_activeHypercubeName = ''
  end % public properties
  
  
  %% Read-only Properties %%
  properties (SetAccess = private) % read-only
    app
    model
    view
    
    listeners = {}
    
    plugins = struct()
  end
  
  
  %% Events %%
  events
    % model events
    modelChanged
    
    % controller events
    pluginAdded
    pluginRemoved
    
    % view events
    activeHypercubeChanged
    activeHypercubeNameChanged
    activeHypercubeAxisLabelChanged
    activeHypercubeSliceChanged
    nViewDimsChanged
    makeAxes
    doPlot
    mainWindowReset
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
    
    
    function setup(cntrlObj)
      cntrlObj.model = cntrlObj.app.model;
      cntrlObj.view = cntrlObj.app.view;
      
      cntrlObj.loadDefaultPlugins()
      
      cntrlObj.addDefaultListeners()
    end
    
    
    function newListener(obj, varargin)
      % newListener - call addlistener and add to listerners property
      
      obj.listeners{end+1} = addlistener(obj, varargin{:});
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

      cntrlObj.vprintf('[gvController] Plugin ''%s'' added.\n', pluginFieldName);
    end
    
    
    function connectPlugin(cntrlObj, pluginSrc)
      % connectPlugin - bidirectional add
      %
      % Inputs:
      %   pluginSrc: plugin class name string or pluginObj object
      
      pluginFieldName = getDefaultPropertyValue(pluginSrc, 'pluginFieldName');
      
      % add plugin to controller
      cntrlObj.addPlugin(pluginSrc);
      
      pluginClassName = cntrlObj.plugins.(pluginFieldName).pluginClassName;
      
      % add controller to plugin
      cntrlObj.plugins.(pluginFieldName).addController(cntrlObj);
      cntrlObj.plugins.(pluginFieldName).setup(cntrlObj);
      
      notify(cntrlObj, 'pluginAdded',...
        gvEvent('pluginFieldName',pluginFieldName, 'pluginClassName',pluginClassName) );
    end
    
    
    function removePlugin(cntrlObj, pluginFieldName)
      % removePlugin - unidirectional remove
      
      cntrlObj.plugins = rmfield(cntrlObj.plugins, pluginFieldName);
      
      cntrlObj.vprintf('[gvController] Plugin ''%s'' removed.\n', pluginFieldName);
    end
    
    
    function disconnectPlugin(cntrlObj, pluginFieldName)
      % disconnectPlugin - bidirectional remove
      
      pluginClassName = cntrlObj.plugins.(pluginFieldName).pluginClassName;
      
      % close window if open
      if isa(cntrlObj.plugins.(pluginFieldName), 'gvWindowPlugin')
        cntrlObj.plugins.(pluginFieldName).closeWindow();
      end
      
      % remove controller from plugin
      cntrlObj.plugins.(pluginFieldName).removeController();
      
      % remove plugin from controller
      removePlugin(cntrlObj, pluginFieldName);
      
      notify(cntrlObj, 'pluginRemoved',...
        gvEvent('pluginFieldName',pluginFieldName, 'pluginClassName',pluginClassName) );
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
    
    
    function setActiveHypercube(cntrlObj, argin)
      if nargin < 2
        flds = fieldnames(cntrlObj.model.data);
        
        if ~isempty(flds)
          firstHypercubeName = flds{1};

          cntrlObj.activeHypercube = cntrlObj.model.data.(firstHypercubeName);
          cntrlObj.activeHypercubeName = firstHypercubeName;
        else
          cntrlObj.activeHypercube = gvArray();
          cntrlObj.activeHypercubeName = '[None]';
        end
      elseif isobject(argin)
        cntrlObj.activeHypercube = argin;
        cntrlObj.activeHypercubeName = argin.hypercubeName;
      elseif ischar(argin)
        if strcmp(argin, '[None]')
          wprintf('Import data before selecting a hypercube.')
          return
        end
        
        cntrlObj.activeHypercubeName = argin;
        cntrlObj.activeHypercube = cntrlObj.model.data.(argin);
      else
        error('Unknown hypercube input')
      end
      
      if ~strcmp(cntrlObj.activeHypercubeName, cntrlObj.prior_activeHypercubeName)
        notify(cntrlObj, 'activeHypercubeChanged', gvEvent('activeHypercubeName', cntrlObj.activeHypercubeName) );
        cntrlObj.prior_activeHypercubeName = cntrlObj.activeHypercubeName;
      end
    end
    
    
    function saveActiveHypercube(cntrlObj, varargin)
      % saveActiveHypercube - save gvArray object to file as MDD object (default: 'gvHypercubeData.mat')
      %
      % See also: gvModel/saveHypercube
      
      modelObj = cntrlObj.model;
      
      modelObj.saveHypercube(cntrlObj.activeHypercubeName, varargin{:})
    end
    
    
    function deleteActiveHypercube(cntrlObj)
      % deleteActiveHypercube
      %
      % See also: gvModel/deleteHypercube
      
      modelObj = cntrlObj.model;
      
      flds = fieldnames(modelObj.data);
      flds(strcmp(flds, cntrlObj.activeHypercubeName)) = [];
      if ~isempty(flds)
        cntrlObj.setActiveHypercube(flds{1});
      end
      
      modelObj.deleteHypercube(cntrlObj.activeHypercubeName);
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
    
    
    function addDefaultListeners(cntrlObj)
      % model events
      cntrlObj.newListener('modelChanged', @gvController.Callback_modelChanged);
      
      % controller events
      cntrlObj.newListener('pluginAdded', @gvController.Callback_pluginChanged);
      cntrlObj.newListener('pluginRemoved', @gvController.Callback_pluginChanged);
      
      % view events
      cntrlObj.newListener('activeHypercubeChanged', @gvController.Callback_activeHypercubeChanged);
      cntrlObj.newListener('activeHypercubeNameChanged', @gvController.Callback_activeHypercubeNameChanged);
    end
    
  end
  
  %% Static Methods %%
  
  %% Callbacks
  methods (Static, Access = protected)
    
    function Callback_modelChanged(src, evnt)
      cntrlObj = src;
       
      % TODO: is this needed?
%       if ~isempty(cntrlObj.activeHypercubeName) && ~any(strcmp(fieldnames(cntrlObj.model.data), cntrlObj.activeHypercubeName))
%         cntrlObj.activeHypercubeName = [];
%         cntrlObj.activeHypercube = [];
%       end
      
      
      if strcmp(cntrlObj.activeHypercubeName, '[None]')
        hypercubeNames = fieldnames(cntrlObj.model.data);
        if ~isempty(hypercubeNames)
          cntrlObj.setActiveHypercube(hypercubeNames{1});
        end
      end
      
      if cntrlObj.view.checkMainWindowExists()
        cntrlObj.plugins.main.openWindow(); % reopen window
      end
    end
    
    
    function Callback_pluginChanged(src, evnt)
      pluginClassName = evnt.data.pluginClassName;
      if isa(feval(pluginClassName), 'gvGuiPlugin')
        src.plugins.main.openWindow(); % reset window
      end
    end
    
    
    function Callback_activeHypercubeChanged(src, evnt)
      cntrlObj = src;
      new_activeHypercubeName = evnt.data.activeHypercubeName;
%       prior_activeHypercubeName = cntrlObj.prior_activeHypercubeName;
%       if ~strcmp(new_activeHypercubeName, prior_activeHypercubeName)
        cntrlObj.vprintf('[gvController] New active hypercube: %s\n',new_activeHypercubeName);
        
        % TODO: more precise change
        if cntrlObj.view.checkMainWindowExists()
          cntrlObj.plugins.main.openWindow(); % reopen window
        end
        
        notify(cntrlObj, 'doPlot'); % TODO remove this calback
%       end
    end
    
    
    function Callback_activeHypercubeNameChanged(src, evnt)
      cntrlObj = src;
      
      new_activeHypercubeName = evnt.data.activeHypercubeName;
      prior_activeHypercubeName = cntrlObj.prior_activeHypercubeName;
      if ~strcmp(new_activeHypercubeName, prior_activeHypercubeName)
        cntrlObj.vprintf('[gvController] New active hypercube Name: %s\n',new_activeHypercubeName);
        
        cntrlObj.activeHypercubeName = new_activeHypercubeName;
        cntrlObj.prior_activeHypercubeName = new_activeHypercubeName;
        cntrlObj.model.changeHypercubeName(prior_activeHypercubeName, new_activeHypercubeName);
        
        
        if cntrlObj.view.checkMainWindowExists()
          cntrlObj.plugins.main.openWindow(); % reopen window
        end
      end
    end
    
  end
  
end % classdef
