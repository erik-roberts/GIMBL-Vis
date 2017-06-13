function output_txt = dataCursorCallback(src, evnt)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

% TODO

%get studyID
axUserData = evnt.Target.Parent.UserData;
axLabels = axUserData.axLabels;
hMainFig = evnt.Target.Parent.Parent.UserData.MainFigH;
handles = gvHandlesFromFig(hMainFig);

if length(axLabels) >= 1
  xLabel = axLabels{1};
else
  xLabel = 'X';
end

if length(axLabels) >= 2
  yLabel = axLabels{2};
else
  yLabel = 'Y';
end

if length(axLabels) >= 3
  zLabel = axLabels{3};
else
  zLabel = 'Z';
end

pos = get(evnt,'Position');
output_txt = {[xLabel ': ',num2str(pos(1),4)],...
    [yLabel ': ',num2str(pos(2),4)]};

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = [zLabel ': ',num2str(pos(3),4)];
end

% Output simID if stored
if isfield(handles.ImageWindow, 'simID')
  simID = handles.ImageWindow.simID;
  output_txt{end+1} = ['simID: ', num2str(simID)];
end