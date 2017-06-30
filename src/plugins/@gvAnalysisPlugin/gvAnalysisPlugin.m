%% gvAnalysisPlugin - Select GUI Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis analysis tab in the main  window.

classdef gvAnalysisPlugin < gvGuiPlugin
  
  %% Public properties %%
  properties (Constant)
    pluginName = 'Analysis'
    pluginFieldName = 'analysis'
  end
  
  properties
    metadata = struct()
    
    handles = struct()
  end
  
  %% Public methods %%
  methods
    
    function pluginObj = gvAnalysisPlugin(varargin)
      pluginObj@gvGuiPlugin(varargin{:});
    end
    
    
    function setup(pluginObj, cntrlObj)
      setup@gvGuiPlugin(pluginObj, cntrlObj);
    end

    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    function fns = getFnList(pluginObj)
      fnDir = fullfile(gv.RootPath, 'src', 'analysisFunctions');
      fns = lscell(fnDir);
      fns = strrep(fns, '.m',''); % remove .m
      fns = ['[ User Specified ]', fns];
      fns = fns(:); % convert to cell col vec
    end
    
    
    function label = getTargetNameLabel(pluginObj)
      radioBox = findobjReTag('targetRadioBox');
      
      buttonString = radioBox.Button.String;
      
      switch buttonString
        case 'Merge into Source Hypercube'
          label = 'Target Axis:';
        case 'New Hypercube'
          label = 'Target Hypercube:';
        case 'Workspace Variable'
          label = 'Target Variable:';
        case 'New File'
          label = 'Target File Path:';
        otherwise
          error('Could not find correct target type string.')
      end
    end
    
  end
  
  
  %% Static %%
  methods (Static, Hidden)
    
    function str = helpStr()
      str = [gvAnalysisPlugin.pluginName ':\n',...
        'Select an input source and output target and press the Apply button to ',...
        'call the function.\n'
        ];
    end
    
    
    %% Callbacks %%
    function Callback_analysis_panel_targetRadioBox(src)
      nameLabelObj = findobjReTag('analysis_panel_targetNameLabel');
      
      deleteSourceHcLabelObj = findobjReTag('analysis_panel_deleteSourceHcLabel');
      deleteSourceHcToggleObj = findobjReTag('analysis_panel_deleteSourceHcToggle');
      
      switch src.Button.String
        case 'Merge into Source Hypercube'
          nameLabelObj.String = 'Target Axis';
          
          deleteSourceHcLabelObj.Enable = 'off';
          deleteSourceHcToggleObj.Enable = 'off';
        case 'New Hypercube'
          nameLabelObj.String = 'Target Hypercube';
          
          deleteSourceHcLabelObj.Enable = 'on';
          deleteSourceHcToggleObj.Enable = 'off';
        case 'Workspace Variable'
          nameLabelObj.String = 'Target Variable';
          
          deleteSourceHcLabelObj.Enable = 'on';
          deleteSourceHcToggleObj.Enable = 'on';
        case 'New File'
          nameLabelObj.String = 'Target File Path';
          
          deleteSourceHcLabelObj.Enable = 'on';
          deleteSourceHcToggleObj.Enable = 'on';
      end
    end

    
    function Callback_analysis_panel_fnMenu(src, evnt)
      fnBoxObj = findobjReTag('analysis_panel_fnBox');
      if src.Value == 1
        fnBoxObj.Enable = 'on';
      else
        fnBoxObj.Enable = 'off';
      end
    end
    
    
    function Callback_analysis_panel_deleteSourceHcToggle(src, evnt)
%       pluginObj = src.UserData.pluginObj; % window plugin
      
      if src.Value
        src.String = sprintf('( %s )', char(hex2dec('2714'))); % checkmark
      else
        src.String = '(   )';
      end
    end
    
    
    function Callback_analysis_panel_applyButton()
      
    end
    
  end
  
end