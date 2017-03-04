function gvMarkerTypeMenuCallback(hObject, eventdata, handles)

% if new val, then replot
if hObject.UserData.lastVal ~= hObject.Value
  handles.PlotPanel.markerType = hObject.String{hObject.Value};
  gvPlot(hObject, eventdata, handles);
end

%Update last value
hObject.UserData.lastVal = hObject.Value;

% Update handles structure
guidata(hObject, handles);

end