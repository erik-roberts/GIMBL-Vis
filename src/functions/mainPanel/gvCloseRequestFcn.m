function gvCloseRequestFcn(hObject, eventdata, handles)
% gvCloseRequestFcn - callback when closing gv GUI

% TODO check this

if isempty(gcbf)
    if length(dbstack) == 1
        warning(message('MATLAB:closereq:ObsoleteUsage'));
    end
    close('force');
else
    delete(gcbf);
end

% handles.gvObj.guiData.guiWindowBool = false;

notify(handles.gvObj, 'guiWindowChange');

end