%% gvImageWindowPlugin - Image Window Plugin Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis image window.

% Note:
%   imageRegexp can be regexp string or cellstring of 2-3 regexp. if string,
%   needs two groups. first group is imagetype, second group is sim id. if
%   cellstr, first cell is imagetype, second cell is sim id. if 3rd cell, this
%   is used as alternate name if the imagetype is matched as 'study', the
%   default dynasim prefix.

classdef gvImageWindowPlugin < gvWindowPlugin

  %% Public properties %%
  properties
    metadata = struct()
    
    handles = struct()
  end
  
  
  properties (Constant)
    pluginName = 'Image';
    pluginFieldName = 'image';
    
    windowName = 'Image Window';
  end
  
  
  %% Events %%
  events
    
  end
  
  
  %% Public methods %%
  methods
    
    function pluginObj = gvImageWindowPlugin(varargin)
      pluginObj@gvWindowPlugin(varargin{:});
    end
    
    
    function setup(pluginObj, cntrlObj)
      setup@gvWindowPlugin(pluginObj, cntrlObj);
      
      pluginObj.metadata.imageRegexp = pluginObj.controller.app.config.defaultImageRegexp;
      
      pluginObj.addWindowOpenedListenerToPlotPlugin();
    end

    openWindow(pluginObj)
    
    panelHandle = makePanelControls(pluginObj, parentHandle)

  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    function status = makeFig(pluginObj)
      % makeFig - make image window figure
      
      if ~isValidFigHandle(pluginObj.controller.plugins.plot.handles.fig)
        wprintf('Plot Window must be open to open Image Window.');
        status = 1;
        return
      end
      
      plotPanPos = pluginObj.controller.plugins.plot.handles.fig.Position;
      newPos = plotPanPos; % same size as plot window
      newPos(1) = newPos(1)+newPos(3)+50; % move right
      %       newPos(3:4) = newPos(3:4)*.8; %shrink
      imageWindowHandle = figure(...
        'Name',['GIMBL-VIS: ' pluginObj.windowName],...
        'Tag',pluginObj.figTag(),...
        'NumberTitle','off',...
        'Position',newPos,...
        'color','white');
      
      makeBlankAxes(imageWindowHandle);
      
      % set image handle
      pluginObj.handles.fig = imageWindowHandle;
      
      status = 0;
    end
    
    
    function addWindowOpenedListenerToPlotPlugin(pluginObj)
      if isfield(pluginObj.controller.windowPlugins, 'plot')
        if isfield(pluginObj.metadata, 'plotWindowListener')
          delete(pluginObj.metadata.plotWindowListener)
        end
        
        pluginObj.metadata.plotWindowListener = addlistener(pluginObj.controller.windowPlugins.plot, 'windowOpened', @gvImageWindowPlugin.Callback_plotWindowOpened);
        
        pluginObj.vprintf('gvImageWindowPlugin: Added window opened listener to plot plugin.\n');
      end
    end
    
    
    function addMouseMoveCallbackToPlotFig(pluginObj)
      if isfield(pluginObj.controller.windowPlugins, 'plot')
        plotFigH = pluginObj.controller.windowPlugins.plot.handles.fig;
        set(plotFigH, 'WindowButtonMotionFcn', @gvImageWindowPlugin.Callback_mouseMove);
        
        pluginObj.vprintf('gvImageWindowPlugin: Added WindowButtonMotionFcn callback to plot plugin figure.\n');
      end
    end
    
    
    function pathStr = getImageDirPath(pluginObj)
      boxObj = findobjReTag('image_panel_imageDirBox');
      pathStr = boxObj.String;
      
      cwd = pluginObj.controller.app.workingDir;
      if isempty(pathStr) % if blank
        pathStr = cwd;
      elseif pathStr(1) == '.' % if rel path
        pathStr = fullfile(cwd, pathStr);
      end
    end

    
    function imageTypes = getImageTypes(pluginObj)
      imageDir = pluginObj.getImageDirPath;
      
      if exist(imageDir, 'dir')
        % Find images in imageDir
        dirList = pluginObj.getImageList();
              
        imageRegExp = pluginObj.metadata.imageRegexp;
        
        if ischar(imageRegExp)
          % Parse image names
          imageFiles = regexp(dirList, imageRegExp, 'tokens');
          imageFiles = imageFiles(~cellfun(@isempty, imageFiles));
          imageFiles = cellfunu(@(x) x{1}, imageFiles);
          imageFiles = cellfunu(@(x) x{1}, imageFiles);
        else % iscell
          % Parse image names
          imageFiles = regexp(dirList, imageRegExp{1}, 'tokens');
          imageFiles = imageFiles(~cellfun(@isempty, imageFiles));
          imageFiles = cellfunu(@(x) x{1}, imageFiles);
          imageFiles = cellfunu(@(x) x{1}, imageFiles);
          
          % alternate name if 3rd regexp cell
          if length(imageRegExp) > 2
            % find alt names
            altImageFiles = regexp(dirList, imageRegExp{3}, 'tokens');
            altImageFiles = altImageFiles(~cellfun(@isempty, altImageFiles));
            altImageFiles = cellfunu(@(x) x{1}, altImageFiles);
            altImageFiles = cellfunu(@(x) x{1}, altImageFiles);
            
            % find filenames mathcing study
            studyInds = strcmp(imageFiles, 'study');
            
            % replace name wiht alt name
            imageFiles(studyInds) = altImageFiles(studyInds);
          end
        end
        
        if isempty(imageFiles)
          imageTypes = '[ None ]';
        else
          imageTypes = unique(imageFiles);
        end
      else
        imageTypes = '[ None ]';
      end
    end
    
    function imageType = getImageTypeFromGUI(pluginObj)
      % get menu handle
      imgTypeMenu = findobjReTag('image_panel_imageTypeMenu');
      
      imageTypes = imgTypeMenu.String;
      
      imageType = imageTypes{imgTypeMenu.Value};
    end
    
    
    function dirList = getImageList(pluginObj)
      imageDir = pluginObj.getImageDirPath;
      
      dirList = lscell(imageDir, true);
    end
    
    
    function updateImageTypeListControl(pluginObj)
      % get menu handle
      imgTypeMenu = findobjReTag('image_panel_imageTypeMenu');
      
      % update menu string with image types from dir
      imgTypeMenu.String = pluginObj.getImageTypes();
    end
    
  end
  
  %% Static %%
  methods (Static, Hidden)
    
    function str = helpStr()
      str = [gvImageWindowPlugin.pluginName ':\n',...
        'Use the Select tab or mouse over a Plot window data point to choose an ',...
        'image to display.\n'
        ];
    end
    
    
    %% Callbacks %%
    function Callback_image_panel_openWindowButton(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      pluginObj.openWindow();
    end
    
    
    function Callback_image_panel_imageDirBox(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      pluginObj.updateImageTypeListControl();
    end
    
    
    function Callback_image_panel_imageTypeMenu(src, evnt)
%       pluginObj = src.UserData.pluginObj; % window plugin
    end
    
    function Callback_plotWindowOpened(src, evnt)
      if isfield(src.controller.windowPlugins, 'image')
        pluginObj = src.controller.windowPlugins.image;

        pluginObj.addMouseMoveCallbackToPlotFig();
      end
    end
  
    
    function Callback_image_panel_imageRegexpBox(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      % update imageRegexp
      pluginObj.metadata.imageRegexp = shebangParse(src.String);
      
      pluginObj.updateImageTypeListControl();
    end
    
    Callback_mouseMove(src, evnt)
  end
  
end
