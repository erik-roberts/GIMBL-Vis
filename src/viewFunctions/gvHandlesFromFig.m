function handles = gvHandlesFromFig(mainWindowH)

handles = getappdata(mainWindowH, 'UsedByGUIData_m');

end