function gvImageTypeMenuCallback(hObject, eventdata, handles)

if hObject.UserData.lastVal ~= hObject.Value
  % update plot type
  handles.ImageWindow.plotType = hObject.String{hObject.Value};
  
  % Update last value
  hObject.UserData.lastVal = hObject.Value;

  % Update handles structure
  guidata(hObject, handles);
end

end