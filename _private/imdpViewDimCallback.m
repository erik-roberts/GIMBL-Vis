function imdpViewDimCallback(hObject, eventdata, handles)

vdH = handles.lists.vdH;
sH = handles.lists.sH;
svH = handles.lists.svH;

% Determine number of checked ViewDim boxes
nViewDims = 0;
viewDims = [];

for hInd = 1:handles.PlotPanel.nAxDims
  nViewDims = nViewDims + handles.(vdH{hInd}).Value;
  viewDims(end+1) = handles.(vdH{hInd}).Value;
  if handles.(vdH{hInd}).Value
    handles.(sH{hInd}).Enable = 'off';
    handles.(svH{hInd}).Enable = 'off';
  else
    handles.(sH{hInd}).Enable = 'on';
    handles.(svH{hInd}).Enable = 'on';
  end
end
handles.PlotPanel.nViewDims = nViewDims;

if nViewDims > 8
  hObject.Value = 0;
  wprintf('A max of 8 ViewDims is permitted.')
  nViewDims = nViewDims - 1;
  handles.PlotPanel.nViewDims = nViewDims;
end

% Update viewDims
handles.PlotPanel.viewDims = viewDims;

% Update Multi Dim Plot
handles = imdpPlotPanel(hObject, eventdata, handles);

% Update nViewDimsLast
handles.PlotPanel.nViewDimsLast = nViewDims;

% Update handles structure
guidata(hObject, handles);

end
