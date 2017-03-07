function gvLockDimCallback(hObject, eventdata, handles)

ldH = handles.MainPanel.Handles.ldH;
sH = handles.MainPanel.Handles.sH;
svH = handles.MainPanel.Handles.svH;

nAxDims = handles.PlotPanel.nAxDims;
nViewDims = handles.PlotPanel.nViewDims;
viewDims = handles.PlotPanel.viewDims;

% Determine number of checked locked boxes
nLockedDims = 0;
lockedDims = [];

for hInd = 1:nAxDims
  nLockedDims = nLockedDims + ldH(hInd).Value;
  lockedDims(end+1) = ldH(hInd).Value;
end

% Disable sliders when all data is shown (dim < 3)
axDims = 1:nAxDims;
if any(nViewDims == [1,2])
  disabledDims = logical(lockedDims + viewDims);
else
  disabledDims = logical(lockedDims);
end

for hInd = axDims(disabledDims)
  sH(hInd).Enable = 'off';
  svH(hInd).Enable = 'off';
end

for hInd = axDims(~disabledDims)
  sH(hInd).Enable = 'on';
  svH(hInd).Enable = 'on';
end

% Update lockedDims
handles.PlotPanel.lockedDims = logical(lockedDims);

% Update disabledDims
handles.PlotPanel.disabledDims = disabledDims;

% Update nLockDimsLast
handles.PlotPanel.nLockedDimsLast = nLockedDims;

% Update handles structure
guidata(hObject, handles);

end
