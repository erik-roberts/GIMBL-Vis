function makeMenu(pluginObj, parentHandle)
%% makeMainWindowMenu
%
% Input: parentHandle - handle for uimenu parent
%
% Notes: These handles are arranged in a cell matrix corresponding to the 
%        positions in the toolbar and menu columns. The first row contains the 
%        toolbar titles.

uiMenuHandles = {};
menuCol = 0;

%% File
menuHandleStr = 'File';
menuLabel = menuHandleStr;
rowParent = makeMenuCol();

% uigetdir
handleStr = 'ChangeWD';
menuLabel = 'Change Working Directory';
makeMenuRow();

% uigetfile
handleStr = 'Load';
menuLabel = 'Load Object';
makeMenuRow();

% uigetfile
handleStr = 'Import';
menuLabel = 'Import Data';
makeMenuRow();

% uiputfile
% uisave
handleStr = 'Save';
menuLabel = 'Save GV Object';
makeMenuRow();


%% Model
menuHandleStr = 'Model';
menuLabel = menuHandleStr;
rowParent = makeMenuCol();

handleStr = 'MergeHypercubes';
menuLabel = 'Merge Hypercubes';
makeMenuRow();

handleStr = 'MergeVarFromWS';
menuLabel = 'Merge Variable From Workspace';
makeMenuRow();

handleStr = 'DeleteHypercube';
menuLabel = 'Delete Hypercube';
makeMenuRow();


%% View
menuHandleStr = 'View';
menuLabel = menuHandleStr;
rowParent = makeMenuCol();

% inputdlg
% uisetfont
handleStr = 'FontSize';
menuLabel = 'Font Size';
makeMenuRow();


handleStr = 'Reset';
menuLabel = 'Reset Window';
makeMenuRow();


%% Store Handles
pluginObj.handles.menu = uiMenuHandles;


%% Nested Fn
  function menuColHandle = makeMenuCol()
    menuCol = menuCol + 1;
    
    menuColHandle = uimenu(...
      'Label',menuLabel,...
      'Tag',[menuHandleStr 'Menu'],...
      'Callback',[],...
      'Parent',parentHandle...
      );
    uiMenuHandles{1,menuCol} = menuColHandle;
  end

  function makeMenuRow()
    uiMenuHandles{end+1,menuCol} = uimenu(...
      'Label',menuLabel,...
      'Tag',[menuHandleStr handleStr],...
      'Callback',eval(['@gvMainWindowPlugin.Callback_' menuHandleStr handleStr]),...
      'UserData',pluginObj.userData,...
      'Parent',rowParent...
      );
  end

end
