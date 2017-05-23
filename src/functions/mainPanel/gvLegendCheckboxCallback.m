function gvLegendCheckboxCallback(hObject, eventdata, handles)

if hObject.Value
  handles.MainPanel.legendBool = true;
else
  handles.MainPanel.legendBool = false;
end

% Update handles structure
guidata(hObject, handles);

end