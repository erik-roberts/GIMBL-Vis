%% gvPlotWindow - Plot Window Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis plot window

classdef gvPlotWindowPlugin < gvWindowPlugin

  %% Public properties %%
  properties
    metadata = struct()
    
    handles = struct()
  end
  
  properties (Constant)
    pluginName = 'Plot';
    pluginFieldName = 'plot';
    
    windowName = 'Plot Window';
  end
  
  
  %% Public methods %%
  methods
    
    function pluginObj = gvPlotWindowPlugin(varargin)
      pluginObj@gvWindowPlugin(varargin{:});
    end

    
    function setup(pluginObj, cntrlObj)
      setup@gvWindowPlugin(pluginObj, cntrlObj);
      
      % Event listeners
      cntrlObj.newListener('activeHypercubeChanged', @gvPlotWindowPlugin.Callback_activeHypercubeChanged);
      cntrlObj.newListener('activeHypercubeAxisLabelChanged', @gvPlotWindowPlugin.Callback_activeHypercubeAxisLabelChanged);
      cntrlObj.newListener('activeHypercubeSliceChanged', @gvPlotWindowPlugin.Callback_activeHypercubeSliceChanged);
      
      cntrlObj.newListener('nViewDimsChanged', @gvPlotWindowPlugin.Callback_nViewDimsChanged);
      cntrlObj.newListener('makeAxes', @gvPlotWindowPlugin.Callback_makeAxes);
      cntrlObj.newListener('doPlot', @gvPlotWindowPlugin.Callback_doPlot);
    end

    
    openWindow(pluginObj)
    
    
    function closeWindow(pluginObj)
      closeWindow@gvWindowPlugin(pluginObj)
      
      pluginObj.handles.ax = [];
    end
    
    
    openLegendWindow(pluginObj)

    
    plot(pluginObj)
    
    
    iterate(pluginObj)

    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    makePlotMarkerPanelControls(pluginObj, parentHandle)
    
    
    makePlotPanelControls(pluginObj, parentHandle)
    
    
    function makeFig(pluginObj)
      % makeFig - make plot window figure
      
      mainWindowPos = pluginObj.controller.windowPlugins.main.handles.fig.Position;
    
      plotWindowHandle = figure(...
        'Name',['GIMBL-VIS: ' pluginObj.windowName],...
        'Tag', pluginObj.figTag(),...
        'NumberTitle','off',...
        'Position',[mainWindowPos(1)+mainWindowPos(3)+50, mainWindowPos(2), 600,500],...
        'UserData',pluginObj.userData...
        );
      %         'WindowButtonMotionFcn',@gvPlotWindowPlugin.mouseMoveCallback...

      % set plot handle
      pluginObj.handles.fig = plotWindowHandle;
%       pluginObj.handles.ax = axes(plotWindowHandle);
    end
    
    
    function makeAxes(pluginObj)
      % makeAxes - make plot window figure axes grid based on number of viewDims
      
      plotWindowHandle = pluginObj.handles.fig;
      
      if ~pluginObj.checkWindowExists()
        pluginObj.vprintf('Skipping axis creation since window not open.\n')
        return
      end
      
      clf(plotWindowHandle) %clear fig
      
      nViewDims = pluginObj.view.dynamic.nViewDims;

      gap = 0.1;
      marg_h = 0.1;
      marg_w = 0.1;
      
      switch nViewDims
        case 1
          % 1 1d pane
          %         axes(hFig)
          %       hspg = subplot_grid(1,'no_zoom', 'parent',hFig);
          tight_subplot2(1, 1, gap, marg_h, marg_w, plotWindowHandle);
        case 2
          % 1 2d pane
          %         axes(hFig)
          %       hspg = subplot_grid(1,'no_zoom', 'parent',hFig);
          tight_subplot2(1, 1, gap, marg_h, marg_w, plotWindowHandle);
        case 3
          % 3 2d panes + 1 3d pane = 4 subplots
          %       hspg = subplot_grid(2,2, 'parent',hFig);
          tight_subplot2(2, 2, gap, marg_h, marg_w, plotWindowHandle);
        case 4
          % 6 2d panes + 4 3d pane = 10 subplots
          %       hspg = subplot_grid(2,5, 'parent',hFig);
          tight_subplot2(2, 5, gap, marg_h, marg_w, plotWindowHandle);
        case 5
          % 10 2d panes + 10 3d pane = 20 subplots
          %       hspg = subplot_grid(3,7, 'parent',hFig); % 1 empty
          tight_subplot2(3, 7, gap, marg_h, marg_w, plotWindowHandle);
        case 6
          % 15 2d panes = 15 subplots
          %       hspg = subplot_grid(3,5, 'parent',hFig);
          tight_subplot2(3, 5, gap, marg_h, marg_w, plotWindowHandle);
        case 7
          % 21 2d panes = 21 subplots
          %       hspg = subplot_grid(3,7, 'parent',hFig);
          tight_subplot2(3, 7, gap, marg_h, marg_w, plotWindowHandle);
        case 8
          % 28 2d panes = 28 subplots
          %       hspg = subplot_grid(4,7, 'parent',hFig);
          tight_subplot2(4, 7, gap, marg_h, marg_w, plotWindowHandle);
        otherwise
          wprintf('Select 1-8 dimensions to plot.')
      end

      hAx = plotWindowHandle.Children;
      hAxBool = false(length(hAx),1);
      
      for hInd = 1:length(hAx)
        hAxBool(hInd) = strcmp(hAx(hInd).Type, 'axes');
      end   
      hAx = hAx(hAxBool);
      
      hAx = flip(hAx); % since given backwards
      
      if nViewDims > 0
        pluginObj.handles.ax = hAx;
      else
        pluginObj.handles.ax = [];
      end
    end
    
    
    function addDataCursor(pluginObj)
      dcm = datacursormode(pluginObj.handles.fig);
      dcm.UpdateFcn = @gvPlotWindowPlugin.dataCursorCallback;
    end

  end
  
  %% Callbacks %%
  methods (Static)

    function Callback_plot_panel_openPlotButton(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      pluginObj.openWindow();
    end
    
    
    function Callback_plot_panel_openLegendButton(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      pluginObj.openLegendWindow();
    end
    
    
    function Callback_plot_panel_iterateToggle(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      if src.Value
        src.String = sprintf('Iterate ( %s )', char(8545)); %pause char (bars)
%         src.String = sprintf('Iterate ( %s )', char(hex2dec('23F8'))); %pause char (bars)

        pluginObj.iterate();
      else
        src.String = sprintf('Iterate ( %s )', char(9654)); %start char (arrow)
      end
    end
    
    
    function Callback_activeHypercubeChanged(src, evnt)
      cntrlObj = src;
      
      notify(cntrlObj, 'doPlot');
    end
 
    
    function Callback_activeHypercubeAxisLabelChanged(src, evnt)
      cntrlObj = src;
      
      notify(cntrlObj, 'doPlot');
    end
    
    
    function Callback_activeHypercubeSliceChanged(src, evnt)
      cntrlObj = src;
      
      notify(cntrlObj, 'doPlot');
    end
    
    
    function Callback_nViewDimsChanged(src, evnt)
      cntrlObj = src;
%       pluginObj = src.windowPlugins.(gvPlotWindowPlugin.pluginFieldName); % window plugin
      
      notify(cntrlObj, 'makeAxes');
    end
    
    
    function Callback_makeAxes(src, evnt)
      cntrlObj = src;
      pluginObj = src.windowPlugins.(gvPlotWindowPlugin.pluginFieldName); % window plugin
 
      if pluginObj.view.checkMainWindowExists() && pluginObj.checkWindowExists()
        pluginObj.makeAxes();
        
        notify(cntrlObj, 'doPlot');
      end
    end
    
    
    function Callback_doPlot(src, evnt)
      pluginObj = src.windowPlugins.(gvPlotWindowPlugin.pluginFieldName); % window plugin
 
      if pluginObj.view.checkMainWindowExists()
        
        nViewDims = pluginObj.view.dynamic.nViewDims;
        nViewDimsLast = pluginObj.view.dynamic.nViewDimsLast;

        if ~(nViewDims > 0)
          pluginObj.vprintf('Skipping Plot\n')
          return
        end

        if ~pluginObj.checkWindowExists()
          pluginObj.openWindow();
        end
        
        pluginObj.plot();
      end
    end
    
    
    function Callback_plot_panel_autoSizeToggle(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      cntrlObj = pluginObj.controller;
      
      markerSizeSlider = findobj('-regexp', 'Tag','markerSizeSlider');
      
      if src.Value
        src.String = sprintf('AutoSize (%s)', char(hex2dec('2714')));
        markerSizeSlider.Enable = 'off';
      else
        src.String = sprintf('AutoSize (%s)', '  ');
        markerSizeSlider.Enable = 'on';
      end
      
      notify(cntrlObj, 'doPlot');
    end
    
    function Callback_plot_panel_markerSizeSlider(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      cntrlObj = pluginObj.controller;
      
      notify(cntrlObj, 'doPlot');
    end
    
    
    mouseMoveCallback(src, evnt)
    
    dataCursorCallback(src, evnt)
    
  end
  
end
