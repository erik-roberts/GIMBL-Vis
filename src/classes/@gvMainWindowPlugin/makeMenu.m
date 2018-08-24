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
menuRow = 0;

%% File
menuLabel = 'File';
menuHandleStr = lower(menuLabel);
rowParent = makeMenuCol();

handleStr = 'changeWD';
menuLabel = 'Change Working Directory';
makeMenuRow();

handleStr = 'changeWD2pwd';
menuLabel = 'Change Working Directory to Current Folder';
makeMenuRow();

handleStr = 'loadFile';
menuLabel = 'Load Object from File';
makeMenuRow();

handleStr = 'loadCwd';
menuLabel = 'Auto Load Object from Working Directory';
makeMenuRow();

handleStr = 'importMdData';
menuLabel = 'Import Multidimensional Data from File';
makeMenuRow();

handleStr = 'importTable';
menuLabel = 'Import Tabular Data from File';
makeMenuRow();

handleStr = 'importCwd';
menuLabel = 'Auto Import Data from Working Directory';
makeMenuRow();

handleStr = 'saveGV';
menuLabel = 'Save GV Object';
makeMenuRow();

handleStr = 'saveHC';
menuLabel = 'Save Hypercube as MDD Object';
makeMenuRow();


%% Model
menuLabel = 'Model';
menuHandleStr = lower(menuLabel);
rowParent = makeMenuCol();

handleStr = 'loadFromWS';
menuLabel = 'Load/Import Data from Workspace';
makeMenuRow();

% TODO fix MDDRef to allow merge
% handleStr = 'mergeHypercubes';
% menuLabel = 'Merge Hypercube with Active Hypercube';
% makeMenuRow();

% handleStr = 'mergeFromWS';
% menuLabel = 'Merge Object From Workspace with Active Hypercube';
% makeMenuRow();

handleStr = 'deleteHypercube';
menuLabel = 'Delete Active Hypercube';
makeMenuRow();


%% View
menuLabel = 'View';
menuHandleStr = lower(menuLabel);
rowParent = makeMenuCol();

handleStr = 'setFontSize';
menuLabel = 'Set Font Size';
makeMenuRow();


handleStr = 'reset';
menuLabel = 'Reset Window';
makeMenuRow();


%% Help
menuLabel = 'Help';
menuHandleStr = lower(menuLabel);
rowParent = makeMenuCol();

handleStr = 'pluginHelp';
menuLabel = 'Current Plugin Help in Command Window';
makeMenuRow();

handleStr = 'onlineHelp';
menuLabel = 'Online Help in Browser';
makeMenuRow();

handleStr = 'pluginDocs';
menuLabel = 'Current Plugin Reference page in Help browser';
makeMenuRow();

handleStr = 'evalInBase';
menuLabel = 'Evaluate GV Object in Command Window';
makeMenuRow();



%% Store Handles
pluginObj.handles.menu = uiMenuHandles;


%% Nested Fn
  function menuColHandle = makeMenuCol()
    menuCol = menuCol + 1;
    menuRow = 0;
    
    thisTag = [pluginObj.pluginFieldName '_menu_' menuHandleStr];
    
    menuColHandle = uimenu(...
      'Label',menuLabel,...
      'Tag',thisTag,...
      'Callback',[],...
      'Parent',parentHandle...
      );
    uiMenuHandles{1,menuCol} = menuColHandle;
  end


  function makeMenuRow()
    menuRow = menuRow + 1;
    
    thisTag = [pluginObj.pluginFieldName '_menu_' menuHandleStr '_' handleStr];
    
    uiMenuHandles{menuRow,menuCol} = uimenu(...
      'Label',menuLabel,...
      'Tag',thisTag,...
      'Callback',pluginObj.callbackHandle(thisTag),...
      'UserData',pluginObj.userData,...
      'Parent',rowParent...
      );
  end

end
