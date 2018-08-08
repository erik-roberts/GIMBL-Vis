%% gvPlotWindowPlugin - Plot Window Plugin Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis plot window.

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
    
    plot1dTypes = {'scatter', 'line'};
    plot2dTypes = {'scatter', 'grid'};
    plot3dTypes = {'scatter', 'slices'};
  end
  
  
  %% Public methods %%
  methods
    
    function pluginObj = gvPlotWindowPlugin(varargin)
      pluginObj@gvWindowPlugin(varargin{:});
    end

    
    function setup(pluginObj, cntrlObj)
      setup@gvWindowPlugin(pluginObj, cntrlObj);
      
      pluginObj.WindowKeyPressFcns.plot = @pluginObj.Callback_plot_window_KeyPressFcn;
      pluginObj.WindowButtonDownFcns.plot = @pluginObj.Callback_mouseButton_setSliders;
      
      % Event listeners
      cntrlObj.newListener('activeHypercubeChanged', @gvPlotWindowPlugin.Callback_activeHypercubeChanged);
      cntrlObj.newListener('activeHypercubeAxisLabelChanged', @gvPlotWindowPlugin.Callback_activeHypercubeAxisLabelChanged);
      cntrlObj.newListener('activeHypercubeSliceChanged', @gvPlotWindowPlugin.Callback_activeHypercubeSliceChanged);
      
      cntrlObj.newListener('nViewDimsChanged', @gvPlotWindowPlugin.Callback_nViewDimsChanged);
      cntrlObj.newListener('makeAxes', @gvPlotWindowPlugin.Callback_makeAxes);
      cntrlObj.newListener('doPlot', @gvPlotWindowPlugin.Callback_doPlot);
      
      addlistener(pluginObj, 'panelControlsMade', @gvPlotWindowPlugin.Callback_panelControlsMade);
      
      pluginObj.initializeControlsDynamicVars();
    end

    
    openWindow(pluginObj)
    
    
    function closeWindow(pluginObj)
      closeWindow@gvWindowPlugin(pluginObj)
      
      pluginObj.handles.ax = [];
    end
    
    
    openLegendWindow(pluginObj)

    
    plot(pluginObj)

    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
    
    function sliderPos = getSliderAbsolutePosition(pluginObj)
      thisPosCell = cellfunu(@getPos, pluginObj.view.dynamic.plotSliderAncestry);
      thisPos = vertcat(thisPosCell{:});
      thisPos = sum(thisPos);
      
      sliderPos= [thisPos, pluginObj.view.dynamic.plotSliderAncestry{1}.Position(3:4)];
      
      function out = getPos(x)
        thisUnits = x.Units;
        if ~strcmp(thisUnits, 'pixels')
          x.Units = 'pixels';
          out = x.Position;
          x.Units = thisUnits; 
        else
          out = x.Position;
        end
        
        out = out(1:2);
      end
    end
    
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    function initializeControlsDynamicVars(pluginObj)
      pluginObj.view.dynamic.plot1dTypeVal = 1;
      pluginObj.view.dynamic.plot2dTypeVal = 1;
      pluginObj.view.dynamic.plot3dTypeVal = 1;
    end
    
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
        'WindowKeyPressFcn',@pluginObj.Callback_WindowKeyPressFcn,...
        'WindowButtonDownFcn',@pluginObj.Callback_WindowButtonDownFcn,...
        'UserData',pluginObj.userData...
        );

      % set plot handle
      pluginObj.handles.fig = plotWindowHandle;
    end
    
    
    makeAxes(pluginObj)
    
    
    function addDataCursor(pluginObj)
      dcm = datacursormode(pluginObj.handles.fig);
      dcm.UpdateFcn = @gvCallback_dataCursor;
    end
    
    
    getPlotMetadataFromData(pluginObj, hypercubeObj)
    
    
    function makeSliderAncestryMetadata(pluginObj)
      sliderHandle = findobjReTag('plot_panel_markerSizeSlider');
      
      pluginObj.view.dynamic.plotSliderAncestry = {};
      
      h = sliderHandle;    
      
      notFigParent = true;
      while notFigParent
        if isequal(h, pluginObj.view.main.handles.fig)
          notFigParent = false;
          continue
        end
        
        pluginObj.view.dynamic.plotSliderAncestry{end+1} = h;
        
        h = h.Parent;
      end
    end

  end
  
  %% Static %%
  methods (Static, Hidden)
    
    function str = helpStr()
      str = [gvPlotWindowPlugin.pluginName ':\n',...
        'Choose plot seetings.\n'
        ];
    end
    
    
    %% Callbacks %%
    function Callback_panelControlsMade(src, evnt)
      pluginObj = src; % window plugin
      
      pluginObj.makeSliderAncestryMetadata();
    end
    

    function Callback_plot_panel_openPlotButton(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      pluginObj.openWindow();
    end
    
    
    function Callback_plot_panel_showLegendButton(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      % TODO: show colorbar, in panel legend, or extern legend/colorbar
      
      pluginObj.openLegendWindow();
    end

    
    function Callback_activeHypercubeChanged(src, evnt)
      cntrlObj = src;
      pluginObj = src.windowPlugins.(gvPlotWindowPlugin.pluginFieldName); % window plugin
      
      % check data type
      pluginObj.getPlotMetadataFromData(pluginObj.controller.activeHypercube);

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
%         nViewDimsLast = pluginObj.view.dynamic.nViewDimsLast;

        if ~(nViewDims > 0)
          pluginObj.vprintf('[gvPlotWindowPlugin] Skipping Plot\n')
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
    
    
    function Callback_plot_panel_plot1dTypeMenu(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      % update and plot if changed value
      if pluginObj.view.dynamic.plot1dTypeVal ~= src.Value
        pluginObj.view.dynamic.plot1dTypeVal = src.Value;

        cntrlObj = pluginObj.controller;
        notify(cntrlObj, 'doPlot');
      end
    end
    
    
    function Callback_plot_panel_plot2dTypeMenu(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      % update and plot if changed value
      if pluginObj.view.dynamic.plot2dTypeVal ~= src.Value
        pluginObj.view.dynamic.plot2dTypeVal = src.Value;

        cntrlObj = pluginObj.controller;
        notify(cntrlObj, 'doPlot');
      end
    end
    
    
    function Callback_plot_panel_plot3dTypeMenu(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      % update and plot if changed value
      if pluginObj.view.dynamic.plot3dTypeVal ~= src.Value
        pluginObj.view.dynamic.plot3dTypeVal = src.Value;

        cntrlObj = pluginObj.controller;
        notify(cntrlObj, 'doPlot');
      end
    end
    
    
    Callback_WindowScrollWheelFcn(src, evnt)
    
    
    Callback_mouseButton_setSliders(src, evnt)
    
    
    function Callback_plot_window_KeyPressFcn(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      switch evnt.Character
        case '1' 
          plotTypeMenuHandle = findobjReTag('plot_panel_plot1dTypeMenu');

          plotTypeMenuHandle.Value = max(mod(plotTypeMenuHandle.Value+1, 3),1);
          
          pluginObj.vprintf('[gvPlotWindowPlugin] ''1D Plot Type'': ''%s''\n', plotTypeMenuHandle.String{plotTypeMenuHandle.Value});
          
          pluginObj.Callback_plot_panel_plot1dTypeMenu(plotTypeMenuHandle, evnt);
        case '2' 
          plotTypeMenuHandle = findobjReTag('plot_panel_plot2dTypeMenu');

          plotTypeMenuHandle.Value = max(mod(plotTypeMenuHandle.Value+1, 3),1);
          
          pluginObj.vprintf('[gvPlotWindowPlugin] ''2D Plot Type'': ''%s''\n', plotTypeMenuHandle.String{plotTypeMenuHandle.Value});
          
          pluginObj.Callback_plot_panel_plot2dTypeMenu(plotTypeMenuHandle, evnt);
        case '3'
          plotTypeMenuHandle = findobjReTag('plot_panel_plot3dTypeMenu');
          
          plotTypeMenuHandle.Value = max(mod(plotTypeMenuHandle.Value+1, 3),1);
          
          pluginObj.vprintf('[gvPlotWindowPlugin] ''3D Plot Type'': ''%s''\n', plotTypeMenuHandle.String{plotTypeMenuHandle.Value});
          
          pluginObj.Callback_plot_panel_plot3dTypeMenu(plotTypeMenuHandle, evnt);
      end
    end
    
  end
  
end
