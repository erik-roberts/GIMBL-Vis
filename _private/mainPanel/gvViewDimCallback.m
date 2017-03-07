function gvViewDimCallback(hObject, eventdata, handles)

vdH = handles.MainPanel.HandlesNames.vdH;
sH = handles.MainPanel.HandlesNames.sH;
svH = handles.MainPanel.HandlesNames.svH;

nAxDims = handles.PlotPanel.nAxDims;
lockedDims = handles.PlotPanel.lockedDims;

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
  wprintf('A max of 8 ViewDims is permitted.')
  nViewDims = nViewDims - 1;
  viewDims(hObject.Tag(end)) = 0;
end

handles.PlotPanel.nViewDims = nViewDims;

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
handles.PlotPanel.viewDims = viewDims;

% Update disabledDims
handles.PlotPanel.disabledDims = disabledDims;

% Update Multi Dim Plot
handles = gvPlotPanel(hObject, eventdata, handles);

% Update nViewDimsLast
handles.PlotPanel.nViewDimsLast = nViewDims;

% Update handles structure
guidata(hObject, handles);

end
