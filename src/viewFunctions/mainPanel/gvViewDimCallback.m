function gvViewDimCallback(hObject, eventdata, handles)

vdH = handles.MainWindow.HandlesNames.vdH;
sH = handles.MainWindow.HandlesNames.sH;
svH = handles.MainWindow.HandlesNames.svH;

nAxDims = handles.PlotWindow.nAxDims;
lockedDims = handles.PlotWindow.lockedDims;

% Determine number of checked ViewDim boxes
nViewDims = 0;
viewDims = [];

for hInd = 1:nAxDims
  nViewDims = nViewDims + handles.(vdH{hInd}).Value;
  viewDims(end+1) = handles.(vdH{hInd}).Value;
end

% Check number of ViewDims
if nViewDims > 3
  hObject.Value = 0;
  wprintf('A max of 3 ViewDims is permitted at this time.')
  nViewDims = nViewDims - 1;
  viewDims(str2double(hObject.Tag(end))) = 0;
end

handles.PlotWindow.nViewDims = nViewDims;

% Disable sliders when all data is shown (dim < 3)
axDims = 1:nAxDims;
if nViewDims < 3
  disabledDims = viewDims;
else
  disabledDims = zeros(size(viewDims));
end
disabledDims = logical(disabledDims + lockedDims); % add in lockedDims

for hInd = axDims(disabledDims)
  handles.(sH{hInd}).Enable = 'off';
  handles.(svH{hInd}).Enable = 'off';
end

for hInd = axDims(~disabledDims)
  handles.(sH{hInd}).Enable = 'on';
  handles.(svH{hInd}).Enable = 'on';
end

% Update viewDims
handles.PlotWindow.viewDims = viewDims;

% Update disabledDims
handles.PlotWindow.disabledDims = disabledDims;

% Update Multi Dim Plot
handles = gvPlotWindow(hObject, eventdata, handles);

% Update nViewDimsLast
handles.PlotWindow.nViewDimsLast = nViewDims;

% Update handles structure
guidata(hObject, handles);

end
