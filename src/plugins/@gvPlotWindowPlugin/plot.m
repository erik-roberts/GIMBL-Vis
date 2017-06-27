function plot(pluginObj)

% TODO
% - fn on celsl
% - hypercube scale colormap

% Dev notes:
%  Data Type Strategy:
%   - check if all data is numeric
%   - check if slice or hypercube numeric scale
%   - if mixed, set non-numeric to nans
%   - if only non-numeric, get legend info

hFig = pluginObj.handles.fig;
hAx = pluginObj.handles.ax;
figure(hFig); % make hFig gcf

nViewDims = pluginObj.view.dynamic.nViewDims;
viewDims = pluginObj.view.dynamic.viewDims;

fontSize = pluginObj.view.fontSize;

hypercubeObj = pluginObj.controller.activeHypercube;
dimNames = hypercubeObj.axisNames;
dimNames = strrep(dimNames, '_', ' '); % replace '_' with ' ' to avoid subscript
sliderVals = pluginObj.view.dynamic.sliderVals;

makeAllSubplots();


%% Nested functions
  function makeAllSubplots()
    switch nViewDims
      case 1
        % 1 1d pane
        plotDim = find(viewDims);
%         make1dPlot(hAx)
        makeSubplot(@make1dPlot, hAx, plotDim);
        
      case 2
        % 1 2d pane
        plotDims = find(viewDims);
        %     if strcmp(pluginObj.plotWindow.markerType, 'scatter')
        makeSubplot(@make2dPlot, hAx, plotDims);
        %     elseif strcmp(pluginObj.plotWindow.markerType, 'pcolor')
        %       make2dPcolorPlot(hAx, plotDims);
        
        % TODO to use pcolor, need to add extra row,col that arent used for
        % color. the x,y,z are the edge points.  uses the first point in C for the
        % interval from 1st point to second point in x,y,z. need to change axis to
        % shift by 50%, then move ticks and tick lables to center of dots, instead
        % of edges of dots
        %     end
        
      case {3,4,5}
        % 3D: 3 2d panes + 1 3d pane = 4 subplots
        % 4D: 6 2d panes + 4 3d pane = 10 subplots
        % 5D: 10 2d panes + 10 3d pane = 20 subplots
        
        plotDims = find(viewDims);
        
        % 2d plots
        plotDims2d = sort(combnk(plotDims,2));
        for iAx2d = 1:size(plotDims2d, 1)
          ax2d = hAx(iAx2d);
          %       if strcmp(pluginObj.plotWindow.markerType, 'scatter')
          makeSubplot(@make2dPlot, ax2d, plotDims2d(iAx2d,:));
          %       elseif strcmp(pluginObj.plotWindow.markerType, 'pcolor')
          %         make2dPcolorPlot(ax2d, plotDims2d(iAx,:));
          %       end
        end
        
        % 3d plot
        plotDims3d = sort(combnk(plotDims,3));
        
        for iAx3d = iAx2d+1:iAx2d+size(plotDims3d, 1)
          ax3d = hAx(iAx3d);
%           if isgraphics(ax3d) && isempty(get(ax3d,'Children'))
            makeSubplot(@make3dPlot, ax3d, plotDims3d(iAx3d-iAx2d,:))
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
          %       if strcmp(pluginObj.plotWindow.markerType, 'scatter')
          makeSubplot(@make2dPlot, ax2d, plotDims2d(iAx2d,:));
          %       elseif strcmp(pluginObj.plotWindow.markerType, 'pcolor')
          %         make2dPcolorPlot(ax2d, plotDims2d(iAx,:));
          %       end
        end
    end
    
    hideEmptyAxes(hFig);
    
  end


  function makeSubplot(plotFn, hAx, plotDims)
    set(hFig,'CurrentAxes', hAx);
    
    sliceInds = sliderVals;
    sliceInds = num2cell(sliceInds);
    [sliceInds{plotDims}] = deal(':');
    plotSlice = squeeze(hypercubeObj.data(sliceInds{:}));
    
    if hypercubeObj.meta.onlyNumericDataBool
      anyNumBool = true;
    else
      % check if any numeric in slice
      numInds = cellfun(@isnumeric, plotSlice);
      
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
    
    % make plot
    if anyNumBool
%       feval(plotFn, hAx, plotDims, plotSlice);
      makePlot(hAx, plotDims, plotSlice);
    else
%       feval(plotFn, hAx, plotDims, plotSlice, legendInfo);
      makePlot(hAx, plotDims, plotSlice, legendInfo);
    end
  end


  function makePlot(hAx, plotDims, plotSlice, legendInfo)
    if nargin<4
      legendInfo = [];
    end

    axVals = arrayfun(@getValsForAxis, plotDims,'Uni',0);
    
    if length(axVals) == 3
      axValsVector = cell(1, length(axVals));
      [axValsVector{:}] = meshgrid(axVals{2}, axVals{1}, axVals{3});
    elseif length(axVals) == 2
      axValsVector = cell(1, length(axVals));
      [axValsVector{:}] = meshgrid(axVals{2}, axVals{1});
    else % turn 1D into 2D
      axValsVector{1} = axVals{1};
      axValsVector{2} = axValsVector{1}*0;
    end
    
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
    
    axisLabels = dimNames(plotDims);

    % Marker Size
    markerSizeSlider = findobjReTag('plot_panel_markerSizeSlider');
    autoSizeMarkerCheckboxHandle = findobjReTag('plot_panel_autoSizeToggle');
    if autoSizeMarkerCheckboxHandle.Value %auto size marker
      axUnit = get(hAx,'unit');
      set(hAx,'unit', 'pixels');
      pos = get(hAx,'position');
      axSize = pos(3:4);
      markerSize = min(axSize) / max(cellfun(@length, axVals));
      set(hAx,'unit', axUnit);
    else %manual size marker
      markerSize = markerSizeSlider.Value;
    end
    
    % scatter plot
    if isempty(legendInfo) % numerical mat
      if 1% strcmp(pluginObj.controller.app.config.plotColormapScope, 'slice') TODO
        if length(axVals) < 3
          scatter(axValsVector{:}, markerSize, plotSlice, 'filled'); % slice specific colormap
          colorbar;
        else
          scatter3(axValsVector{:}, markerSize, plotSlice, 'filled'); % slice specific colormap
          colorbar
        end
      end
    else % categorical cells
      groups = legendInfo.groups;
      colors = legendInfo.colors;
      markers = legendInfo.markers;
      
      [~, gInd] = ismember(plotSlice, groups);

      if length(axVals) < 3
        scatter(axValsVector{:}, markerSize, colors(gInd,:), 'filled'); % slice specific colormap
      else
        scatter3(axValsVector{:}, markerSize, colors(gInd,:), 'filled'); % slice specific colormap
      end
    end
    
    % Remove 1D y axis
    if length(axVals) == 1
      set(hAx,'YTick', []);
    end
    
    % lims
    xlim([min(axValsVector{1}), max(axValsVector{1})]);
    % Rescale xlim
    try
      xlims = get(hAx,'xlim');
      set(hAx, 'xlim', [xlims(1)- 0.05*range(xlims) xlims(2)+0.05*range(xlims)]);
    end
    xlabel(axisLabels{1})
    
    if length(axVals) > 1
      ylim([min(axValsVector{2}), max(axValsVector{2})]);
      % Rescale ylim
      try
        ylims = get(hAx,'ylim');
        set(hAx, 'ylim', [ylims(1)- 0.05*range(ylims) ylims(2)+0.05*range(ylims)]);
      end
      ylabel(axisLabels{2})
      
      if length(axVals) > 2
        zlim([min(axValsVector{3}), max(axValsVector{3})]);
        % Rescale zlim
        try
          zlims = get(hAx,'zlim');
          set(hAx, 'zlim', [zlims(1)- 0.05*range(zlims) zlims(2)+0.05*range(zlims)]);
        end
        zlabel(axisLabels{3})
      end
    end
    
    hAx.FontSize = fontSize;
    
    
    %% Nested fn
    function vals = getValsForAxis(x)
      vals = hypercubeObj.axisValues{x};
    end
    
    function x = linearize(x)
      x = x(:);
    end
    
    function x = removeEmpty(x)
      x(emptyCells) = [];
    end
  end


  function make3dPlot(hAx, plotDims, plotSlice)
    % x dim is plotDims(1)
    % y dim is plotDims(2)
    % z dim is plotDims(2)

    % ax vals
    xVals = hypercubeObj.axisValues{plotDims(1)};
    yVals = hypercubeObj.axisValues{plotDims(2)};
    zVals = hypercubeObj.axisValues{plotDims(3)};
    
    % Get grid
    [y,x,z] = meshgrid(yVals, xVals, zVals);
      %  meshgrid works differently than the linearization
    g = plotSlice;
    
    % Linearize grid
    x = x(:)';
    y = y(:)';
    z = z(:)';
    g = g(:)';
    
    % Remove empty points
    emptyCells = cellfun(@isempty,g);
    x(emptyCells) = [];
    y(emptyCells) = [];
    z(emptyCells) = [];
    g(emptyCells) = [];
    
    plotData.x = x;
    plotData.xlabel = dimNames{plotDims(1)};
    
    plotData.y = y;
    plotData.ylabel = dimNames{plotDims(2)};
    
    plotData.z = z;
    plotData.zlabel = dimNames{plotDims(3)};
    
    plotData.g = g;
    
    plotData.clr = [];
    plotData.sym = '';
    for grp = unique(plotData.g)
      gInd = strcmp(groups, grp);
      thisClr = colors(gInd,:);
      thisSym = markers{gInd};
      plotData.clr(end+1,:) = thisClr;
      plotData.sym = [plotData.sym thisSym];
    end

  % Marker Size
    markerSizeSlider = findobjReTag('plot_panel_markerSizeSlider');
    autoSizeMarkerCheckboxHandle = findobjReTag('plot_panel_autoSizeToggle');
    if autoSizeMarkerCheckboxHandle.Value %auto size marker
      axUnit = get(hAx,'unit');
      set(hAx,'unit', 'pixels');
      pos = get(hAx,'position');
      axSize = pos(3:4);
      markerSize = min(axSize) / max([length(xVals), length(yVals), length(zVals)]);
      plotData.siz = markerSize;
      set(hAx,'unit', axUnit);
    else %manual size marker
      markerSize = markerSizeSlider.Value;
      plotData.siz = markerSize;
    end
    
    scatter3dPlot(plotData);
    
    % lims
    xlim([min(xVals), max(xVals)]);
    ylim([min(yVals), max(yVals)]);
    zlim([min(zVals), max(zVals)]);
    
    % Rescale xlim
    try
      xlims = get(hAx,'xlim');
      set(hAx, 'xlim', [xlims(1)- 0.05*range(xlims) xlims(2)+0.05*range(xlims)]);
    end
    
    % Rescale ylim
    try
      ylims = get(hAx,'ylim');
      set(hAx, 'ylim', [ylims(1)- 0.05*range(ylims) ylims(2)+0.05*range(ylims)]);
    end
    
    % Rescale zlim
    try
      zlims = get(hAx,'zlim');
      set(hAx, 'zlim', [zlims(1)- 0.05*range(zlims) zlims(2)+0.05*range(zlims)]);
    end
    
    axObj = get(hFig,'CurrentAxes');
    axObj.UserData.plotDims = plotDims;
    axObj.UserData.axLabels = dimNames(plotDims);
    axObj.FontSize = fontSize;
    axObj.FontWeight = 'Bold';
  end

  
  function make2dPlot(hAx, plotDims, plotSlice)
    % x dim is plotDims(1)
    % y dim is plotDims(2)

    % ax vals
    xVals = hypercubeObj.axisValues{plotDims(1)};
    yVals = hypercubeObj.axisValues{plotDims(2)};
    
    % Get grid
    [y,x] = meshgrid(yVals, xVals);
      %  meshgrid works opposite the linearization
    g = plotSlice;
    
    % Linearize grid
    x = x(:)';
    y = y(:)';
    g = g(:)';
    
    % Remove empty points
    emptyCells = cellfun(@isempty,g);
    x(emptyCells) = [];
    y(emptyCells) = [];
    g(emptyCells) = [];
    
    plotData.x = x;
    plotData.xlabel = dimNames{plotDims(1)};
    
    plotData.y = y;
    plotData.ylabel = dimNames{plotDims(2)};
    
    plotData.g = g;
    
    plotData.clr = [];
    plotData.sym = '';
    for grp = unique(plotData.g)
      gInd = strcmp(groups, grp);
      thisClr = colors(gInd,:);
      thisSym = markers{gInd};
      plotData.clr(end+1,:) = thisClr;
      plotData.sym = [plotData.sym thisSym];
    end
    
    % Marker Size
    markerSizeSlider = findobjReTag('plot_panel_markerSizeSlider');
    autoSizeMarkerCheckboxHandle = findobjReTag('plot_panel_autoSizeToggle');
    if autoSizeMarkerCheckboxHandle.Value %auto size marker
      axUnit = get(hAx,'unit');
      set(hAx,'unit', 'pixels');
      pos = get(hAx,'position');
      axSize = pos(3:4);
      markerSize = min(axSize) / max(length(xVals), length(yVals));
      plotData.siz = markerSize;
      set(hAx,'unit', axUnit);
    else %manual size marker
      markerSize = markerSizeSlider.Value;
      plotData.siz = markerSize;
    end
    
    % Set MarkerSize Slider Val
    markerSizeSlider.Value = markerSize;
    
    scatter2dPlot(plotData);
    
    % lims
    xlim([min(xVals), max(xVals)]);
    ylim([min(yVals), max(yVals)]);
    
    % Rescale xlim
    try
      xlims = get(hAx,'xlim');
      set(hAx, 'xlim', [xlims(1)- 0.05*range(xlims) xlims(2)+0.05*range(xlims)]);
    end
    
    % Rescale ylim
    try
      ylims = get(hAx,'ylim');
      set(hAx, 'ylim', [ylims(1)- 0.05*range(ylims) ylims(2)+0.05*range(ylims)]);
    end
    
    axObj = get(hFig,'CurrentAxes');
    axObj.UserData = [];
    axObj.UserData.plotDims = plotDims;
    axObj.UserData.axLabels = dimNames(plotDims);
    axObj.FontSize = fontSize;
    axObj.FontWeight = 'Bold';
  end


  function make2dPcolorPlot(hAx, plotDims, plotSlice)
    % x dim is plotDims(1)
    % y dim is plotDims(2)

    % Get grid
    [y,x] = meshgrid(hypercubeObj.dimVals{plotDims(2)}, hypercubeObj.dimVals{plotDims(1)});
      %  meshgrid works opposite the linearization
    g = plotSlice;
    
%     % Linearize grid
%     x = x(:)';
%     y = y(:)';
%     g = g(:)';
    
    % Remove empty points
%     emptyCells = cellfun(@isempty,g);
%     x(emptyCells) = [];
%     y(emptyCells) = [];
%     g(emptyCells) = [];
    
%     plotData.x = x;
%     plotData.xlabel = dimNames{plotDims(1)};
    
%     plotData.y = y;
%     plotData.ylabel = dimNames{plotDims(2)};
    
%     plotData.g = g;
    
    grpNumeric = nan(size(g));
    for iG = 1:length(groups)
      gInd = strcmp(groups, groups{iG});
      grpNumeric(gInd) = iG;
    end
    
    % add extra row and col to x,y,g
    x(end+1,:) = x(end,:);
    x(:,end+1) = x(:,end);
    y(end+1,:) = y(end,:);
    y(:,end+1) = y(:,end);
    grpNumeric(end+1,:) = grpNumeric(end,:);
    grpNumeric(:,end+1) = grpNumeric(:,end);
    
    %add min and max values for colormap to work
    grpNumeric(end,1:2) = [1, length(groups)];

    % Plot
    colormap(colors)
    pcolor(hAx, x,y,grpNumeric)
    xlabel(dimNames{plotDims(1)})
    ylabel(dimNames{plotDims(2)})
    
    axObj = get(hFig,'CurrentAxes');
    axObj.UserData = [];
    axObj.UserData.plotDims = plotDims;
    axObj.UserData.axLabels = dimNames(plotDims);
    axObj.FontSize = fontSize;
    axObj.FontWeight = 'Bold';
  end


  function make1dPlot(hAx, plotDim, plotSlice)
    % ax vals
    xVals = hypercubeObj.axisValues{plotDim};
    
    plotData.xlabel = dimNames{plotDim};
    plotData.x = hypercubeObj.axisValues{plotDim};
    plotData.y = zeros(length(plotData.x),1);
    plotData.ylabel = '';
    plotData.g = plotSlice;
    plotData.g = plotData.g(:)';
    
    % Remove empty points
    emptyCells = cellfun(@isempty,plotData.g);
    plotData.x(emptyCells) = [];
    plotData.y(emptyCells) = [];
    plotData.g(emptyCells) = [];
    
    plotData.clr = [];
    plotData.sym = '';
    for grp = unique(plotData.g)
      gInd = strcmp(groups, grp);
      thisClr = colors(gInd,:);
      thisSym = markers{gInd};
      plotData.clr(end+1,:) = thisClr;
      plotData.sym = [plotData.sym thisSym];
    end
    
    % Marker Size
    markerSizeSlider = findobjReTag('plot_panel_markerSizeSlider');
    autoSizeMarkerCheckboxHandle = findobjReTag('plot_panel_autoSizeToggle');
    if autoSizeMarkerCheckboxHandle.Value %auto size marker
      axUnit = get(hAx,'unit');
      set(hAx,'unit', 'pixels');
      pos = get(hAx,'position');
      axSize = pos(3:4);
      markerSize = min(axSize) / length(xVals);
      plotData.siz = markerSize;
      set(hAx,'unit', axUnit);
    else %manual size marker
      markerSize = markerSizeSlider.Value;
      plotData.siz = markerSize;
    end
    
    % Set MarkerSize Slider Val
    markerSizeSlider.Value = markerSize;
    
    scatter2dPlot(plotData);
    
    % lims
    xlim([min(hypercubeObj.axisValues{plotDim}), max(hypercubeObj.axisValues{plotDim})]);
    
    % Rescale xlim
    try
      xlims = get(hAx,'xlim');
      set(hAx, 'xlim', [xlims(1)- 0.05*range(xlims) xlims(2)+0.05*range(xlims)]);
    end

    set(hAx,'YTick', []);
    
    axObj = get(hFig,'CurrentAxes');
    axObj.UserData = [];
    axObj.UserData.plotDims = plotDim;
    axObj.UserData.axLabels = dimNames(plotDim);
    axObj.FontSize = fontSize;
    axObj.FontWeight = 'Bold';
  end


  function scatter2dPlot(plotData)
    try
      gscatter(plotData.x,plotData.y,categorical(plotData.g),plotData.clr,plotData.sym,plotData.siz,'off',plotData.xlabel,plotData.ylabel)
    end
  end


  function scatter3dPlot(plotData)
    %     [uniqueGroups, uga, ugc] = unique(group);
    %     colors = colormap;
    %     markersize = 20;
    %     scatter3(x(:), y(:), z(:), markersize, colors(ugc,:));
    
    try
      [~, ~, groupInd4color] = unique(plotData.g);
      
%       plotData.sym

      scatter3(plotData.x, plotData.y, plotData.z, plotData.siz, plotData.clr(groupInd4color,:), '.');
      
      xlabel(plotData.xlabel)
      ylabel(plotData.ylabel)
      zlabel(plotData.zlabel)
      
%       if handles.MainWindow.legendBool
%         uG = unique(plotData.g);
%         [lH,icons] = legend(uG); % TODO: hide legend before making changes   
% 
%         % Increase legend width
%     %     lPos = lH.Position;
%     %     lPos(3) = lPos(3) * 1.05; % increase width of legend
%     %     lH.Position = lPos;
% 
%         [icons(1:length(uG)).FontSize] = deal(lFontSize);
%         [icons(1:length(uG)).FontUnits] = deal('normalized');
% 
%         shrinkText2Fit(icons(1:length(uG)))
% 
%         [icons(length(uG)+2:2:end).MarkerSize] = deal(lMarkerSize);
%         
% %         legend(hFig,'boxoff')
% %         legend(hFig,'Location','SouthEast')
%       end
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
