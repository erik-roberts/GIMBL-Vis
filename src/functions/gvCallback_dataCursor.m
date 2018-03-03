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
axValues = hypercubeObj.axisValues;
axValues = axValues(axDims);

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
if length(pos) > 1
  yVal = axValues{2}(pos(2));
  output_txt{end+1} = [yLabel ': ',num2str(yVal, 4)];
end

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
  zVal = axValues{3}(pos(3));
  output_txt{end+1} = [zLabel ': ',num2str(zVal, 4)];
end

% Output imageIndex if stored
if isfield(pluginObj.metadata, 'imageIndex')
  imageIndex = pluginObj.metadata.imageIndex;
  output_txt{end+1} = ['imageIndex: ', num2str(imageIndex)];
end

end