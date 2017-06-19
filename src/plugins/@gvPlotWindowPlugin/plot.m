function plot(pluginObj)

nViewDims = pluginObj.view.dynamic.nViewDims;
nViewDimsLast = pluginObj.view.dynamic.nViewDimsLast;

if ~(nViewDims > 0 && nViewDims ~= nViewDimsLast)
  pluginObj.vprintf('Skipping Plot\n')
  return
end

hFig = pluginObj.handles.fig;
hAx = pluginObj.handles.ax;

nViewDims = pluginObj.view.dynamic.nViewDims;
viewDims = pluginObj.view.dynamic.viewDims;
% nAxDims = pluginObj.plotWindow.nAxDims;
data = pluginObj.controller.activeHypercube;
dimNames = data.axisNames;

% Find labels for categorical data
if isfield(pluginObj.controller.model.data.meta.classes,'Label')
  colors = cat(1,pluginObj.plotWindow.Label.colors{:});
  markers = pluginObj.plotWindow.Label.markers;
  groups = pluginObj.plotWindow.Label.names;
  plotVarNum = pluginObj.plotWindow.Label.varNum;
  plotLabels = data.data{plotVarNum};
end

%% TODO: check axis order correct **********************************************
switch nViewDims
  case 1
    % 1 1d pane
    make1dPlot(hAx)
    
  case 2
    % 1 2d pane
    plotDims = find(viewDims);
    if strcmp(pluginObj.plotWindow.markerType, 'scatter')
        make2dPlot(hAx, plotDims);
    elseif strcmp(pluginObj.plotWindow.markerType, 'pcolor')
      make2dPcolorPlot(hAx, plotDims);
      % FIXME to use pcolor, need to add extra row,col that arent used for
      % color. the x,y,z are the edge points.  uses the first point in C for the
      % interval from 1st point to second point in x,y,z. need to change axis to
      % shift by 50%, then move ticks and tick lables to center of dots, instead
      % of edges of dots
    end
    
  case 3
    % 3 2d panes + 1 3d pane = 4 subplots
    plotDims = find(viewDims);
    
    % 2d plots
    plotDims2d = combnk(plotDims,2);
    for iAx = 1:3
      ax2d = hAx(iAx);
      if strcmp(pluginObj.plotWindow.markerType, 'scatter')
        make2dPlot(ax2d, plotDims2d(iAx,:));
      elseif strcmp(pluginObj.plotWindow.markerType, 'pcolor')
        make2dPcolorPlot(ax2d, plotDims2d(iAx,:));
      end
    end
    
    % 3d plot
    ax3d = hAx(iAx+1);
    if isgraphics(ax3d) && isempty(get(ax3d,'Children'))
      make3dPlot(ax3d, plotDims)
    end
    
  case 4
    % 6 2d panes + 4 3d pane = 10 subplots
  case 5
    % 10 2d panes + 10 3d pane = 20 subplots
  case 6
    % 15 2d panes = 15 subplots
  case 7
    % 21 2d panes = 21 subplots
  case 8
    % 28 2d panes = 28 subplots
end

% hFig.hide_empty_axes;

if nargout > 0
  varargout{1} = handles;
end

%% Sub functions
  function make3dPlot(hAx, plotDims)
    % x dim is plotDims(1)
    % y dim is plotDims(2)
    % z dim is plotDims(2)
    
    axes(hAx)

    sliceInd = pluginObj.plotWindow.axInd;
    sliceInd = num2cell(sliceInd);
    [sliceInd{plotDims}] = deal(':');
    
    % Get grid
    [y,x,z] = meshgrid(data.dimVals{plotDims(2)}, data.dimVals{plotDims(1)}, data.dimVals{plotDims(3)});
      %  meshgrid works differently than the linearization
    g = plotLabels(sliceInd{:});
    
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
    if handles.autoSizeMarkerCheckbox.Value %auto size marker
      set(gca,'unit', 'pixels');
      pos = get(gca,'position');
      axSize = pos(3:4);
      markerSize = min(axSize) / max([length(plotData.x), length(plotData.y), length(plotData.z)]);
      set(gca,'unit', 'normalized');
      plotData.siz = markerSize;
    else %manual size marker
      markerSize = handles.markerSizeSlider.Value;
      plotData.siz = markerSize;
    end
    
    % Set MarkerSize Slider Val
    if isfield(pluginObj.plotWindow, 'sliderH')
      pluginObj.plotWindow.sliderH.Value = markerSize;
      gvMarkerSizeSliderCallback(pluginObj.plotWindow.sliderH,[])
    end
    
    scatter3dPlot(plotData);
    
    axObj = get(gcf,'CurrentAxes');
    axObj.UserData.plotDims = plotDims;
    axObj.UserData.axLabels = dimNames(plotDims);
    axObj.FontSize = 14;
    axObj.FontWeight = 'Bold';
    
%     % Rescale ylim
%     ylims = get(hAx,'ylim');
%     set(hAx, 'ylim', [ylims(1)- 0.05*range(ylims) ylims(2)+0.05*range(ylims)]);
  end
  
  function make2dPlot(hAx, plotDims)
    % x dim is plotDims(1)
    % y dim is plotDims(2)
    
    axes(hAx)
    
    sliceInd = pluginObj.plotWindow.axInd;
    sliceInd = num2cell(sliceInd);
    [sliceInd{plotDims}] = deal(':');
    
    % Get grid
    [y,x] = meshgrid(data.dimVals{plotDims(2)}, data.dimVals{plotDims(1)});
      %  meshgrid works opposite the linearization
    g = plotLabels(sliceInd{:});
    
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
    if handles.autoSizeMarkerCheckbox.Value %auto size marker
      set(gca,'unit', 'pixels');
      pos = get(gca,'position');
      axSize = pos(3:4);
      markerSize = min(axSize) / max(length(plotData.x), length(plotData.y));
      set(gca,'unit', 'normalized');
      plotData.siz = markerSize;
    else %manual size marker
      markerSize = handles.markerSizeSlider.Value;
      plotData.siz = markerSize;
    end
    
    % Set MarkerSize Slider Val
    if isfield(pluginObj.plotWindow, 'sliderH')
      pluginObj.plotWindow.sliderH.Value = markerSize;
      gvMarkerSizeSliderCallback(pluginObj.plotWindow.sliderH,[])
    end
    
    scatter2dPlot(plotData);
    
    % Rescale ylim
    try
      ylims = get(hAx,'ylim');
      set(hAx, 'ylim', [ylims(1)- 0.05*range(ylims) ylims(2)+0.05*range(ylims)]);
    end
    
    axObj = get(gcf,'CurrentAxes');
    axObj.UserData = [];
    axObj.UserData.plotDims = plotDims;
    axObj.UserData.axLabels = dimNames(plotDims);
    axObj.FontSize = 14;
    axObj.FontWeight = 'Bold';
  end

  function make2dPcolorPlot(hAx, plotDims)
    % x dim is plotDims(1)
    % y dim is plotDims(2)
    
    axes(hAx)
    
    sliceInd = pluginObj.plotWindow.axInd;
    sliceInd = num2cell(sliceInd);
    [sliceInd{plotDims}] = deal(':');
    
    % Get grid
    [y,x] = meshgrid(data.dimVals{plotDims(2)}, data.dimVals{plotDims(1)});
      %  meshgrid works opposite the linearization
    g = plotLabels(sliceInd{:});
    
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
    
    axObj = get(gcf,'CurrentAxes');
    axObj.UserData = [];
    axObj.UserData.plotDims = plotDims;
    axObj.UserData.axLabels = dimNames(plotDims);
    axObj.FontSize = 14;
    axObj.FontWeight = 'Bold';
  end

  function make1dPlot(hAx)
    axes(hAx)
    plotDim = find(viewDims);
    sliceInd = pluginObj.plotWindow.axInd;
    sliceInd = num2cell(sliceInd);
    sliceInd{plotDim} = ':';
    
    plotData.xlabel = dimNames{plotDim};
    plotData.x = data.dimVals{plotDim};
    plotData.y = zeros(length(plotData.x),1);
    plotData.ylabel = '';
    plotData.g = plotLabels(sliceInd{:});
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
    if handles.autoSizeMarkerCheckbox.Value %auto size marker
      set(gca,'unit', 'pixels');
      pos = get(gca,'position');
      axSize = pos(3:4);
      markerSize = min(axSize) / length(plotData.x);
      set(gca,'unit', 'normalized');
      plotData.siz = markerSize;
    else %manual size marker
      markerSize = handles.markerSizeSlider.Value;
      plotData.siz = markerSize;
    end
    
%     % Set MarkerSize Slider Val
%     if isfield(pluginObj.plotWindow, 'sliderH')
%       pluginObj.plotWindow.sliderH.Value = markerSize;
%       gvMarkerSizeSliderCallback(pluginObj.plotWindow.sliderH,[])
%     end
    
    scatter2dPlot(plotData);

    set(gca,'YTick', []);
    
    axObj = get(gcf,'CurrentAxes');
    axObj.UserData = [];
    axObj.UserData.plotDims = plotDim;
    axObj.UserData.axLabels = dimNames(plotDim);
    axObj.FontSize = 14;
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

      scatter3(plotData.x, plotData.y, plotData.z, plotData.siz, plotData.clr(groupInd4color,:), '*');
      
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
% %         legend(gca,'boxoff')
% %         legend(gca,'Location','SouthEast')
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
