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

handleStr = 'load';
menuLabel = 'Load Object';
makeMenuRow();

% uigetfile
handleStr = 'importTable';
menuLabel = 'Import Tabular Data';
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

handleStr = 'mergeHypercubes';
menuLabel = 'Merge Hypercube with Active Hypercube';
makeMenuRow();

handleStr = 'mergeVarFromWS';
menuLabel = 'Merge Variable From Workspace with Active Hypercube';
makeMenuRow();

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
