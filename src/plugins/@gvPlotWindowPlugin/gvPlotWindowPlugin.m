%% gvPlotWindow - UI Plot Window Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis plot window

classdef gvPlotWindowPlugin < gvWindowPlugin

  %% Public properties %%
  properties
    metadata = struct()
  end
  
  
  %% Other properties %%
  properties (Hidden)
    controller
    view
    
    handles = struct()
  end
  
  
  properties (Constant, Hidden)
    pluginName = 'Plot';
    pluginFieldName = 'plot';
    
    windowName = 'Plot Window';
  end
  
  
  %% Events %%
  events
    plotEvent
  end
  
  
  %% Public methods %%
  methods
    
    function pluginObj = gvPlotWindowPlugin(varargin)
      pluginObj@gvWindowPlugin(varargin{:});
    end

    openWindow(pluginObj)
    
    openLegendWindow(pluginObj)

    plot(pluginObj)

  end
  
  %% Hidden methods %%
  methods (Hidden)
    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    dataPanelheight = makeDataPanelControls(pluginObj, parentHandle)
    
    makeDataPanelTitles(pluginObj, parentHandle)
    
    makePlotMarkerPanelControls(pluginObj, parentHandle)
    
    makePlotPanelControls(pluginObj, parentHandle)
    
    function makeFig(pluginObj)
      % makeFig - make plot window figure
      
      mainWindowPos = pluginObj.view.windowPlugins.main.handles.fig.Position;
    
      plotWindowHandle = figure(...
        'Name','Plot Window',...
        'NumberTitle','off',...
        'Position',[mainWindowPos(1)+mainWindowPos(3)+50, mainWindowPos(2), 600,500],...
        'UserData',pluginObj.userData,...
        'WindowButtonMotionFcn',@gvPlotWindowPlugin.mouseMoveCallback...
        );

      % set plot handle
      pluginObj.handles.fig = plotWindowHandle;
      pluginObj.handles.ax = axes(plotWindowHandle);
    end
    
    
    function makeAxes(pluginObj)
      % makeAxes - make plot window figure axes grid based on number of viewDims
      
      plotWindowHandle = pluginObj.handles.fig;
      clf(plotWindowHandle) %clear fig
      
      nViewDims = pluginObj.view.nViewDims;
      
      gap = 0.1;
      marg_h = 0.1;
      marg_w = 0.1;
      
      switch nViewDims
        case 1
          % 1 1d pane
          %         axes(hFig)
          %       hspg = subplot_grid(1,'no_zoom', 'parent',hFig);
          hAx = tight_subplot2(1, 1, gap, marg_h, marg_w, plotWindowHandle);
        case 2
          % 1 2d pane
          %         axes(hFig)
          %       hspg = subplot_grid(1,'no_zoom', 'parent',hFig);
          hAx = tight_subplot2(1, 1, gap, marg_h, marg_w, plotWindowHandle);
        case 3
          % 3 2d panes + 1 3d pane = 4 subplots
          %       hspg = subplot_grid(2,2, 'parent',hFig);
          hAx = tight_subplot2(2, 2, gap, marg_h, marg_w, plotWindowHandle);
        case 4
          % 6 2d panes + 4 3d pane = 10 subplots
          %       hspg = subplot_grid(2,5, 'parent',hFig);
          hAx = tight_subplot2(2, 5, gap, marg_h, marg_w, plotWindowHandle);
        case 5
          % 10 2d panes + 10 3d pane = 20 subplots
          %       hspg = subplot_grid(3,7, 'parent',hFig); % 1 empty
          hAx = tight_subplot2(3, 7, gap, marg_h, marg_w, plotWindowHandle);
        case 6
          % 15 2d panes = 15 subplots
          %       hspg = subplot_grid(3,5, 'parent',hFig);
          hAx = tight_subplot2(3, 5, gap, marg_h, marg_w, plotWindowHandle);
        case 7
          % 21 2d panes = 21 subplots
          %       hspg = subplot_grid(3,7, 'parent',hFig);
          hAx = tight_subplot2(3, 7, gap, marg_h, marg_w, plotWindowHandle);
        case 8
          % 28 2d panes = 28 subplots
          %       hspg = subplot_grid(4,7, 'parent',hFig);
          hAx = tight_subplot2(4, 7, gap, marg_h, marg_w, plotWindowHandle);
        otherwise
          wprintf('Select at least 1 ViewDim to plot.')
      end
      
      if nViewDims > 0
        pluginObj.handles.ax = hAx; %TODO check handle type
      end
    end
    
    
    function addDataCursor(pluginObj)
      dcm = datacursormode(pluginObj.handles.fig);
      dcm.UpdateFcn = @gvPlotWindowPlugin.dataCursorCallback;
    end

  end
  
  %% Callbacks %%
  methods (Static, Hidden)

    function openWindowCallback(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      pluginObj.openWindow();
    end
    
    
    function openLegendWindowCallback(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      pluginObj.openLegendWindow();
    end
    
    
    function plotCallback(src, evnt)
      view = src.view;
      
      nViewDims = view.nViewDims;
      nViewDimsLast = view.nViewDimsLast;

      if nViewDims > 0 && nViewDims ~= nViewDimsLast
        view.plot();
      end
    end
    
    
    mouseMoveCallback(src, evnt)
    
    dataCursorCallback(src, evnt)
    
  end
  
end
