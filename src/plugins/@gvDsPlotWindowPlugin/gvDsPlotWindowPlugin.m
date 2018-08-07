%% gvDsPlotWindowPlugin - DynaSim Plot Window Plugin Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis DynaSim Plot window.

% dev notes: 
% click button to load data
% plot function
% plot function options

classdef gvDsPlotWindowPlugin < gvWindowPlugin

  %% Public properties %%
  properties
    metadata = struct()
    
    handles = struct()
  end
  
  
  properties (Constant)
    pluginName = 'DsPlot';
    pluginFieldName = 'dsPlot';
    
    windowName = 'DS Plot Window';
    
    importModes = {'manual', 'auto', 'withPlot', 'tempWithPlot'};
  end
  
  %% Protected properties %%
  properties (Access = protected)
    lastIndex = -1;
    fig2copy = [];
  end
  
  %% Events %%
  events
    stackEntryEdited
    newStackVal
  end
  
  %% Public methods %%
  methods
    
    function pluginObj = gvDsPlotWindowPlugin(varargin)
      pluginObj@gvWindowPlugin(varargin{:});
    end
    
    
    function setup(pluginObj, cntrlObj)
      setup@gvWindowPlugin(pluginObj, cntrlObj);
      
      % pluginObj.metadata.stack
      if isfield(pluginObj.controller.app.config, 'defaultDsPlotStack')
        pluginObj.metadata.stack = pluginObj.controller.app.config.defaultDsPlotStack;
      else
        wprintf('Set defaultDsPlotStack in gvConfig.txt')
        pluginObj.metadata.stack = {};
      end
      
      % pluginObj.metadata.importMode
      if isfield(pluginObj.controller.app.config, 'defaultDsPlotImportMode')
        pluginObj.metadata.importMode = pluginObj.controller.app.config.defaultDsPlotImportMode;
      else
        wprintf('Set defaultDsPlotImportMode in gvConfig.txt')
        pluginObj.metadata.importMode = '';
      end
      
      pluginObj.addWindowOpenedListenerToPlotPlugin();
      
      pluginObj.initializeControlsDynamicVars();
      
      % Event listeners
      addlistener(pluginObj, 'stackEntryEdited', @gvDsPlotWindowPlugin.Callback_stackEntryEdited);
      addlistener(pluginObj, 'newStackVal', @gvDsPlotWindowPlugin.Callback_newStackVal);
    end

    
    openWindow(pluginObj)
    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
    plotData(pluginObj, index)
    
    
    function str = stackStr(pluginObj)
      % return cellstr of stack tags

      % stack var length
      nStack = size(pluginObj.metadata.stack, 1);
      
      % update string
      if nStack == 0
        str = {' [ Empty ]'};
      else
        % tags stored in first col
        str = pluginObj.metadata.stack(:,1);
        
        % fill empty label cells with contents
        emptyCells = cellfun(@isempty, str);
        if any(emptyCells)
          eCells = find(emptyCells);
          for iCell = eCells(:)'
            str{iCell} = [strrep(pluginObj.metadata.stack{iCell, 2}, '@', ''), '(' pluginObj.metadata.stack{iCell, 3} ')'];
          end
        end
      end
    end
    
    
    function pushStack(pluginObj, fnTagStr, fnStr, fnOptStr)
      % add current fn and opts to stack
      
      % add to stack
      pluginObj.metadata.stack(end+1, :) = {fnTagStr, fnStr, fnOptStr};
      
      % update stackMenu string
      pluginObj.updateStackMenu();
    end
    
    
    function popStack(pluginObj)
      % remove current item from stack
      
      % get current stack val
      currVal = pluginObj.view.dynamic.dsPlotStackVal;
      
      % stack var length
      nStack = size(pluginObj.metadata.stack, 1);
      
      if nStack > 0
        % remove stack val
        pluginObj.metadata.stack(currVal, :) = [];
        
        % update stackMenu string
        pluginObj.updateStackMenu();
        
        if nStack > 1
          notify(pluginObj, 'newStackVal');
        end
      end
    end
    
    
    function updateStackMenu(pluginObj)
      % update stack menu
      
      % get stackMenu
      stackMenu = findobjReTag('dsPlot_panel_stackMenu');
      
      % get current stack val
      currVal = pluginObj.view.dynamic.dsPlotStackVal;
      
      % stack var length
      nStack = size(pluginObj.metadata.stack, 1);
      
      % check curr value
      if nStack == 0
        pluginObj.view.dynamic.dsPlotStackVal = 1;
      elseif nStack < currVal
        pluginObj.view.dynamic.dsPlotStackVal = nStack;
        
        stackMenu.Value = nStack;
        
        notify(pluginObj, 'newStackVal');
      end
      
      % update string
      stackMenu.String = pluginObj.stackStr();
    end

  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    function initializeControlsDynamicVars(pluginObj)
      
      % stack
      pluginObj.view.dynamic.dsPlotStackVal = 1;
      
      % mode
      importModeStr = pluginObj.metadata.importMode;
      if isempty(importModeStr)
        pluginObj.view.dynamic.dsPlotModeVal = 1;
      else
        pluginObj.view.dynamic.dsPlotModeVal = find(strcmp(importModeStr, pluginObj.importModes));
      end
      
    end
    
    
    function status = makeFig(pluginObj)
      % makeFig - make dsPlot window figure
      
      if ~isValidFigHandle(pluginObj.controller.plugins.plot.handles.fig)
        wprintf('Plot Window must be open to open dsPlot Window.');
        status = 1;
        return
      end
      
      plotPanPos = pluginObj.controller.plugins.plot.handles.fig.Position;
      newPos = plotPanPos; % same size as plot window
      newPos(2) = newPos(2)-newPos(4)-100; % move down
      %       newPos(3:4) = newPos(3:4)*.8; %shrink
      dsPlotWindowHandle = figure(...
        'Name',['GIMBL-VIS: ' pluginObj.windowName],...
        'Tag',pluginObj.figTag(),...
        'NumberTitle','off',...
        'Position',newPos,...
        'color','white');
      
%       makeBlankAxes(dsPlotWindowHandle);
      
      % set window handle
      pluginObj.handles.fig = dsPlotWindowHandle;
      
      status = 0;
    end
    
    
    function addWindowOpenedListenerToPlotPlugin(pluginObj)
      if isfield(pluginObj.controller.windowPlugins, 'plot')
        if isfield(pluginObj.metadata, 'plotWindowListener')
          delete(pluginObj.metadata.plotWindowListener)
        end
        
        pluginObj.metadata.plotWindowListener = addlistener(pluginObj.controller.windowPlugins.plot, 'windowOpened', @gvDsPlotWindowPlugin.Callback_plotWindowOpened);
        
        pluginObj.vprintf('[gvDsPlotWindowPlugin] Added window opened listener to plot plugin.\n');
      end
    end
    
    
    function addMouseButtonCallbackToPlotFig(pluginObj)
      if isfield(pluginObj.controller.windowPlugins, 'plot')
        plotPluginObj = pluginObj.controller.windowPlugins.plot;

        plotPluginObj.WindowButtonDownFcns.dsPlot = @gvDsPlotWindowPlugin.Callback_ImageWindowMousePress;
        
        pluginObj.vprintf('[gvDsPlotWindowPlugin] Added WindowButtonDownFcn callback to plot plugin figure.\n');
      end
    end
    
  end
  
  %% Static %%
  methods (Static, Hidden)
    
    function str = helpStr()
      str = [gvDsPlotWindowPlugin.pluginName ':\n',...
        'Use the Select tab or mouse over a Plot window data point to choose a ',...
        'simulation index to plot.\n'
        ];
    end
    
    
    %% Callbacks %%
    function Callback_dsPlot_panel_openWindowButton(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      pluginObj.openWindow();
    end
    
    
    Callback_dsPlot_panel_deleteDataButton(src, evnt)
    
    
    Callback_dsPlot_panel_importDataButton(src, evnt)
    
    
    function Callback_plotWindowOpened(src, evnt)
      if isfield(src.controller.windowPlugins, 'dsPlot')
        pluginObj = src.controller.windowPlugins.dsPlot;

        pluginObj.addMouseButtonCallbackToPlotFig();
      end
    end
    
    
    function Callback_dsPlot_panel_funcTagBox(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin

      notify(pluginObj, 'stackEntryEdited');
    end
  
    
    function Callback_dsPlot_panel_funcBox(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      notify(pluginObj, 'stackEntryEdited');
    end
    
    
    function Callback_dsPlot_panel_funcOptsBox(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      notify(pluginObj, 'stackEntryEdited');
    end
    
    
    function Callback_dsPlot_panel_stackMenu(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      % update val
      if pluginObj.view.dynamic.dsPlotStackVal ~= src.Value
        pluginObj.view.dynamic.dsPlotStackVal = src.Value;
        
        notify(pluginObj, 'newStackVal');
      end
    end
    
    
    function Callback_dsPlot_panel_pushStackButton(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      fnTagBox = findobjReTag('dsPlot_panel_funcTagBox');
      fnTagStr = fnTagBox.String;
      
      fnBox = findobjReTag('dsPlot_panel_funcBox');
      fnStr = fnBox.String;
      
      fnOptBox = findobjReTag('dsPlot_panel_funcOptsBox');
      fnOptStr = fnOptBox.String;
      
      pluginObj.pushStack(fnTagStr, fnStr, fnOptStr);
    end
    
    
    function Callback_dsPlot_panel_popStackButton(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      pluginObj.popStack();
    end
    
    
    function Callback_stackEntryEdited(src, evnt)
      pluginObj = src; % window plugin
      
      fnTagBox = findobjReTag('dsPlot_panel_funcTagBox');
      fnTagStr = fnTagBox.String;
      
      fnBox = findobjReTag('dsPlot_panel_funcBox');
      fnStr = fnBox.String;
      
      fnOptBox = findobjReTag('dsPlot_panel_funcOptsBox');
      fnOptStr = fnOptBox.String;
      
      % get current stack val
      currVal = pluginObj.view.dynamic.dsPlotStackVal;
      
      % edit stack entry
      pluginObj.metadata.stack(currVal, :) = {fnTagStr, fnStr, fnOptStr};
      
      % update stackMenu string
      pluginObj.updateStackMenu();
    end
    
    
    function Callback_newStackVal(src, evnt)
      pluginObj = src; % window plugin
      
      % get current stack val
      currVal = pluginObj.view.dynamic.dsPlotStackVal;
            
      fnTagBox = findobjReTag('dsPlot_panel_funcTagBox');
      fnTagBox.String = pluginObj.metadata.stack{currVal, 1};
      
      fnBox = findobjReTag('dsPlot_panel_funcBox');
      fnBox.String = pluginObj.metadata.stack{currVal, 2};
      
      fnOptBox = findobjReTag('dsPlot_panel_funcOptsBox');
      fnOptBox.String = pluginObj.metadata.stack{currVal, 3};
    end
    

    function Callback_dsPlot_panel_modeMenu(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      % update val
      if pluginObj.view.dynamic.dsPlotModeVal ~= src.Value
        pluginObj.view.dynamic.dsPlotModeVal = src.Value;
      end
    end
    
    Callback_ImageWindowMousePress(src, evnt)
  end
  
end
