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
  end
  
  %% Protected properties %%
  properties (Access = protected)
    lastIndex = -1;
    fig2copy = [];
  end
  
  %% Events %%
  events
    
  end
  
  
  %% Public methods %%
  methods
    
    function pluginObj = gvDsPlotWindowPlugin(varargin)
      pluginObj@gvWindowPlugin(varargin{:});
    end
    
    
    function setup(pluginObj, cntrlObj)
      setup@gvWindowPlugin(pluginObj, cntrlObj);
      
      pluginObj.metadata.plotFn = pluginObj.controller.app.config.defaultDsPlotFn;
      pluginObj.metadata.plotFnOpts = ''; % default to no options
      
      pluginObj.addWindowOpenedListenerToPlotPlugin();
    end

    openWindow(pluginObj)
    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
    plotData(pluginObj, index)

  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    function status = makeFig(pluginObj)
      % makeFig - make dsPlot window figure
      
      if ~isValidFigHandle(pluginObj.controller.plugins.plot.handles.fig)
        wprintf('Plot Window Must Be Open to Open dsPlot Window.');
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
        
        pluginObj.vprintf('gvDsPlotWindowPlugin: Added window opened listener to plot plugin.\n');
      end
    end
    
    
    function addMouseMoveCallbackToPlotFig(pluginObj)
      if isfield(pluginObj.controller.windowPlugins, 'plot')
        plotFigH = pluginObj.controller.windowPlugins.plot.handles.fig;
%         set(plotFigH, 'WindowButtonMotionFcn', @gvDsPlotWindowPlugin.Callback_mouseMove);
        set(plotFigH, 'WindowButtonDownFcn', @gvDsPlotWindowPlugin.Callback_mouseClick);
        
        pluginObj.vprintf('gvDsPlotWindowPlugin: Added WindowButtonMotionFcn callback to plot plugin figure.\n');
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
    
    
    Callback_dsPlot_panel_importDataButton(src, evnt)
    

    function Callback_plotWindowOpened(src, evnt)
      if isfield(src.controller.windowPlugins, 'dsPlot')
        pluginObj = src.controller.windowPlugins.dsPlot;

        pluginObj.addMouseMoveCallbackToPlotFig();
      end
    end
  
    
    function Callback_dsPlot_panel_funcBox(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      % update func
      pluginObj.metadata.plotFn = src.String;
    end
    
    
    function Callback_dsPlot_panel_funcOptsBox(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      % update func
      pluginObj.metadata.plotFnOpts = src.String;
    end
    
    Callback_mouseClick(src, evnt)
  end
  
end
