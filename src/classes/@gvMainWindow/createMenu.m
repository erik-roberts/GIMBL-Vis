function createMenu(windowObj, parentHandle)
%% createMainWindowMenu
%
% Input: parentHandle - handle for uimenu parent
%
% Notes: These handles are arranged in a cell matrix corresponding to the 
%        positions in the toolbar and menu columns. The first row contains the 
%        toolbar titles.

uiMenuHandles = {};

%% File
uiMenu_fileCol = 1;
uiMenu_fileH = uimenu(...
  'Label','File',...
  'Tag','fileMenu',...
  'Callback',[],...
  'Parent',parentHandle...
);
uiMenuHandles{1,uiMenu_fileCol} = uiMenu_fileH;


uiMenuHandles{end+1,uiMenu_fileCol} = uimenu(...
  'Label','Load',...
  'Tag','fileLoad',...
  'Callback',@(hObject,eventdata)gvMainWindow_export('fileLoad_Callback',hObject,eventdata,guidata(hObject)),...
  'UserData',windowObj.userData,...
  'Parent',uiMenu_fileH...
);


uiMenuHandles{end+1,uiMenu_fileCol} = uimenu(...
  'Label','Import',...
  'Tag','fileImport',...
  'Callback',@(hObject,eventdata)gvMainWindow_export('fileImport_Callback',hObject,eventdata,guidata(hObject)),...
  'UserData',windowObj.userData,...
  'Parent',uiMenu_fileH...
);


uiMenuHandles{end+1,uiMenu_fileCol} = uimenu(...
  'Label','Save',...
  'Tag','fileSave',...
  'Callback',@(hObject,eventdata)gvMainWindow_export('fileSave_Callback',hObject,eventdata,guidata(hObject)),...
  'UserData',windowObj.userData,...
  'Parent',uiMenu_fileH...
);

%% Edit
uiMenu_fileCol = 2;
uiMenu_fileH = uimenu(...
  'Label','Edit',...
  'Tag','editMenu',...
  'Callback',[],...
  'Parent',parentHandle...
);
uiMenuHandles{1,uiMenu_fileCol} = uiMenu_fileH;

%% View
uiMenu_fileCol = 3;
uiMenu_fileH = uimenu(...
  'Label','View',...
  'Tag','viewMenu',...
  'Callback',[],...
  'Parent',parentHandle...
);
uiMenuHandles{1,uiMenu_fileCol} = uiMenu_fileH;

uiMenuHandles{end+1,uiMenu_fileCol} = uimenu(...
  'Label','Reset',...
  'Tag','viewReset',...
  'Callback',@gvWindow.resetWindowCallback,...
  'UserData',windowObj.userData,...
  'Parent',uiMenu_fileH...
);

%% Store Handles
windowObj.handles.menu = uiMenuHandles;

end