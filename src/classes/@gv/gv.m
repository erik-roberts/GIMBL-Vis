%% gv - main class for GIMBL-Vis
%
% Properties (public):
%   mdData = struct containing gvArrays, with fields equal to hypercube names
%   meta = struct()
%   gui = gvGUI()
%
% Methods (public):
%   gv: constructor
%   load: load gv or gvArray object data
%   importTabularDataFromFile
%   run: run gv GUI
%   save: save gv object to file
%   summary: print mdData gvArray summaries
%   cwdChild: get name of most descendant directory for cwd path
%
% Methods (protected):
%   nextMdDataFieldName: get next default field for mdData
%   checkMdDataFieldName: check if hypercubeName exists as field in mdData
%
% Methods (static):
%   Load: load gv or gvArray object data
%   ImportDsData: import dynasim data
%   ImportTabularDataFromFile
%
% NOTE: gv is a handle class, which means that objects are passed by reference
%       instead of by value. For more info visit:
%       https://www.mathworks.com/help/matlab/matlab_oop/comparing-handle-and-value-classes.html

% Dev Notes:
%   This is the controller class for the GV MVC
%
% TODO:
%   fill nans in gvarray and have index
%   load new axes vs load merge axes
%   add propListeners
%   add callbacks
%     hypercube
%     axis name
%     slider/val
%     view
%     lock
%     plot marker
%     marker type
%   convert methods to handle style methods

classdef gv < handle
  
  %% Public Properties %%
  properties (SetObservable, AbortSet) % allows listener callback, aborts if set to current value
    mdData = struct()
    meta = struct()
    gui = gvGUI()
  end
  
  %   %% Set Properties %%
  %   methods
  %
  %     function set.mdData(obj, value)
  %       obj.mdData = value;
  %     end
  %
  %     function set.meta(obj, value)
  %       obj.meta = value;
  %     end
  %
  %     function set.gui(obj, value)
  %       obj.gui = value;
  %     end
  %
  %   end
  
  
  %% Protected Properties %%
  properties (Access = protected)
    propListeners = []; % proplistener array
  end
  
  %% Events %%
  events
    mainWindowChange
  end
  
  %% Public Methods %%
  methods
    
    %% Constructor
    function obj = gv(varargin)
      % gv - constructor
      %
      % Usage:
      %   1) Create blank gv object
      %       obj = gv()
      %
      %   2) Call load method on file/dir
      %       obj = gv(file/dir)
      %      obj = gv(file/dir, hypercubeName)
      %
      %   3) Call gvArray constructor on gvArray/MDD_Data
      %       obj = gv(gvArrayData)
      %       obj = gv(hypercubeName, gvArrayData)
      %
      %   4) Call gvArray constructor on cell/numeric_array data. Can be linear
      %         or multidimensional array data.
      %       obj = gv(cell/numeric_array)
      %       obj = gv(hypercubeName, cell/numeric_array)
      %       obj = gv(cell/numeric_array, axis_vals, axis_names)
      %       obj = gv(hypercubeName, cell/numeric_array, axis_vals, axis_names)
      
      % Add GUI propListeners
      obj.gui.data.mainPanel.obj = []; % set empty main panel obj
      addlistener(obj, 'mainWindowChange', @gv.guiWindowChangeCallback);
      
      % Add Property propListeners
      obj.propListeners{1} = addlistener(obj,'mdData','PostSet',@gv.propPostSetCallback);
      obj.propListeners{2} = addlistener(obj,'meta','PostSet',@gv.propPostSetCallback);
      obj.propListeners{3} = addlistener(obj,'gui','PostSet',@gv.propPostSetCallback);
      obj.propListeners = [obj.propListeners{:}]; % convert to proplistener array
      
      [obj.propListeners.Enabled] = deal(false); % disable until window opens
      
      if nargin
        if ischar(varargin{1})
          if exist(varargin{1}, 'file') || exist(varargin{1}, 'dir') % varargin{1} is a path
            obj = gv.Load(varargin{:});
            return
          else % treat varargin{1} as fld
            fld = varargin{1};
            varargin(1) = [];
          end
        end
        
        if exist('fld', 'var')
          [obj, fld] = checkMdDataFieldName(obj, fld);
        end
        
        if iscell(varargin{1}) || isnumeric(varargin{1}) % varargin{1} is built-in data array
          if ~exist('fld', 'var')
            fld = obj.nextMdDataFieldName; % get next fld for mdData.axes#
          end
          obj.mdData.(fld) = gvArray(varargin{:});
        elseif isa(varargin{1}, 'gvArray') || isa(varargin{1}, 'MDD')
          if ~exist('fld', 'var')
            [obj, fld] = checkMdDataFieldName(obj, data);
          end
          obj.mdData.(fld) = gvArray(varargin{:});
        end
      end
    end
    
    
    %% Loading
    function obj = load(obj, src, fld, staticBool)
      % load - load gv or gvArray object data
      %
      % Usage: obj = obj.load()
      %        obj = obj.load(src)
      %        obj = obj.load(src, hypercubeName)
      %
      % Inputs:
      %   src: is a dir or a file to load.
      %   hypercubeName: is a hypercubeName to store loaded data in. If empty
      %                  will use default indexing.
      %
      % See also: gv.Load (static method)
      
      % Setup args
      if nargin < 2 || isempty(src)
        src = pwd;
      end
      if nargin < 3
        fld = [];
      end
      if nargin < 4
        staticBool = false;
      end
      
      % Determine fld/hypercubeName
      if isempty(fld)
        fld = obj.nextMdDataFieldName; % get next fld for mdData.axes#
      else
        [obj, fld] = checkMdDataFieldName(obj, fld);
      end
      
      % parse src
      if exist(src, 'dir')
        matFile = lscell(fullfile(src, '*.mat'));
        if ~isempty(matFile)
          if any(strcmp(matFile, 'gvData.mat'))
            src = fullfile(src, 'gvData.mat');
          else
            if length(matFile) > 1
              error('Found multiple mat files in dir. Please specify path to which mat file to load.')
            end
            src = fullfile(src, matFile{1});
          end
          
          % in case specify dynasim data dir
          if strcmp(matFile{1}, 'studyinfo.mat')
            obj = gv.ImportDsData(src); % ignore src
            return
          end
        else
          error('No mat files found in dir for loading.')
        end
      elseif ~exist(src, 'file')
        error('Load source not found. Use ''obj.importTabularDataFromFile'' instead for non-mat files.')
      end
      
      % import data
      data = importdata(src);
      if isa(data, 'gv')
        if ~staticBool
          for mdDataFld = fieldnames(data.mdData)'
            mdDataFld = mdDataFld{1};
            [obj, mdDataFldNew] = checkMdDataFieldName(obj, mdDataFld); % check fld name
            obj.mdData.(mdDataFldNew) = data.mdData.(mdDataFld); % add fld to checked fld name
          end
        else
          obj = data;
        end
        fprintf('Loaded gv object data.\n')
      elseif isa(data, 'gvArray') || isa(data, 'MDD')
        obj.mdData.(fld) = gvArray(data);
        fprintf('Loaded multidimensional array object data.\n')
      else
        error('Attempting to load non-gv data. Use ''obj.importTabularDataFromFile'' instead.')
      end
    end
    
    
    %% Importing
    function obj = importTabularDataFromFile(obj, fld, varargin)
      % importTabularDataFromFile (public) - Imports tabular data from a file to
      %                                      a new set of axes (ie hypercube)
      %
      % Supports file types including: xls, xlsx, csv, tsv, txt, mat.
      %
      % Usage:
      %   obj = obj.importTabularDataFromFile([], filePath)
      %   obj = obj.importTabularDataFromFile(hypercubeName, filePath, dataCol, headerFlag, delimiter)
      %
      % Inputs:
      %   filePath: path to file
      %       Supported filetypes:
      %           xls, xlsx, csv, tsv, txt, mat (containing 1 numeric mat variable)
      %               Note: xls and xlsx cannot have columns with mixtures of numerics
      %                     and strings, except for first row. however, txt and csv
      %                     files can.
      %
      % Inputs (optional):
      %   dataCol: col number or header name of column with linear data. the rest of
      %            the columns will be treated as axes. Default is col 1.
      %   headerFlag: logical value of whether 1st row is header of axis names. the
      %               name for dataCol will be ignored. it is only necesary to
      %               explicitly set this to true if the type of data (numeric vs. string)
      %               of the first row is the same as the second row and the first row
      %               should be treated as a header.
      %   delimiter: specify if using a delimiter other than space(' '), comma(','),
      %              or tab('\t'). see strsplit documentation for delimiter specification.
      %
      % See also:
      %   gv.ImportTabularDataFromFile (static method)
      %   MDD.ImportFile documentation for more information.
      
      if isempty(fld)
        fld = obj.nextMdDataFieldName; % get next fld for mdData.axes#
      else
        [obj, fld] = checkMdDataFieldName(obj, fld);
      end
      
      obj.mdData.(fld) = gvArray.ImportFile(varargin{:});
    end
    
    
    %% Running
    function obj = run(obj, varargin)
      % run (public) - run gv GUI
      %
      % See also: gv.Run (static method)
      
      options = checkOptions(varargin,{...
        'workingDir',[],[],...
        'overwriteBool', 0, {0,1},...
        'verboseBool', 1, {0,1},...
        },false);
      
      % if specify load path
      if ~isempty(options.workingDir)
        obj.gui.data.workingDir = options.workingDir;
      else
        obj.gui.data.workingDir = pwd;
      end
      
      obj = gvMainPanel(obj);
    end
    
    
    %% Saving
    function save(obj, filePath, overwriteBool) %#ok<INUSL>
      % save - save gv object to file (default: 'gvData.mat')
      
      if ~exist('filePath', 'var') || isempty(filePath)
        filePath = 'gvData.mat';
      end
      if nargin < 3
        overwriteBool = false;
      end
      
      if ~exist(filePath,'file') || overwriteBool
        save(filePath, 'obj');
      else
        warning('File exists and overwriteBool=false. Choose a new file name or set overwriteBool=true.')
      end
    end
    
    
    %% Misc
    function summary(obj)
      % summary - print mdData gvArray summaries
      %
      % See also: gvArray/summary
      
      flds = fieldnames(obj.mdData)';
      if ~isempty(flds)
        for mdDataFld = flds
          fprintf(['Hypercube: ' mdDataFld{1} '\n'])
          summary(obj.mdData.(mdDataFld{1}))
          fprintf('\n')
        end
      end
    end
    
    
    function workingDirChild = cwdChild(obj)
      % cwdChild - get name of most descendant directory for cwd path
      
      [workingDir] = fileparts2(obj.gui.data.workingDir);
      if ~ispc
        workingDir = strsplit(workingDir, filesep);
      else
        workingDir = strsplit(workingDir, '\\');
      end
      workingDir = workingDir(~cellfun(@isempty, workingDir));
      workingDirChild = workingDir{end};
    end
    
    
    %% Overloaded built-ins
    function varargout = subsref(obj, S)
      % Notes:
      %	Default settings for cell outputs:
      %	varargout = builtin('subsref', obj, S);
      %
      %	Default settings for non cell outputs:
      %	varargout = {builtin('subsref', obj, S)};
      %
      %	Default settings for multiple outputs:
      %	[varargout{1:nargout}] = builtin('subsref', obj, S);
      %
      %   Only 2 arguments to subsref.
      %
      %   S is a struct array with length equal to number of consecutive
      %   operations to perform. Order follows the order written/performed,
      %   so that the first entry is the closest to the left on the call.
      %
      %   varargout needs to be cell array. Non cell output should  be
      %   enclosed in cell. Multiple outputs should go into cells.
      %   Importantly, if length(S) > 1, meaning multiple consecutive
      %   subsref operations, varargout should equal length of S. Thus,
      %   one needs to make space for recursive outputs when calling
      %   builtin again, which takes the form of a cell{:} multiple outputs.

      switch S(1).type
        case '{}'
          varargout = builtin('subsref', obj, S);
          otherwise
            [varargout{1:nargout}]
          varargout = {builtin('subsref', obj, S)};
      end
    end
    
  end % methods
  
  
  %% Protected Methods %%
  methods (Access = protected)
    
    function fld = nextMdDataFieldName(obj)
      % nextMdDataFieldName - get next default fld for mdData.defaultName#
      
      flds = fieldnames(obj.mdData);
      tokens = regexp(flds,'hypercube(\d+)$', 'tokens');
      tokens = [tokens{:}]; % enter cells
      if ~isempty(tokens)
        tokens = [tokens{:}]; % get ind
        inds = str2double(tokens);
        fld = ['hypercube' num2str(max(inds)+1)];
      else
        fld = 'hypercube1';
      end
    end
    
    function [obj, fldOut] = checkMdDataFieldName(obj, src)
      % Purpose: check if hypercubeName exists as field in mdData.
      %
      % Usage: [obj, hypercubeName_Out] = checkMdDataFieldName(obj, hypercubeName_In)
      %        [obj, hypercubeName_Out] = checkMdDataFieldName(obj, arrayObj)
      %
      % Details:
      %   If 2nd arg is hypercubeName_In, hypercubeName = hypercubeName_In.
      % If 2nd arg is arrayObj, check if hypercubeName = arrayObj.hypercubeName
      % exists. If not, use obj.nextMdDataFieldName.
      %   If hypercubeName is already a field in mdData without a trailing index,
      % add a 1 to original and make this new one with suffix 2. If exists with
      % index, increment to find next index.
      
      if isa(src, 'MDD') % or gvArray
        if isfield(src.meta, 'hypercubeName')
          fldIn = src.meta.hypercubeName;
        else
          fldIn = [];
        end
      elseif ischar(src)
        fldIn = src;
      else
        error('Unknown input')
      end
      
      if ~isempty(fldIn)
        flds = fieldnames(obj.mdData);
        
        hypercubeNameAlreadyExist = any(~cellfun(@isempty, regexp(flds, ['^' fldIn])));
        if hypercubeNameAlreadyExist
          fldInNoDigits = fldIn(1:find(~isstrprop(fldIn, 'digit'), 1, 'last'));
          tokens = regexp(flds,['^' fldInNoDigits '(\d+)$'], 'tokens');
          tokens = [tokens{:}]; % enter cells
          if ~isempty(tokens)
            tokens = [tokens{:}]; % get ind
            inds = str2double(tokens);
            fldOut = [fldInNoDigits num2str(max(inds)+1)];
          else
            % rename field with index 1
            obj.mdData.([fldIn '1']) = obj.mdData.(fldIn);
            obj.mdData = rmfield(obj.mdData, fldIn);
            
            fldOut = [fldIn '2'];
          end
        else
          fldOut = fldIn;
        end
      else % isempty(hypercubeName)
        fldOut = obj.nextMdDataFieldName; % get next fld for mdData.axes#
      end
    end
    
  end % methods (Access = protected)
  
  
  %% Static Methods %%
  methods (Static)
    % Static methods will be capitalized
    
    %% Loading
    function obj = Load(src, hypercubeName)
      % Load - load gv or gvArray object data
      %
      % Usage: obj = gv.Load()
      %        obj = gv.Load(src)
      %        obj = gv.Load(src, hypercubeName)
      %
      % Inputs:
      %   src: is a dir or a file to load.
      %   hypercubeName: is a hypercubeName to store loaded data in. If empty
      %                  will use default indexing.
      %
      % See also: gv/load (public method)
      
      if nargin < 1
        src = [];
      end
      if nargin < 2
        hypercubeName = [];
      end
      
      obj = gv();
      
      obj = obj.load(src, hypercubeName, true);
    end
    
    
    %% Importing
    obj = ImportDsData(varargin)
    
    
    function obj = ImportTabularDataFromFile(varargin)
      % ImportTabularDataFromFile (static) - Imports tabular data from a file to
      %                                      a new set of axes (ie hypercube)
      %
      % Supports file types including: xls, xlsx, csv, tsv, txt, mat.
      %
      % Usage:
      %   obj = obj.ImportTabularDataFromFile(filePath)
      %   obj = obj.ImportTabularDataFromFile(filePath, dataCol, headerFlag, delimiter)
      %
      % Inputs:
      %   filePath: path to file
      %       Supported filetypes:
      %           xls, xlsx, csv, tsv, txt, mat (containing 1 numeric mat variable)
      %               Note: xls and xlsx cannot have columns with mixtures of numerics
      %                     and strings, except for first row. however, txt and csv
      %                     files can.
      %
      % Inputs (optional):
      %   dataCol: col number or header name of column with linear data. the rest of
      %            the columns will be treated as axes. Default is col 1.
      %   headerFlag: logical value of whether 1st row is header of axis names. the
      %               name for dataCol will be ignored. it is only necesary to
      %               explicitly set this to true if the type of data (numeric vs. string)
      %               of the first row is the same as the second row and the first row
      %               should be treated as a header.
      %   delimiter: specify if using a delimiter other than space(' '), comma(','),
      %              or tab('\t'). see strsplit documentation for delimiter specification.
      %
      % See also:
      %   gv/importTabularDataFromFile (public method)
      %   MDD.ImportFile documentation for more information.
      
      obj = gv();
      
      fld = obj.nextMdDataFieldName; % get next fld for mdData.axes#
      
      obj.mdData.(fld) = gvArray.ImportFile(varargin{:});
    end
    
    %% Running
    function obj = Run(loadPath, varargin)
      % Run (static) - run gv
      
      % if load path not defined
      if ~exist('loadPath', 'var') || ~isempty(loadPath)
        loadPath = pwd;
      end
      
      obj = gv.Load(loadPath);
      
      obj = run(obj, varargin{:});
      
      % See also: gv/run (public method)
    end
    
    %% Misc
    
    
  end % methods (Static)
  
  %   methods (Static, Access = protected)
  %
  %   end
  
  
  %% Event Callbacks %%
  methods (Static)
    
    function propPostSetCallback(src,event)
      switch src.Name
        case 'mdData'
          % mdData has triggered an event
          
        case 'meta'
          % meta has triggered an event
          
        case 'gui'
          % gui.data has triggered an event
          fprintf('Test')
      end
    end
    
    
    function guiWindowChangeCallback(src, event)
      obj = src;
      switch event.EventName
        case 'mainWindowChange'
          % Enabled status based on whether main window is open
          [obj.propListeners.Enabled] = deal( isValidFigHandle(obj.gui.data.mainPanel.obj) );
      end
    end
  end
  
end
