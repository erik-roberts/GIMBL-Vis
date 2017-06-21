%% gvMainWindowPlugin - Main Window Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis main window

classdef gvMainWindowPlugin < gvWindowPlugin
  
  %% Public properties %%
  properties
    metadata = struct()
    handles = struct()
  end
  
  properties (Constant)
    pluginName = 'Main';
    pluginFieldName = 'main';
    
    windowName = 'GIMBL-Vis Toolbox';
  end

  properties (SetAccess = 'protected')
    dynamicCallbacks = struct(); % allow for dynamic addition of callbacks
  end
  
  %% Public methods %%
  methods
    
    function pluginObj = gvMainWindowPlugin(varargin)
      pluginObj@gvWindowPlugin(varargin{:});
    end
    
    
    function setup(pluginObj, varargin)
      setup@gvWindowPlugin(pluginObj, varargin{:});
      
      pluginObj.addDynamicCallbackFields();
    end
    
    
    function addDynamicCallbackFields(pluginObj)
      flds = {'WindowScrollWheelFcn'};
      
      for fld = flds(:)'
        pluginObj.dynamicCallbacks.(fld{1}) = {};
      end
    end
    
    
    openWindow(pluginObj)
    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
    function selectTab(pluginObj, tabInd)
      pluginObj.handles.controls.tabPanel.SelectedTab = pluginObj.handles.controls.tabs{tabInd}.uitab;
    end
    
    function addDynamicCallback(pluginObj, callbackEventName, callbackHandle)
      if isfield(pluginObj.dynamicCallbacks, callbackEventName)
        pluginObj.dynamicCallbacks.(callbackEventName){end+1} = callbackHandle;
      else
        error(sprinft('dynamicCallbacks field ''%s'' not found.', callbackEventName));
      end
    end

  end
  
  
  %% Protected methods %%
  methods (Access = protected)
     
    makeFig(pluginObj)
    
    makeWindowControls(pluginObj, parentHandle)
    
    makeMenu(pluginObj, parentHandle)
    
    uiControlsHandles = makeHypercubePanelControls(pluginObj, parentHandle)

  end
  
  %% Callbacks %%
  methods (Static, Hidden)
    
    function Callback_CloseRequestFcn(src, ~)
      % Close request function
 
      pluginObj = src.UserData.pluginObj;
      closeMainWindowSaveDialogBool = pluginObj.controller.app.config.closeMainWindowSaveDialogBool;
      
      if ~closeMainWindowSaveDialogBool
        delete(pluginObj.handles.fig)
        return % if config turns off this dialog win
      end
      
      selection = questdlg('Save GIMBL-Vis object before closing?',...
        'GIMBL-Vis',...
        'Cancel','Yes','No', 'No');
      switch selection
        case 'No'
          delete(pluginObj.handles.fig)
        case 'Yes'
          % TODO
          error('Not implemented yet');
        case 'Cancel'
          return
      end
    end
    
    
    function Callback_activeHyperCubeMenu(src, ~)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      newActiveHypercube = src.String{src.Value};
      
      pluginObj.controller.setActiveHypercube(newActiveHypercube);
    end
    
    
    function Callback_loadPluginCheckbox(src, ~)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      checkBool = src.Value;
      if checkBool
        pluginClassName = src.UserData.pluginClassName;
        pluginObj.controller.connectPlugin(pluginClassName);
      else
        pluginFieldName = src.UserData.pluginFieldName;
        pluginObj.controller.disconnectPlugin(pluginFieldName);
      end
    end
    
    %% Menu Callbacks
    function Callback_main_menu_file_changeWD(src, ~)
      pluginObj = src.UserData.pluginObj;

      newWD = uigetdir(pluginObj.controller.app.workingDir, 'New Working Directory');
      
      pluginObj.controller.app.workingDir = newWD;
    end
    
    
    function Callback_main_menu_file_load(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      [fileName, pathName] = uigetfile('*.mat', 'Load Object');
      
      if ~fileName && ~pathName
        return
      end
      
      filePath = fullfile(pathName, fileName);
      
      pluginObj.controller.model.load(filePath);
    end
    
    
    function Callback_main_menu_file_importTable(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      [fileName, pathName] = uigetfile('*.mat', 'Import Tabular Data');
      
      if ~fileName && ~pathName
        return
      end
      
      filePath = fullfile(pathName, fileName);
      
      pluginObj.controller.model.importTabularDataFromFile(filePath);
    end
    
    
    function Callback_main_menu_file_saveGV(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      [fileName, pathName] = uiputfile('*.mat', 'Save GIMB-Vis Object');
      
      if ~fileName && ~pathName
        return
      end
      
      filePath = fullfile(pathName, fileName);
      
      pluginObj.controller.app.save(filePath);
    end
    
    
    function Callback_main_menu_file_saveHC(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      [fileName, pathName] = uiputfile('*.mat', 'Save Hypercube as MDD Object');
      
      if ~fileName && ~pathName
        return
      end
      
      filePath = fullfile(pathName, fileName);
      
      pluginObj.controller.saveActiveHypercube(filePath);
    end
    
    
    function Callback_main_menu_model_deleteHypercube(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      pluginObj.controller.deleteActiveHypercube()
    end
    
    
    function Callback_main_menu_view_setFontSize(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      newFontSize = inputdlg( {'Enter New Font Size:'},'Font Size',1,{num2str(pluginObj.fontSize)} );
      
      newFontSize = str2double(newFontSize);
      
      pluginObj.view.fontSize = newFontSize;
    end
    
    
    function Callback_main_menu_view_reset(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      pluginObj.Callback_resetWindow(src, evnt);
    end
    
    function Callback_WindowScrollWheelFcn(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      callbackHandleCells = pluginObj.dynamicCallbacks.WindowScrollWheelFcn;
      
      if ~isempty(callbackHandleCells) % check if any callbacks registered
        for fnHandle = callbackHandleCells
          feval(fnHandle{1}, src, evnt); % evaluate each callback
        end
      end
    end
    
  end
  
end
