%% gvPlotWindow - UI Plot Window Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMB-Vis plot window

classdef gvPlotWindow < gvWindow

  %% Public properties %%
  properties
    metadata = struct()
    handles = struct()
    
    viewObj
  end
  
  
  %% Other properties %%
  properties (Constant, Hidden)
    windowName = 'Plot';
    windowFieldName = 'plotWindow';
  end
  
  
  %% Events %%
  events
    plotEvent
  end
  
  
  %% Public methods %%
  methods
    
    function windowObj = gvPlotWindow(varargin)
      windowObj@gvWindow(varargin{:});
    end

    openWindow(windowObj)

    plot(windowObj)

  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    function createFig(windowObj)
      % createFig - create plot window figure
      
      mainWindowPos = windowObj.viewObj.windows.mainWindow.handles.fig.Position;
    
      plotWindowHandle = figure(...
        'Name','Plot Window',...
        'NumberTitle','off',...
        'Position',[mainWindowPos(1)+mainWindowPos(3)+50, mainWindowPos(2), 600,500],...
        'UserData',windowObj.userData,...
        'WindowButtonMotionFcn',@gvPlotWindow.mouseMoveCallback...
        );

      % set plot handle
      windowObj.handles.fig = plotWindowHandle;
      windowObj.handles.ax = axes(plotWindowHandle);
    end
    
    
    function createAxes(windowObj)
      % createAxes - create plot window figure axes grid based on number of viewDims
      
      plotWindowHandle = windowObj.handles.fig;
      clf(plotWindowHandle) %clear fig
      
      nViewDims = windowObj.viewObj.nViewDims;
      
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
        windowObj.handles.ax = hAx; %TODO check handle type
      end
    end
    
    
    function addDataCursor(windowObj)
      dcm = datacursormode(windowObj.handles.fig);
      dcm.UpdateFcn = @gvPlotWindow.dataCursorCallback;
    end
    
%     createMenu(viewObj, parentHandle)
    
%     createControls(viewObj, parentHandle)
  end
  
  %% Callbacks %%
  methods (Static, Hidden)

    function plotCallback(src, evnt)
      viewObj = src.viewObj;
      
      nViewDims = viewObj.nViewDims;
      nViewDimsLast = viewObj.nViewDimsLast;

      if nViewDims > 0 && nViewDims ~= nViewDimsLast
        viewObj.plot();
      end
    end
    
    
    mouseMoveCallback(src, evnt)
    
    dataCursorCallback(src, evnt)
    
  end
  
end
