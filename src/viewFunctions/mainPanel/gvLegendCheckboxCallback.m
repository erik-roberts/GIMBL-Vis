function gvLegendCheckboxCallback(hObject, eventdata, handles)

if hObject.Value
  handles.MainWindow.legendBool = true;
else
  handles.MainWindow.legendBool = false;
end

% Update handles structure
guidata(hObject, handles);

end