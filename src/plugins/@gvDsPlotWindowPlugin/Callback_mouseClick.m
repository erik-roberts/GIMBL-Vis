function Callback_mouseClick(src, evnt)

if ~strcmp(evnt.EventName, 'WindowMousePress') % not mouse click
  return
end

plotFig = src;
plotPluginObj = plotFig.UserData.pluginObj;
dsPlotPluginObj = plotPluginObj.controller.guiPlugins.dsPlot;

if plotPluginObj.checkWindowExists() && plotPluginObj.view.dynamic.nViewDims > 0
  
  mousePosPx = get(plotFig, 'CurrentPoint'); %pixels
  figPos = plotFig.Position;
%   mousePosRel = mousePosPx ./ figPos(3:4); %relative
  
  % Get all axes
  ax = findobj(plotFig.Children,'type','axes');
  
  axPos = cat(1,ax.Position);
  
  % Find Positions of LL and UR corners for each ax
  axLLx  = axPos(:,1)*figPos(3);
  axLLy  = axPos(:,2)*figPos(4);
  axURx  = (axPos(:,1)+axPos(:,3))*figPos(3);
  axURy  = (axPos(:,2)+axPos(:,4))*figPos(4);
  
  % determine which axis
  axInd = find((mousePosPx(1)>=axLLx) .* (mousePosPx(1)<=axURx) .* (mousePosPx(2)>=axLLy) .* (mousePosPx(2)<=axURy));
  
  if ~isempty(axInd)
    currAx = ax(axInd);
    
    % get mouse position
    mouseAxPosIndScale = get(currAx, 'CurrentPoint'); %in axis scale
      % Dev note: returns the points into and out of the plot volume
    mouseAxPosIndScale = mouseAxPosIndScale(1,:);
    if mouseAxPosIndScale(3) ~= 1 %in 3d scale
      return
    end
    mouseAxPosIndScale = mouseAxPosIndScale(1:2);
    mouseAxPosIndScale = round(mouseAxPosIndScale); % round
    
    try
      plotDims = currAx.UserData.plotDims;
      nPlotDims = length(plotDims);
    catch
      return % in case axis is deleted
    end
    if nPlotDims > 2 %only 1d or 2d
      return
    end
    
    
    % get hypercube data
    hypercubeObj = plotPluginObj.controller.activeHypercube;
    axesType = gvGetAxisType(hypercubeObj);
    if ~isempty(axesType)
      % check for axisType = 'dataType'
      dataTypeAxInd = find(strcmp(axesType, 'dataType'), 1);
      
      if isempty(dataTypeAxInd)
        plotPluginObj.vprintf('gvDsPlotWindowPlugin: Cannot find dataType axis.\n');
        return
      end
    else
      plotPluginObj.vprintf('gvDsPlotWindowPlugin: Cannot find any axis types.\n');
      return
    end
    
    % find corresponding index
    indexAxInd = find(strcmp(plotPluginObj.controller.activeHypercube.axis(dataTypeAxInd).axismeta.dataType, 'index'),1);
    sliderVals = plotPluginObj.view.dynamic.sliderVals;
    sliderVals(dataTypeAxInd) = indexAxInd; % set sliderVals dataType axis number to axis position for hypercube index.
    sliderVals(plotDims) = mouseAxPosIndScale; % set sliderVals plot dims to closest point to mouse
    
    % get image index from slider vals
    sliderVals = num2cell(sliderVals); % convert to cell for indexing
    dataIndex = hypercubeObj.data(sliderVals{:});
    if iscell(dataIndex)
      dataIndex = dataIndex{1};
    end
    if ischar(dataIndex)
      dataIndex = str2double(dataIndex);
    end
    
    % plot data
    if ~isempty(dataIndex) && (dataIndex ~= dsPlotPluginObj.lastIndex)
      if ~isempty(dsPlotPluginObj.fig2copy)
        return
      end
      dsPlotPluginObj.plotData(dataIndex);
    end
    
     % TODO: % check if distance to nearest point is < x% of axis size
  end
end

end
