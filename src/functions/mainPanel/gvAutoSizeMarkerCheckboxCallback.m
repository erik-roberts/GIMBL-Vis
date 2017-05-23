function gvAutoSizeMarkerCheckboxCallback(hObject, eventdata, handles)

% Enable/Disable marker size slider based on state of autoSize checkbox
if hObject.Value % auto on
  handles.markerSizeSlider.Enable = 'off';
else % auto off
  handles.markerSizeSlider.Enable = 'on';
end

gvPlot(hObject, eventdata, handles);

end