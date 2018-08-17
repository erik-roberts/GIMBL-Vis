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
      
      % image lists
      pluginObj.metadata.dirList = [];
      pluginObj.metadata.dirImageList = [];
      pluginObj.metadata.imageFileTypes = [];
      pluginObj.metadata.imageFileInd = [];
      pluginObj.metadata.imageDirs = [];
      
      pluginObj.metadata.matchedImageList = [];
      pluginObj.metadata.matchedImageIndList = [];
      
      pluginObj.addWindowOpenedListenerToPlotPlugin();
      
      pluginObj.WindowKeyPressFcns.image = @pluginObj.Callback_image_window_KeyPressFcn;
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
        'Name',['GIMBL-Vis: ' pluginObj.windowName],...
        'Tag',pluginObj.figTag(),...
        'NumberTitle','off',...
        'Position',newPos,...
        'color','white',...
        'WindowKeyPressFcn',@pluginObj.Callback_WindowKeyPressFcn,...
        'WindowButtonDownFcn',@pluginObj.Callback_WindowButtonDownFcn,...
        'UserData',pluginObj.userData);
      
      makeBlankAxes(imageWindowHandle);
      
      % set image handle
      pluginObj.handles.fig = imageWindowHandle;
      
      status = 0;
    end
    
    
    showImage(pluginObj, index)
    
    
    function addWindowOpenedListenerToPlotPlugin(pluginObj)
      if isfield(pluginObj.controller.windowPlugins, 'plot')
        if isfield(pluginObj.metadata, 'plotWindowListener')
          delete(pluginObj.metadata.plotWindowListener)
        end
        
        pluginObj.metadata.plotWindowListener = addlistener(pluginObj.controller.windowPlugins.plot, 'windowOpened', @gvImageWindowPlugin.Callback_plotWindowOpened);
        
        pluginObj.vprintf('[gvImageWindowPlugin] Added window opened listener to plot plugin.\n');
      end
    end
    
    
    function addMouseMoveCallbackToPlotFig(pluginObj)
      if isfield(pluginObj.controller.windowPlugins, 'plot')
        plotFigH = pluginObj.controller.windowPlugins.plot.handles.fig;
        set(plotFigH, 'WindowButtonMotionFcn', @gvImageWindowPlugin.Callback_mouseMove);
        
        pluginObj.vprintf('[gvImageWindowPlugin] Added WindowButtonMotionFcn callback to plot plugin figure.\n');
      end
    end
    
    
    function imageDirs = getImageDirPaths(pluginObj, forceUpdateBool)
      % returns cell array of dirs that exist
      
      if nargin < 2
        forceUpdateBool = false;
      end
      
      imageDirCell = pluginObj.metadata.imageDirs;
      
      if isempty(imageDirCell) || forceUpdateBool
        boxObj = findobjReTag('image_panel_imageDirBox');
        imageDirStr = boxObj.String;
        
        imageDirCell = shebangParse(imageDirStr);
        if ~iscell(imageDirCell)
          imageDirCell = {imageDirCell};
        end
        
        cwd = pluginObj.controller.app.workingDir;
        
        % parse paths
        imageDirs = {};
        for thisCell = imageDirCell(:)'
          imageDirs = [imageDirs; parsePath(thisCell{1})];
        end
        
        imageDirs = unique(imageDirs);
      end
      
      
      %% Nested fn
      function thisPath = parsePath(thisPath)
        % Note: if doesn't exist, returns empty
        
        if isempty(thisPath) % if blank
          thisPath = cwd;
        end
        
        % convert to abs
        thisPath = getAbsolutePath(thisPath);
        
        % try regexp if path doesnt exist
        if ~isfolder(thisPath)
          % remove trailing filesep
          if thisPath(end) == filesep
            thisPath(end) = [];
          end
          
          outerPath = fileparts(thisPath);
          
          outerContents = lscell(outerPath, 0);
          
          % seach with wildcards
          matchingDirs = regexpi(outerContents, regexptranslate('wildcard',thisPath));
          matchingDirs = outerContents(~cellfun(@isempty, matchingDirs));
          
          thisPath = matchingDirs(:);
        end
      end
    end

    
    function imageTypes = getImageTypes(pluginObj)
      imageDirs = pluginObj.getImageDirPaths;
      
      if any(isfolder(imageDirs))
        if isempty(pluginObj.metadata.imageFileTypes)
          % usually called with makePanelControls
          pluginObj.updateAllImageList();
        end
        
        imageFileTypes = pluginObj.metadata.imageFileTypes;
        
        if isempty(imageFileTypes)
          imageTypes = '[ None ]';
        else
          imageTypes = unique(imageFileTypes);
        end
      else
        imageTypes = '[ None ]';
      end
    end
    
    
    function [dirImageList, imageTypes, imageInd] = useImageRegExp(pluginObj)
      % gets cellstr of image types and index for each file in imageDir
      
      imageDirs = pluginObj.getImageDirPaths;
      
      if any(isfolder(imageDirs))
        % Find images in imageDir
        dirList = pluginObj.getAllFileList();
        
        % Remove paths
        fileList = cellfun(@getFilenameFromPath, dirList, 'unif',0);

        imageRegExp = pluginObj.metadata.imageRegexp;
        
        if ischar(imageRegExp)
          % Parse image paths
          imageFiles = regexp(fileList, imageRegExp, 'tokens');
          dirImageList = dirList(~cellfun(@isempty, imageFiles));
          
          % Parse image names
          imageFiles = imageFiles(~cellfun(@isempty, imageFiles));
          imageFiles = cellfunu(@(x) x{1}, imageFiles);
          
          imageTypes = cellfunu(@(x) x{1}, imageFiles);
          imageInd = cellfunu(@(x) x{2}, imageFiles);
          imageInd = cellfun(@str2double, imageInd);
        else % iscell
          % Parse image paths
          imageTypes = regexp(fileList, imageRegExp{1}, 'tokens');
          dirImageList = dirList(~cellfun(@isempty, imageTypes));
          
          % Parse image names
          imageTypes = imageTypes(~cellfun(@isempty, imageTypes));
          imageTypes = cellfunu(@(x) x{1}, imageTypes);
          imageTypes = imageTypes(~cellfun(@isempty, imageTypes));
          imageTypes = cellfunu(@(x) x{1}, imageTypes);
          
          % Parse image index
          imageInd = regexp(dirImageList, imageRegExp{2}, 'tokens');
          imageInd = imageInd(~cellfun(@isempty, imageInd));
          imageInd = cellfunu(@(x) x{1}, imageInd);
          imageInd = cellfunu(@(x) x{1}, imageInd);
          imageInd = cellfun(@str2double, imageInd);
          
          % alternate name if 3rd regexp cell
          if length(imageRegExp) > 2
            % find alt names
            altImageTypes = regexp(dirImageList, imageRegExp{3}, 'tokens');
            altImageTypes = altImageTypes(~cellfun(@isempty, altImageTypes));
            altImageTypes = cellfunu(@(x) x{1}, altImageTypes);
            altImageTypes = cellfunu(@(x) x{1}, altImageTypes);
            
            if isempty(imageTypes)
              imageTypes = altImageTypes;
            end
            
            if ~isempty(altImageTypes)
              % find filenames mathcing study
              studyInds = strcmp(imageTypes, 'study');

              % replace name wiht alt name
              imageTypes(studyInds) = altImageTypes(studyInds);
            end
          end
        end
      else
        imageTypes = [];
        imageInd = [];
      end % if isfolder(imageDir)
      
      %% Nested fn
      function filename = getFilenameFromPath(x)
        [~, file, ext] = fileparts(x);
        filename = [file, ext];
      end
    end
    
      
    function imageType = getImageTypeFromGUI(pluginObj)
      % get menu handle
      imgTypeMenu = findobjReTag('image_panel_imageTypeMenu');
      
      imageTypes = imgTypeMenu.String;
      
      imageType = imageTypes{imgTypeMenu.Value};
    end
    
    
    function dirList = getAllFileList(pluginObj, forceUpdateBool)
      if nargin < 2
        forceUpdateBool = false;
      end
      
      if isempty(pluginObj.metadata.dirList) || forceUpdateBool
        imageDirs = pluginObj.getImageDirPaths(forceUpdateBool);
        
        dirList = {};
        removePathBool = false;
        for imageDir = imageDirs(:)'
          imageDir = imageDir{1}; %#ok<FXSET>
          
          % remove .dsStore
          if isfile(fullfile(imageDir, '.DS_Store'))
            delete(fullfile(imageDir, '.DS_Store'));
          end
          
          if isfolder(imageDir)
            dirList = [dirList; lscell(imageDir, removePathBool)]; %#ok<AGROW>
          else
            wprintf('Image folder missing: %s', imageDir);
          end
        end
        
        % store to metadata to speed up future calls
        pluginObj.metadata.dirList = dirList;
      else
        dirList = pluginObj.metadata.dirList;
      end
    end
    
    
    function updateImageTypeListControl(pluginObj)
      % get menu handle
      imgTypeMenu = findobjReTag('image_panel_imageTypeMenu');
      
      % update menu string with image types from dir
      imgTypeMenu.String = pluginObj.getImageTypes();
    end
    
    
    function updateAllImageList(pluginObj)
      % get list of all images
      forceUpdateBool = true;
      getAllFileList(pluginObj, forceUpdateBool);
      
      % use regexp
      [pluginObj.metadata.dirImageList,...
        pluginObj.metadata.imageFileTypes,...
          pluginObj.metadata.imageFileInd] = useImageRegExp(pluginObj);
    end
    
    
    function updateMatchedImageList(pluginObj)
      % get chosen menu str
      thisStr = pluginObj.getImageTypeFromGUI();
      
      % update matched list
      matches = strcmp(pluginObj.metadata.imageFileTypes, thisStr); % look for exact match
      if ~any(matches)
        matches = contains(pluginObj.metadata.imageFileTypes, thisStr); % look for near match
      end
      pluginObj.metadata.matchedImageList = pluginObj.metadata.dirImageList(matches);
      pluginObj.metadata.matchedImageIndList = pluginObj.metadata.imageFileInd(matches);
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
    function Callback_image_window_KeyPressFcn(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      if evnt.Key == 'i'
        % get menu handle
        imgTypeMenu = findobjReTag('image_panel_imageTypeMenu');
        
        nImageTypes = length(imgTypeMenu.String);
        
        switch evnt.Character
          case 'i'
            imgTypeMenu.Value = max(mod(imgTypeMenu.Value+1, nImageTypes+1),1); % increment
          case 'I'
            if imgTypeMenu.Value-1 ~= 0
              imgTypeMenu.Value = imgTypeMenu.Value-1; % decrement
            else
              imgTypeMenu.Value = nImageTypes; % reset to max
            end
        end
        
        pluginObj.vprintf('[gvImageWindowPlugin] ''Image Type'': (%i/%i) ''%s''\n', imgTypeMenu.Value, nImageTypes, imgTypeMenu.String{imgTypeMenu.Value});
        
        pluginObj.updateMatchedImageList();
      end
    end
    
    
    function Callback_image_panel_openWindowButton(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      pluginObj.openWindow();
    end
    
    
    function Callback_image_panel_imageDirBox(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin

      pluginObj.updateAllImageList();
      
      pluginObj.updateImageTypeListControl();
      
      pluginObj.updateMatchedImageList();
    end
    
    
    function Callback_image_panel_imageTypeMenu(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin

      pluginObj.updateMatchedImageList();
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
      
      pluginObj.updateAllImageList();
      
      pluginObj.updateImageTypeListControl();
      
      pluginObj.updateMatchedImageList();
    end
    
    Callback_mouseMove(src, evnt)
  end
  
end
