function gvLockDimCallback(hObject, eventdata, handles)

ldH = handles.MainWindow.Handles.ldH;
sH = handles.MainWindow.Handles.sH;
svH = handles.MainWindow.Handles.svH;

nAxDims = handles.PlotWindow.nAxDims;
nViewDims = handles.PlotWindow.nViewDims;
viewDims = handles.PlotWindow.viewDims;

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
handles.PlotWindow.lockedDims = logical(lockedDims);

% Update disabledDims
handles.PlotWindow.disabledDims = disabledDims;

% Update nLockDimsLast
handles.PlotWindow.nLockedDimsLast = nLockedDims;

% Update handles structure
guidata(hObject, handles);

end
