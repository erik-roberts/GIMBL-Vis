function Callback_mouseMove(src, evnt)

plotFig = src;
plotPluginObj = plotFig.UserData.pluginObj;
imagePluginObj = plotPluginObj.controller.guiPlugins.image;

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
      % to find 3d point, need to use camera angle and ray trace
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
      % strategy
      % filter all points based on range of x, y, z and next point around it
      % this gives cube of points around line
      % then find distance by finding e = b - p = b - (a.*b)/a.^2 .* a or make b a
      % but need to find front point
      
      a = diff(mouseAxPosIndScale);
      
      objVals = size(hypercubeObj);
      objVals = objVals(plotDims);
      objVals = arrayfun(@(x) 1:x, objVals, 'uni',0);
      [bx, by, bz] = meshgrid(objVals{:});
      bx = bx(:);
      by = by(:);
      bz = bz(:);
      b = [bx, by, bz];
      bVec = bsxfun(@minus, b, mouseAxPosIndScale(1,:));
      
      proj = bVec - bsxfun(@times, bsxfun(@times, a, bVec)./a.^2, a);
      proj = sum(proj .* proj, 2);
      
      [~, ind] = min(proj);
      
      vals = b(ind, :);
    end
    
    
    % get hypercube data
    hypercubeObj = plotPluginObj.controller.activeHypercube;
    axesType = gvGetAxisType(hypercubeObj);
    if ~isempty(axesType)
      % check for axisType = 'dataType'
      dataTypeAxInd = find(strcmp(axesType, 'dataType'), 1);
      
      if isempty(dataTypeAxInd)
        plotPluginObj.vprintf('[gvImageWindowPlugin] Cannot find dataType axis.\n');
        return
      end
    else
      plotPluginObj.vprintf('[gvImageWindowPlugin] Cannot find any axis types.\n');
      return
    end
    
    % find corresponding index
    indexAxInd = find(strcmp(plotPluginObj.controller.activeHypercube.axis(dataTypeAxInd).axismeta.dataType, 'index'),1);
    sliderVals = plotPluginObj.view.dynamic.sliderVals;
    sliderVals(dataTypeAxInd) = indexAxInd; % set sliderVals dataType axis number to axis position for hypercube index.
    if length(plotDims) == 3 % 3D
      sliderVals(plotDims) = mouseAxPosIndScale; % set sliderVals plot dims to closest point to mouse
    elseif length(plotDims) == 2 % 2D
      sliderVals(plotDims) = mouseAxPosIndScale(1:2); % set sliderVals plot dims to closest point to mouse
    else % 1D
      sliderVals(plotDims) = mouseAxPosIndScale(1); % set sliderVals plot dims to closest point to mouse
    end
    
    % get image index from slider vals
    sliderVals = num2cell(sliderVals); % convert to cell for indexing
    try
      imageIndex = hypercubeObj.data(sliderVals{:});
      if iscell(imageIndex)
        imageIndex = imageIndex{1};
      end
      if ischar(imageIndex)
        imageIndex = str2double(imageIndex);
      end
      
      % store image index
      plotPluginObj.metadata.imageIndex = imageIndex;
      
      try
        % show image
        if ~isempty(imageIndex)
          imagePluginObj.showImage(imageIndex);
        end
      end
    end
     % TODO: % check if distance to nearest point is < x% of axis size
  end
end

end
