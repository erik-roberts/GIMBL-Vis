%% gv - main class for GIMBL-Vis
%
% Properties (public):
%   TODO
%
% Methods (public):
%   gv: constructor
%   load: load gv or gvArray object data
%   importTabularDataFromFile
%   run: run gv GUI
%   save: save gv object to file
%   summary: print model gvArray summaries
%   cwdChild: get name of most descendant directory for cwd path
%
% Methods (static):
%   Load: load gv or gvArray object data
%   ImportDsData: import dynasim data
%   ImportTabularDataFromFile
%
% Note: gv is a handle class, which means that objects are passed by reference
%       instead of by value. For more info visit:
%       https://www.mathworks.com/help/matlab/matlab_oop/comparing-handle-and-value-classes.html
%
% Author: Erik Roberts

classdef gv < handle
  
  %% Public Properties %%
  properties %(SetObservable, AbortSet) % allows listener callback, aborts if set to current value
    %meta = struct()
    workingDir = pwd
  end
  
  properties (SetAccess = private)
    config
  end
  
%     %% Set Properties %%
%     methods
%   
%       function set.model(obj, value)
%         obj.model.data = value;
%       end
%   
%       function set.view(obj, value)
%         obj.view = value;
%       end
%       
%       function set.controller(obj, value)
%         obj.controller = value;
%       end
%       
%       function set.meta(obj, value)
%         obj.meta = value;
%       end
%   
%     end
  
  %% Properties %%
  properties
    model % = gvModel(gvObj)
    controller % = gvController(gvObj)
    view % = gvView(gvObj)
  end
  
  
  %% Public Methods %%
  methods
    
    %% Constructor
    function gvObj = gv(varargin)
      % gv - constructor
      %
      % Usage:
      %   1) Make empty gv object
      %       gvObj = gv()
      %
      %   2) Call load method on file/dir
      %       gvObj = gv(file/dir)
      %       gvObj = gv(file/dir, hypercubeName)
      %
      %   3) Call gvArray constructor on gvArray/MDD data
      %       gvObj = gv(gvArrayData)
      %       gvObj = gv(hypercubeName, gvArrayData)
      %
      %   4) Call gvArray constructor on cell/numeric array data. Can be linear
      %      or multidimensional array data.
      %       gvObj = gv(cell_or_numeric_array)
      %       gvObj = gv(hypercubeName, cell_or_numeric_array)
      %       gvObj = gv(cell_or_numeric_array, axis_vals, axis_names)
      %       gvObj = gv(hypercubeName, cell_or_numeric_array, axis_vals, axis_names)
      
%       % Add GUI propListeners
%       obj.gui.data.mainWindow.obj = []; % set empty Main window obj
%       addlistener(obj, 'mainWindowChange', @gv.guiWindowChangeCallback);
%       
%       % Add Property propListeners
%       obj.propListeners{1} = addlistener(obj,'model','PostSet',@gv.propPostSetCallback);
%       obj.propListeners{2} = addlistener(obj,'meta','PostSet',@gv.propPostSetCallback);
%       obj.propListeners{3} = addlistener(obj,'gui','PostSet',@gv.propPostSetCallback);
%       obj.propListeners = [obj.propListeners{:}]; % convert to proplistener array
%       
%       [obj.propListeners.Enabled] = deal(false); % disable until window opens
      
      gvObj.updateConfig()

      gvObj.setupMVC();
      
      % TODO Move to separate function or gvModel/Controller
      if nargin
        if ischar(varargin{1})
          if exist(varargin{1}, 'file') || exist(varargin{1}, 'dir') % varargin{1} is a path
            % 2) Call load method on file/dir
            gvObj = gv.Load(varargin{:});
            return
          else % treat varargin{1} as fld (aka hypercubeName)
            fld = varargin{1};
            varargin(1) = [];
          end
        end
        
        % Check hypercubeName if given as varargin{1}
        if exist('fld', 'var')
          fld = gvObj.model.checkHypercubeName(fld);
        end
        
        if iscell(varargin{1}) || isnumeric(varargin{1}) % varargin{1} is built-in data array
          % 4) Call gvArray constructor on cell/numeric array data.
          if ~exist('fld', 'var')
            fld = gvObj.model.nextModelFieldName; % get next fld for model.axes#
          end
                    
          % Add hypercube
          hypercubeObj = gvArrayRef(varargin{:});
          hypercubeName = fld;
          gvObj.model.addHypercube(hypercubeObj, hypercubeName);
          
          gvObj.controller.setActiveHypercube(fld);
        elseif isa(varargin{1}, 'MDD') || isa(varargin{1}, 'MDDRef') % || isa(varargin{1}, 'gvArray')
          % 3) Call gvArray constructor on gvArray/MDD data
          if ~exist('fld', 'var')
            fld = gvObj.model.checkHypercubeName(varargin{1});
          end
          
          % Add hypercube
          hypercubeObj = gvArrayRef(varargin{:});
          hypercubeName = fld;
          gvObj.model.addHypercube(hypercubeObj, hypercubeName);
        end
      else
        % 1) Make empty gv object
      end
    end
    
    
    %% Loading
    function load(gvObj, varargin)
      % load - load gv or gvArray object data
      %
      % Usage: gvObj.load()
      %        gvObj.load(src)
      %        gvObj.load(src, hypercubeName)
      %
      % Inputs:
      %   src: is a dir or a file to load.
      %   hypercubeName: is a hypercubeName to store loaded data in. If empty
      %                  will use default indexing.
      %
      % See also: gv.Load (static method)
      
      gvObj.model.load(varargin{:}) % interface: load(obj, src, fld, staticBool)
      
    end
    
    
    %% Importing
    function importTabularDataFromFile(gvObj, varargin)
      % importTabularDataFromFile (public) - Imports tabular data from a file to
      %                                      a new set of axes (ie hypercube)
      %
      % Supports file types including: xls, xlsx, csv, tsv, txt, mat.
      %
      % Usage:
      %   gvObj.importTabularDataFromFile([], filePath)
      %   gvObj.importTabularDataFromFile(hypercubeName, filePath, dataCol, headerFlag, delimiter)
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
      
      gvObj.model.importTabularDataFromFile(varargin{:}) % interface: load(modelObj, fld, varargin)
      
    end
    
    function importDsData(gvObj, varargin)
      % importDsData - import dynasim data
      %
      % Usage:
      %   gvObj.importDsData(src, varargin)
      %
      % See also: gvModel/importDsData
      
      gvObj.model.importDsData(varargin{:});
    end
    
    
    %% Running
    function varargout = run(gvObj, varargin)
      % run (public) - run gv GUI
      %
      % See also: gv.Run (static method)

      % if specify load path
      if nargin > 1 && ischar(varargin{1})
        gvObj.workingDir = varargin{1};
      end
      
      gvObj.view.run();
      
      if nargout
        varargout{1} = gvObj;
      end
    end
    
    
    %% Saving
    function save(gvObj, filePath, overwriteBool) %#ok<INUSL>
      % save - save gv object to file (default: 'gvData.mat')
      
      if ~exist('filePath', 'var') || isempty(filePath)
        filePath = 'gvData.mat';
      end
      if nargin < 3
        overwriteBool = false;
      end
      
      if ~exist(filePath,'file') || overwriteBool
        gvObj.view.closeWindows();
        save(filePath, 'gvObj');
      else
        wprintf('File exists and overwriteBool=false. Choose a new file name or set overwriteBool=true.')
      end
    end
    
    
    %% Misc
    function varargout = printHypercubeList(gvObj)
      if nargout
        varargout = gvObj.model.printHypercubeList();
      else
        gvObj.model.printHypercubeList();
      end
    end
    
    
    function summary(gvObj)
      % summary - print gv object summary
      %
      % See also: gvModel/summary, gvArray/summary
      
      fprintf('GIMBL-Vis Object Summary:\n')
      fprintf('-------------------------\n')
      
      % Print model summary
      gvObj.model.summary;
      
      fprintf('\n')
      
      % Print controller summary
      gvObj.controller.summary;
      
      fprintf('\n')
      
      % Print view summary
      gvObj.view.summary;
      
      fprintf('\n')
    end
    
    
    function updateConfig(gvObj)
      gvConfigFile = fullfile(gv.RootPath(),'gvConfig.txt');
      
      if ~exist(gvConfigFile, 'file')
        gv.MakeDefaultConfig();
      end
      
      fid = fopen(gvConfigFile, 'r');
      gvVarCells = textscan(fid, '%s = %q');
      fclose(fid);
      
      gvConfig = struct();
      
      for iRow = 1:size(gvVarCells{1}, 1)
        thisStr = gvVarCells{2}{iRow};
        
        thisStr = shebangParse(thisStr);
        
        if ~isnan(str2double(thisStr))
          thisStr = str2double(thisStr);
        end
        
        gvConfig.(gvVarCells{1}{iRow}) = thisStr;
      end

      gvObj.config = gvConfig;
    end
    
    
    function printWindowPositions(gvObj)
      % wrap view.printWindowPositions
      
      gvObj.view.printWindowPositions();
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
        case '()'
          temp = S.subs(:);
          obj.load( temp{:} );
        otherwise
          [varargout{1:nargout}] = builtin('subsref', obj, S);
      end
    end
    
  end % public methods
  
  
  %% Hidden Methods %%
  methods (Hidden)
    
    function vprintf(gvObj, varargin)
      if gvObj.config.verboseModeBool
        fprintf(varargin{:});
      end
    end
    
    
    function workingDirChild = cwdChild(gvObj)
      % cwdChild - get name of most descendant directory for cwd path
      
      [workingDir] = fileparts2(gvObj.workingDir);
      if ~ispc
        workingDir = strsplit(workingDir, filesep);
      else
        workingDir = strsplit(workingDir, '\\');
      end
      workingDir = workingDir(~cellfun(@isempty, workingDir));
      workingDirChild = workingDir{end};
    end
    
  end
  
  
  %% Protected Methods %%
  methods (Access = protected)
  
    function setupMVC(gvObj)
      gvObj.model = gvModel(gvObj);
      gvObj.view = gvView(gvObj);
      gvObj.controller = gvController(gvObj);
      
      gvObj.model.setup();
      gvObj.controller.setup();
      gvObj.view.setup();
    end
    
    
    function replaceApp(gvObj, newObj)
      % replaceApp - replace gv object with supplied one
      
      gvObj.delete();
      
      gvObj = gv();
      
      gvMeta = ?gv;
      props = {gvMeta.PropertyList.Name};
      props = props(~[gvMeta.PropertyList.Dependent]);
      
      for prop = props
        gvObj.(prop{1}) = newObj.(prop{1});
      end
    end
    
  end % methods (Access = protected)
  
  
  %% Static Methods %%
  methods (Static)
    % Dev Note: Static methods will be capitalized
    
    %% Loading
    function gvObj = Load(src, hypercubeName, varargin)
      % Load - load gv, gvArray, or multidimensional object data
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
      
      gvObj = gv();
      
      % update working dir with char src
      if ischar(src)
        gvObj.workingDir = src;
      end
      
      gvObj.load(src, hypercubeName, varargin{:});
    end
    
    
    %% Importing
    function gvObj = ImportTabularDataFromFile(varargin)
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
      
      gvObj = gv();
      
      gvObj.importTabularDataFromFile(varargin{:});
    end
    
    
    function gvObj = ImportDsData(varargin)
      % ImportDsData (static) - import dynasim data
      %
      % Usage:
      %   gv.ImportDsData(src, varargin)
      %
      % See also: gvModel/importDsData
      
      gvObj = gv();
      
      gvObj.importDsData(varargin{:});
    end
    
    
    %% Running
    function varargout = Run(loadPath, varargin)
      % Run (static) - run gv
      %
      % See also: gv/run (public method)
      
      % if load path not defined
      if ~exist('loadPath', 'var') || isempty(loadPath)
        loadPath = pwd;
      end
      
      gvObj = gv.Load(loadPath, [], varargin{:});
      
      gvObj.run(loadPath, varargin{:});
      
      if nargout
        varargout{1} = gvObj;
      end
    end
    
    %% Misc
    function pathstr = RootPath()
      % RootPath - Path to gv root directory
      
      pathstr = fullfile(fileparts(which('gv')), '..', '..', '..');
    end

    function GenerateDocumentation()
      %GenerateDocumentation - Build GIMBL-Vis documentation
      
      cwd = pwd; % store current working dir
      
      cd(gv.RootPath());
      
      m2html('mfiles',{'src'},...
        'htmldir','offline_docs',...
        'recursive','on',...
        'global','on',...
        'template','frame',...
        'index','menu',...
        'graph','on',...
        'ignoredDir', 'dependencies');
      
      cd(cwd);
    end
    
    MakeDefaultConfig()
    
    function EditConfig()
      configPath = fullfile(gv.RootPath, 'gvConfig.txt');
      if exist(configPath, 'file')
        edit(configPath);
      else
        gv.MakeDefaultConfig();
        edit(configPath);
      end
    end
    
  end % static methods
  
  %% Hidden Static Methods %%
  methods (Static, Hidden)
    
    function pluginNames = ListPluginsFromDir()
      pluginFiles = lscell(fullfile(gv.RootPath, 'src', 'plugins'));
      pluginNames = regexp(pluginFiles, '^@?(\w+)(?:\.\w+)?$','tokens');
      pluginNames = [pluginNames{:}];
      pluginNames = [pluginNames{:}];
      pluginNames = sort(pluginNames);
    end
    
  end
  
end % classdef
