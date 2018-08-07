function output_txt = gvCallback_dataCursor(src, evnt)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pluginObj= evnt.Target.Parent.Parent.UserData.pluginObj;
hypercubeObj = pluginObj.controller.activeHypercube;

% get ax info
axUserData = evnt.Target.Parent.UserData;
axLabels = axUserData.axLabels;
axDims = axUserData.plotDims;
allAxValues = hypercubeObj.axisValues;
axValues = allAxValues(axDims);

if length(axLabels) >= 1
  xLabel = ['X (' strrep(axLabels{1}, '\_', '_') ')'];
else
  xLabel = 'X';
end

if length(axLabels) >= 2
  yLabel = ['Y (' strrep(axLabels{2}, '\_', '_') ')'];
else
  yLabel = 'Y';
end

if length(axLabels) >= 3
  zLabel = ['Z (' strrep(axLabels{3}, '\_', '_') ')'];
else
  zLabel = 'Z';
end

pos = get(evnt,'Position');

xVal = axValues{1}(pos(1));
output_txt = {[xLabel ': ',num2str(xVal, 4)]};


% If there is a Y-coordinate in the position, display it as well
if length(axDims) > 1
  yVal = axValues{2}(pos(2));
  output_txt{end+1} = [yLabel ': ',num2str(yVal, 4)];
end

% If there is a Z-coordinate in the position, display it as well
if length(axDims) > 2
  zVal = axValues{3}(pos(3));
  output_txt{end+1} = [zLabel ': ',num2str(zVal, 4)];
end

% Output imageIndex if stored
if isfield(pluginObj.metadata, 'imageIndex')
  imageIndex = pluginObj.metadata.imageIndex;
  output_txt{end+1} = ['imageIndex: ', num2str(imageIndex)];
end

% Value at position
try
  axesType = gvGetAxisType(hypercubeObj);
  
  % check for axisType = 'dataType'
  dataTypeAxInd = find(strcmp(axesType, 'dataType'), 1);
  
  dataTypeVal = pluginObj.view.dynamic.sliderVals(dataTypeAxInd);
  
  dataType = allAxValues{dataTypeAxInd}{dataTypeVal};
  
  thisVals = pluginObj.view.dynamic.sliderVals;
  thisVals(axDims(1)) = pos(1);
  if length(axDims) > 1
    thisVals(axDims(2)) = pos(2);
  end
  if length(axDims) > 2
    thisVals(axDims(3)) = pos(3);
  end
  thisVals = num2cell(thisVals);
  
  dataVal = hypercubeObj.data(thisVals{:}); % works for cell and mat
  
  if iscell(dataVal)
    dataVal = dataVal{1};
  end
  
  if isnumeric(dataVal)
    dataVal = num2str(dataVal);
  elseif iscategorical(dataVal)
    dataVal = char(dataVal);
  end
  
  output_txt{end+1} = [dataType ': ' dataVal];
end

end