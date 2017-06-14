function panelHandle = makePanelControls(pluginObj, parentHandle)
% makePanelControls - make plot panel for tab in main window

% params
spacing = 5;
padding = 5;
panelTitleFontSize = pluginObj.fontSize;

uiControlsHandles = struct();

% 1)
% main vBox
mainVbox = uix.VBoxFlex('Parent',parentHandle, 'Spacing',spacing, 'Padding', padding);

% 1.1)
% data panel
dataPanel = uix.Panel(...
  'Tag','dataPanelBox',...
  'Parent', mainVbox,...
  'Title', 'Hypercube Data',...
  'FontUnits','points',...
  'FontSize',panelTitleFontSize ...
);

dataVbox = uix.VBox('Parent',dataPanel); % make box to hold 1)titles and 2)data

% 1.2.1) titles
pluginObj.makeDataPanelTitles(dataVbox); % row 1

% 1.2.2) data
makeDataPanel(dataVbox) % row 2

uiControlsHandles.dataPanel.handle = dataPanel;

%% Set layout sizes
set(mainVbox, 'Heights',[-1])
set(dataVbox, 'Heights',[30,-1])

%% argout
panelHandle = mainVbox;


%% Nested Fn
  function makeDataPanel(parentHandle)
    dataScrollingPanel = uix.ScrollingPanel(...
      'Tag','dataScrollingPanel',...
      'Parent', parentHandle...
      );
    
    dataPanelheight = pluginObj.makeDataPanelControls(dataScrollingPanel);
    
    set(dataScrollingPanel, 'Heights',dataPanelheight)
  end

end