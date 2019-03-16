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
      
      % determine figure pos
      pos = pluginObj.getConfig([pluginObj.pluginClassName '_Position']);
      if isempty(pos)
        mainWindowPos = pluginObj.controller.windowPlugins.main.handles.fig.Position;
        
        % default Position
        pos = [mainWindowPos(1)+mainWindowPos(3)+50, mainWindowPos(2), 600,500];
      end
      
    
      plotWindowHandle = figure(...
        'Name',['GIMBL-Vis: ' pluginObj.windowName],...
        'Tag', pluginObj.figTag(),...
        'NumberTitle','off',...
        'Position',pos,...
        'WindowKeyPressFcn',@pluginObj.Callback_WindowKeyPressFcn,...
        'WindowButtonDownFcn',@pluginObj.Callback_WindowButtonDownFcn,...
        'UserData',pluginObj.userData...
        );
      
      
      brushH = brush( plotWindowHandle);
      
      set(brushH, 'ActionPostCallback', @pluginObj.Callback_brushActionPost);

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
    
    function Callback_brushActionPost(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      % get pt inds
      axH = evnt.Axes;
      
      scatterH = findobj(axH.Children,'type','Scatter');
      
      brushInd = logical(scatterH.BrushData);
      
      xInds = scatterH.XData(brushInd);
      yInds = scatterH.YData(brushInd);
      
      nPts = length(xInds);
      
      % get ax vals
      hypercubeObj = pluginObj.controller.activeHypercube;
      plotDims = axH.UserData.plotDims;
      hypercubeAxes = hypercubeObj.axis(plotDims);
      
      axValues = {hypercubeAxes.values};
      axNames = {hypercubeAxes.name};
      
      xVals = axValues{1}(xInds);
      yVals = axValues{2}(yInds);
      xVals = xVals(:);
      yVals = yVals(:);
      
      if isnumeric(xVals)
        [xVals, iSorted] = sort(xVals);
        
        yVals = yVals(iSorted);
        
        xVals = num2str(xVals);
      end
      if isnumeric(yVals)
        yVals = num2str(yVals);
      end
      
      axStr = strjoin(axNames, ' | ');
      dataStr = strcat(xVals, ' | ', yVals);
      
      if length(plotDims) > 2
        zInds = scatterH.ZData(brushInd);
        
        zVals = axValues{3}(zInds);
        zVals = zVals(:);
        
        if exist('iSorted', 'var')
          zVals = zVals(iSorted);
        end
        
        if isnumeric(zVals)
          zVals = num2str(zVals);
        end
        
        dataStr = strcat(dataStr, ' | ', zVals);
      end
      
      % find corresponding index
      axesType = gvGetAxisType(hypercubeObj);
      if ~isempty(axesType)
        % check for axisType = 'dataType'
        dataTypeAxInd = find(strcmp(axesType, 'dataType'), 1);
        indexAxInd = find(strcmp(pluginObj.controller.activeHypercube.axis(dataTypeAxInd).axismeta.dataType, 'index'),1);
        
        imageInds = zeros(nPts, 1);
        
        for iPt = 1:nPts
          sliderVals = pluginObj.view.dynamic.sliderVals;
          sliderVals(dataTypeAxInd) = indexAxInd; % set sliderVals dataType axis number to axis position for hypercube index.
          
          if length(plotDims) == 3 % 3D
            sliderVals(plotDims) = [xInds(iPt) yInds(iPt) zInds(iPt)]; % set sliderVals plot dims to closest point to mouse
          elseif length(plotDims) == 2 % 2D
            sliderVals(plotDims) = [xInds(iPt) yInds(iPt)]; % set sliderVals plot dims to closest point to mouse
          else % 1D
            sliderVals(plotDims) = xInds(iPt); % set sliderVals plot dims to closest point to mouse
          end
          
          % get image index from slider vals
          sliderVals = num2cell(sliderVals); % convert to cell for indexing
          imageIndex = hypercubeObj.data(sliderVals{:});
          if iscell(imageIndex)
            imageIndex = imageIndex{1};
          end
          if ischar(imageIndex)
            imageIndex = str2double(imageIndex);
          end
          imageInds(iPt) = imageIndex;
        end
        
        imageInds = num2str(imageInds);
        
        axStr = ['Index | ' axStr];
        dataStr = strcat(imageInds, ' | ', dataStr);
      end
      
      % disp
      disp('Brush Data:')
      disp(axStr);
      disp(dataStr);
    end
    
  end
  
end
