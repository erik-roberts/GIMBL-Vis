function plot(pluginObj)

% TODO
% - fn on cells
% - hypercube scale colormap

% Dev notes:
%  Data Type Strategy:
%   - check if all data is numeric
%   - check if slice or hypercube numeric scale
%   - if mixed, set non-numeric to nans
%   - if only non-numeric, get legend info

hFig = pluginObj.handles.fig;
hAx = pluginObj.handles.ax;
figure(hFig); % make hFig gcf % TODO find way to remove this

nViewDims = pluginObj.view.dynamic.nViewDims;
if nViewDims == 0
  return
end
viewDims = pluginObj.view.dynamic.viewDims;

fontSize = pluginObj.view.fontSize;

hypercubeObj = pluginObj.controller.activeHypercube;
dimNames = hypercubeObj.axisNames;
dimNames = strrep(dimNames, '_', '\_'); % replace '_' with '\_' to avoid subscript
sliderVals = pluginObj.view.dynamic.sliderVals;

makeAllSubplots();


%% Nested functions
  function makeAllSubplots()
    switch nViewDims
      case 1
        % 1 1d pane
        plotDim = find(viewDims);

        makeSubplot(hAx, plotDim);
        
      case 2
        % 1 2d pane
        plotDims = find(viewDims);
        
        makeSubplot(hAx, plotDims);
        
      case {3,4,5}
        % 3D: 3 2d panes + 1 3d pane = 4 subplots
        % 4D: 6 2d panes + 4 3d pane = 10 subplots
        % 5D: 10 2d panes + 10 3d pane = 20 subplots
        
        plotDims = find(viewDims);
        
        % 2d plots
        plotDims2d = sort(combnk(plotDims,2));
        for iAx2d = 1:size(plotDims2d, 1)
          ax2d = hAx(iAx2d);
          
          makeSubplot(ax2d, plotDims2d(iAx2d,:));
        end
        
        % 3d plot
        plotDims3d = sort(combnk(plotDims,3));
        
        for iAx3d = iAx2d+1:iAx2d+size(plotDims3d, 1)
          ax3d = hAx(iAx3d);
%           if isgraphics(ax3d) && isempty(get(ax3d,'Children'))
            makeSubplot(ax3d, plotDims3d(iAx3d-iAx2d,:))
%           end
        end
        
      case {6, 7, 8}
        % 6D: 15 2d panes = 15 subplots
        % 7D: 21 2d panes = 21 subplots
        % 8D: 28 2d panes = 28 subplots
        
        plotDims = find(viewDims);
        
        % 2d plots
        plotDims2d = sort(combnk(plotDims,2));
        for iAx2d = 1:size(plotDims2d, 1)
          ax2d = hAx(iAx2d);
          
          makeSubplot(ax2d, plotDims2d(iAx2d,:));
        end
      otherwise
        wprintf('Unsupported Number of Dimensions');
    end
    
    hideEmptyAxes(hFig);
    
  end


  function makeSubplot(hAx, plotDims)
    set(hFig,'CurrentAxes', hAx);

    sliceInds = sliderVals;
    sliceInds = num2cell(sliceInds);
    [sliceInds{plotDims}] = deal(':');
    plotSlice = squeeze(hypercubeObj.data(sliceInds{:}));
    
    if hypercubeObj.meta.onlyNumericDataBool
      anyNumBool = true;
    else
      % check if any numeric in slice
      numInds = cellfun(@isscalar, plotSlice) & ~cellfun(@iscategorical, plotSlice);
      
      if any(numInds(:))
        anyNumBool = true;
        
        % convert non-numeric to nan
        if ~all(numInds(:))
          plotSlice(~numInds) = deal({nan});
        end
        
        % convert slice to mat
        plotSlice = cell2mat(plotSlice);
        clear plotSliceTemp
      else % all non-num
        anyNumBool = false;
        
        if length(hypercubeObj.meta.legend) > 1
          axesType = gvGetAxisType(hypercubeObj);
          dataTypeAxInd = find(strcmp(axesType, 'dataType'), 1);
          
          legendInfo = hypercubeObj.meta.legend(sliderVals(dataTypeAxInd));
        else
          legendInfo = hypercubeObj.meta.legend(1);
        end
      end
    end
    
    % fill empty cell with nan
    if iscell(plotSlice)
      plotSlice(cellfun(@isempty,plotSlice)) = deal({nan});
    end
    
    % make plot
    if anyNumBool
      makePlot(hAx, plotDims, plotSlice);
    else
      makePlot(hAx, plotDims, plotSlice, legendInfo);
    end
  end


  function makePlot(hAx, plotDims, plotSlice, legendInfo)
    if nargin<4
      legendInfo = [];
    end

    axInds = arrayfun(@makeAxInd, plotDims,'Uni',0); % for ticks
    axVals = arrayfun(@getValsForAxis, plotDims,'Uni',0); % for tick labels
    
    if length(axInds) == 1
      plotType = pluginObj.plot1dTypes{pluginObj.view.dynamic.plot1dTypeVal};
    elseif length(axInds) == 2
      plotType = pluginObj.plot2dTypes{pluginObj.view.dynamic.plot2dTypeVal};
    elseif length(axInds) == 3
      plotType = pluginObj.plot3dTypes{pluginObj.view.dynamic.plot3dTypeVal};
    end
    
    switch plotType
      case {'scatter', 'line'}
        % turn ax vals into mesh grids
        if length(axInds) == 3
          axValsVector = cell(1, length(axInds));
          [axValsVector{:}] = meshgrid(axInds{2}, axInds{1}, axInds{3});
        elseif length(axInds) == 2
          axValsVector = cell(1, length(axInds));
          [axValsVector{:}] = meshgrid(axInds{2}, axInds{1});
        else % turn 1D into 2D
          axValsVector{2} = axInds{1};
          axValsVector{1} = axValsVector{2}*0;
        end
        axValsVector([1,2]) = axValsVector([2,1]);
        
        % linearize ax vals and data
        axValsVector = cellfunu(@linearize, axValsVector);
        plotSlice = plotSlice(:);
        
        % remove empty cells
        if iscell(plotSlice)
          emptyCells = cellfun(@isempty,plotSlice);
          if any(emptyCells)
            axValsVector = cellfun(@removeEmpty, axValsVector);
            plotSlice(emptyCells) = [];
          end
        end
      case 'grid'
        axValsVector = axInds;
        
        plotSlice = plotSlice'; % since 'image' plots x/dim1 on y
      case 'slices'
        plotSliceFull = plotSlice;
      otherwise
        wprintf('Unknown Plot Type')
        return
    end
    
    % remove empty cells
    if iscell(plotSlice)
      nanCells = cellfun(@isnan2,plotSlice);
      if all(nanCells)
        cla
        return
      end
      if any(nanCells)
        axValsVector = cellfun(@removeNan, axValsVector, 'Uni',0);
        if isnumeric(axValsVector)
          axValsVector = num2cell(axValsVector);
        end
        plotSlice(nanCells) = [];
      end
    end
    
    axisLabels = dimNames(plotDims);

    % Marker Size
    markerSizeSlider = findobjReTag('plot_panel_markerSizeSlider');
    autoSizeMarkerCheckboxHandle = findobjReTag('plot_panel_autoSizeToggle');
    if autoSizeMarkerCheckboxHandle.Value %auto size marker
      axUnit = get(hAx,'unit');
      set(hAx,'unit', 'pixels');
      pos = get(hAx,'position');
      axSize = pos(3:4);
      markerSize = 8 * min(axSize) / max(cellfun(@length, axInds));
      set(hAx,'unit', axUnit);
    else %manual size marker
      markerSize = markerSizeSlider.Value;
    end
    
    % get slice ready
    if ~isempty(legendInfo) % categorical cells
      groups = legendInfo.groups;
      colors = legendInfo.colors;
      markers = legendInfo.markers;

      if iscellstr(plotSlice)
        [~, gInd] = ismember(plotSlice, groups);
        missingInd = strcmp(plotSlice, 'missing');
        
        catDataBool = false;
      elseif iscellcategorical(plotSlice)
        plotSlice = [plotSlice{:}];
        [~, gInd] = ismember(plotSlice, groups);
        missingInd = (plotSlice == 'missing');
        
        catDataBool = true;
      else
        error('Unknown data type')
      end
      
      if ~strcmp(plotType, 'line')
        clear plotSlice
        
        % make missing ones 1 temporarily
        gInd(missingInd) = 1;
        
        % assign colors to plotSlice based on group index
        plotSlice = colors(gInd,:);
        
        % make missing nan
        if any(missingInd)
          plotSlice(missingInd, :) = nan;
        end
        
        % for grid
        if ~isvector(gInd)
          plotSlice = reshape(plotSlice, [size(gInd), 3]);
        end
      else
        plotColors = colors(gInd,:);
      end
    else
      catDataBool = false;
    end
    
    % make plot
    if length(axInds) < 3
      switch plotType
        case 'line' % only 1d
          plot(hAx, axInds{1}, plotSlice);
          
          hold(hAx, 'on')
          if ~catDataBool
            scatter(hAx, axInds{1}, plotSlice, markerSize, 'b', 'filled');
          else
            scatter(hAx, axInds{1}, plotSlice, markerSize, plotColors, 'filled');
          end
          hold(hAx, 'off')
        case 'scatter' % 1d or 2d (3d below)
          scatter(hAx, axValsVector{:}, markerSize, plotSlice, 'filled'); % slice specific colormap
        case 'grid' % only 2d
          figure(hFig); % make hFig gcf % TODO find way to remove this
          if isempty(legendInfo)
            image(axValsVector{:}, plotSlice, 'CDataMapping','scaled'); % slice specific colormap
          else
            image(axValsVector{:}, plotSlice); % slice specific colormap
          end
          
          axis xy
        otherwise
          wprintf('Unknown Plot Type')
          return
      end
    else
      switch plotType
        case 'scatter'
          scatter3(hAx, axValsVector{:}, markerSize, plotSlice, 'filled'); % slice specific colormap
        case 'slices'
          plotSliderVals = sliderVals(plotDims);
          sliceH = slice(axInds{:}, permute(plotSliceFull, [2 1 3]), plotSliderVals(1), plotSliderVals(2), plotSliderVals(3));
          [sliceH(:).FaceAlpha] = deal(.7);
          [sliceH(:).EdgeAlpha] = deal(.7);
        otherwise
          wprintf('Unknown Plot Type')
          return
      end
    end
    
    if isempty(legendInfo) && ~strcmp(plotType, 'line')
      colorbar
    end
    
    % Set ticks
    setTicks();
    
    % special 1d settings
    if length(axInds) == 1
      if ~strcmp(plotType, 'line')
        % Remove 1D y axis
        set(hAx,'YTick', []);
      else
        % Add 1d axis label from dataTypeAx if exists
        axesType = gvGetAxisType(hypercubeObj);
        dataTypeAxInd = find(strcmp(axesType, 'dataType'), 1);
        
        % check that dataTypeAx exists
        if ~isempty(dataTypeAxInd)
          allAxVals = getValsForAxis(dataTypeAxInd);
          hAx.YLabel.String = allAxVals{sliderVals(dataTypeAxInd)};
        end
      end
    end
    
    % lims
    setLims();
    
    % add slider slice lines/planes
    if length(axInds) <= 2
      addSliderSlices()
    end
    
    hAx.FontSize = fontSize;
    
    % add plotDims and axis labels to ax user data
    hAx.UserData = struct('plotDims',plotDims);
    hAx.UserData.axLabels = axisLabels;
    
    
    %% Nested fn
    function out = makeAxInd(x)
      out = 1:length(hypercubeObj.axisValues{x});
    end
    
    function vals = getValsForAxis(x)
      vals = hypercubeObj.axisValues{x};
      
      % convert to string if numeric with proper string format
      if isnumeric(vals)
        vals = strsplit( num2str(vals(:)','%.2g ') );
      end
    end
    
    function x = removeEmpty(x)
      x(emptyCells) = [];
    end
    
    function x = removeNan(x)
      x(nanCells) = [];
    end
    
    function addSliderSlices()
      sliderSliceLineWidth = max(3, markerSize / 40);
      sliderSliceLineAlpha = 0.3;
      
      plotSliderVals = sliderVals(plotDims);
      
      hold(hAx, 'on');
      
      thisAxInd = 0;
      
      % vertical slice line
      thisAxInd = thisAxInd + 1;
      plot(hAx, [plotSliderVals(thisAxInd) plotSliderVals(thisAxInd)], ylim(hAx),...
        'k-', 'LineWidth',sliderSliceLineWidth, 'Color',[0 0 0 sliderSliceLineAlpha]);
      
      if length(axInds) > 1
        % horizontal slice line
        thisAxInd = thisAxInd + 1;
        plot(hAx, xlim(hAx), [plotSliderVals(thisAxInd) plotSliderVals(thisAxInd)],...
          'k-', 'LineWidth',sliderSliceLineWidth, 'Color',[0 0 0 sliderSliceLineAlpha]);
      end
        
      hold(hAx, 'off');
    end
    
    function setTicks()
      maxAxVals = 20;
      axLetters = {'X','Y','Z'};
      
      %     set(hAx,'XTick', axInds{1});
      %     set(hAx,'XTicklabel', axVals{1});
      %     if length(axInds) > 1
      %       set(hAx,'YTick', axInds{2});
      %       set(hAx,'YTicklabel', axVals{2});
      %       if length(axInds) > 2
      %         set(hAx,'ZTick', axInds{3});
      %         set(hAx,'ZTicklabel', axVals{3});
      %       end
      %     end
      
      for axInd = 1:length(axInds)
        thisAxVals = axVals{axInd};
        thisAxInds = axInds{axInd};
        
        set(hAx,[axLetters{axInd} 'Tick'], thisAxInds);
        set(hAx,[axLetters{axInd} 'Ticklabel'], thisAxVals);
      end
      
      % check max ticks
      for axInd = 1:length(axInds)
        thisAxVals = axVals{axInd};
        
        nVals = length(thisAxVals);
        
        if ~isnumeric(thisAxVals)
          % check if strings of numbers
          tempAxVals = str2double(thisAxVals);
          if ~any(isnan(tempAxVals))
            thisAxVals = tempAxVals;
          end
        end
        
        if (nVals > maxAxVals) && isnumeric(thisAxVals) && issorted(thisAxVals, 'monotonic')
          % monotonic and too many values
          thisAxInds = axInds{axInd};
          
          newInds = round(linspace(1, nVals, maxAxVals));
          
          set(hAx,[axLetters{axInd} 'Tick'], thisAxInds(newInds));
          set(hAx,[axLetters{axInd} 'Ticklabel'], thisAxVals(newInds));
        end
      end
    end
    
    function setLims()
      xlim([axInds{1}(1), axInds{1}(end)]);
      try
        % Rescale xlim
        xlims = get(hAx,'xlim');
        set(hAx, 'xlim', [xlims(1)- 0.05*range(xlims) xlims(2)+0.05*range(xlims)]);
      end
      xlabel(axisLabels{1})
      
      if length(axInds) > 1
        ylim([axInds{2}(1), axInds{2}(end)]);
        try
          % Rescale ylim
          ylims = get(hAx,'ylim');
          set(hAx, 'ylim', [ylims(1)- 0.05*range(ylims) ylims(2)+0.05*range(ylims)]);
        end
        ylabel(axisLabels{2})
        
        if length(axInds) > 2
          zlim([axInds{3}(1), axInds{3}(end)]);
          try
            % Rescale zlim
            zlims = get(hAx,'zlim');
            set(hAx, 'zlim', [zlims(1)- 0.05*range(zlims) zlims(2)+0.05*range(zlims)]);
          end
          zlabel(axisLabels{3})
        end
      end
    end
  end


  function shrinkText2Fit(txtH)
    for iTxt=1:length(txtH)
      % Check width
      ex = txtH(iTxt).Extent;
      bigBool = ( (ex(1) + ex(3)) > 1 );
      while bigBool
        txtH(iTxt).FontSize = txtH(iTxt).FontSize * 0.99;
        ex = txtH(iTxt).Extent;
        bigBool = ( (ex(1) + ex(3)) > 1 );
      end
    end
  end

end
