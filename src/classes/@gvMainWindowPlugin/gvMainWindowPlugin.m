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
      
      addlistener(pluginObj, 'panelControlsMade', @gvMainWindowPlugin.Callback_panelControlsMade);
    end
    
    
    function addDynamicCallbackFields(pluginObj)
      flds = {'WindowScrollWheelFcn'};
      
      for fld = flds(:)'
        pluginObj.dynamicCallbacks.(fld{1}) = {};
      end
    end
    
    
    openWindow(pluginObj)
    
    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
    
    function plugin = currentPlugin(pluginObj)
      plugin = pluginObj.currentTab.UserData.plugin;
    end
    
    
    function tab = currentTab(pluginObj)
      tab = pluginObj.handles.controls.tabPanel.SelectedTab;
    end
    
    
    function selectTab(pluginObj, tab)
      % selectTab - using tab name or number
      
      if isscalar(tab)
        tabInd = tab;
      elseif ischar(tab)
        tabs = [pluginObj.handles.controls.tabs{:}];
        tabs = [tabs.uitab];
        tabs = {tabs.Title};
        
        tabInd = find(strcmp(tabs, tab));
      else
        error('Unknown tab input.')
      end
      
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

  
  methods (Static, Hidden)
    
    function str = helpStr()
      str = [gvMainWindowPlugin.pluginName ':\n',...
        'Use the Main tab to load different plugins by clicking the checkbox.\n'
        ];
    end
    
    
    %% Event Callbacks
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
    
    function Callback_panelControlsMade(src, ~)
      pluginObj = src;
      
      if pluginObj.controller.app.config.autoOpenLoadedPluginWindows
        
        % get window plugins without main
        windowPlugins = pluginObj.controller.windowPlugins;
        windowPlugins = rmfield(windowPlugins, pluginObj.pluginFieldName);
        windowPlugins = struct2cell(windowPlugins)';
        
        for windowPluginObj = windowPlugins(:)'
          windowPluginObj{1}.openWindow();
        end
        
      end
    end
    
    %% Menu Callbacks
    
    %% File
    function Callback_main_menu_file_changeWD(src, ~)
      pluginObj = src.UserData.pluginObj;

      newWD = uigetdir(pluginObj.controller.app.workingDir, 'New Working Directory');
      
      if isequal(newWD,0)
        return
      end
      
      pluginObj.controller.app.workingDir = newWD;
    end
    
    
    function Callback_main_menu_file_load(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      [fileName, pathName] = uigetfile('*.mat', 'Load gv, gvArray, or MDD Object from File');
      
      if isequal(fileName,0)
        return
      end
      
      filePath = fullfile(pathName, fileName);
      
      pluginObj.controller.model.load(filePath);
    end
    
    
    function Callback_main_menu_file_importMdData(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      [fileName, pathName] = uigetfile('*.mat', 'Import Numeric or Cell Array from File');
      
      if isequal(fileName,0)
        return
      end
      
      filePath = fullfile(pathName, fileName);
      
      pluginObj.controller.model.load(filePath);
    end
    
    
    function Callback_main_menu_file_importTable(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      [fileName, pathName] = uigetfile('*.mat', 'Import Tabular Data from File');
      
      if isequal(fileName,0)
        return
      end
      
      filePath = fullfile(pathName, fileName);
      
      pluginObj.controller.model.importTabularDataFromFile(filePath);
    end
    
    
    function Callback_main_menu_file_saveGV(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      [fileName, pathName] = uiputfile('*.mat', 'Save GIMBL-Vis Object');
      
      if isequal(fileName,0)
        return
      end
      
      filePath = fullfile(pathName, fileName);
      
      pluginObj.controller.app.save(filePath);
    end
    
    
    function Callback_main_menu_file_saveHC(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      [fileName, pathName] = uiputfile('*.mat', 'Save Hypercube as MDD Object');
      
      if isequal(fileName,0)
        return
      end
      
      filePath = fullfile(pathName, fileName);
      
      pluginObj.controller.saveActiveHypercube(filePath);
    end
    
    
    function Callback_main_menu_file_evalInBase(src, ~)
      global Callback_main_menu_file_evalInBase_temp__
      evalin('base', 'global Callback_main_menu_file_evalInBase_temp__');
      
      pluginObj = src.UserData.pluginObj;
      
      Callback_main_menu_file_evalInBase_temp__ = pluginObj.controller.app;
      
      evalin('base', 'ans = Callback_main_menu_file_evalInBase_temp__');
      
      clear global Callback_main_menu_file_evalInBase_temp__
    end
    
    
    %% Model
    function Callback_main_menu_model_loadFromWS(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      varList = evalin('base','whos');
      varList = {varList.name};
      
      [selection,ok] = listdlg('ListString', varList,...
        'Name','Load/Import Data from Workspace',...
        'PromptString','Select at least 1 variable from the Workspace:',...
        'ListSize', [350 300]);
      
      if ~ok
        return
      end

      varList = varList(selection);
      
      for varName = varList(:)'
        hypercubeName = varName{1};
        pluginObj.controller.model.importDataFromWorkspace(varName{1}, hypercubeName);
      end
    end
    
    
    function Callback_main_menu_model_mergeHypercubes(src, ~)
      % TODO fix issue with ref
      pluginObj = src.UserData.pluginObj;
      modelObj = pluginObj.controller.model;
      
      hypercubeList = fieldnames(modelObj.data);
      
      % Remove active hypercube from list
      hypercubeList(strcmp(pluginObj.controller.activeHypercubeName, hypercubeList)) = [];
      
      if isempty(hypercubeList)
        warning('No hypercubes to merge');
        return
      end
      
      [selection,ok] = listdlg('ListString', hypercubeList,...
        'Name','Merge Hypercube into Active Hypercube',...
        'PromptString','Select a hypercube to merge into the active hypercube:',...
        'SelectionMode','single',...
        'ListSize', [450 300]);
      
      if ~ok
        return
      end

      hypercube2merge = hypercubeList{selection};
      
      modelObj.mergeHypercubes(pluginObj.controller.activeHypercubeName, hypercube2merge);
    end
    
    
    function Callback_main_menu_model_mergeFromWS(src, ~)
      % TODO fix issue with ref
      pluginObj = src.UserData.pluginObj;
      modelObj = pluginObj.controller.model;
      
      hypercubeList = fieldnames(modelObj.data);
      
      [selection,ok] = listdlg('ListString', hypercubeList,...
        'Name','Merge Object from Workspace into Active Hypercube',...
        'PromptString','Select a workspace object to merge into the active hypercube:',...
        'ListSize', [450 300]);
      
      if ~ok
        return
      end

      hypercube2merge = hypercubeList{selection};
      
      modelObj.mergeHypercubes(pluginObj.controller.activeHypercubeName, hypercube2merge);
    end
    
    
    
    function Callback_main_menu_model_deleteHypercube(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      pluginObj.controller.deleteActiveHypercube()
    end
    
    
    %% View
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
    
    
    %% Help
    function Callback_main_menu_help_pluginHelp(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      pluginObj.currentPlugin.getHelp();
    end
    
    
    function Callback_main_menu_help_onlineHelp(~, ~)
      web('http://www.earoberts.com/GIMBL-Vis-Docs/', '-browser')
    end
    
    
    function Callback_main_menu_help_pluginDocs(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      doc(pluginObj.currentPlugin.pluginClassName);
    end
    
  end
  
end
