classdef gv
  % TODO:
  %   support for mdData fieldname
  %   fill nans in gvarray
  %   load new axes vs load merge axes
  
  %% Protected Properties %%
  properties (Access = protected)
    
  end
  
  %% Public Properties %%
  properties
    mdData = struct() % containing gvArrays
    meta = struct()
    guiData = struct()
  end
  
  %% Public Methods %%
  methods
    
    %% Constructor
    function obj = gv(varargin)
      if nargin
        if ischar(varargin{1})
          if exist(varargin{1}, 'file') || exist(varargin{1}, 'dir') % varargin{1} is a path
            obj = gv.Load(varargin{1});
          end
        elseif iscell(varargin{1}) || isnumeric(varargin{1}) % varargin{1} is built-in data array
          fld = obj.nextMdDataFieldName; % get next fld for mdData.axes#
          obj.mdData.(fld) = gvArray(varargin{1});
        elseif isa(varargin{1}, 'gvArray') || isa(varargin{1}, 'MDD')
          [obj, fld] = checkMdDataFieldName(obj, data);
          obj.mdData.(fld) = gvArray(varargin{1});
        end
      end
    end
    
    
    %% Running
    obj = run(obj, varargin);
    
    
    %% Overloaded built-ins
    %     function varargout = subsref(varargin)
    %       [varargout{1:nargout}] = builtin('subsref',varargin{:});
    %     end
    
  end
  
  %% Protected Methods %%
  methods (Access = protected)

    function fld = nextMdDataFieldName(obj)
      % get next fld for mdData.axes#
      
      flds = fieldnames(obj.mdData);
      tokens = regexp(flds,'axes(\d+)$', 'tokens');
      tokens = [tokens{:}]; % enter cells
      if ~isempty(tokens)
        tokens = [tokens{:}]; % get ind
        inds = str2double(tokens);
        fld = ['axes' num2str(max(inds)+1)];
      else
        fld = 'axes1';
      end
    end
    
    function [obj, fld] = checkMdDataFieldName(obj, arrayObj)
      % check if fld=arrayObj.hypercubeName exists and if fld already a field in mdData.
      % if already a fld, ie mdData.(fld) exists without index suffix, add a 1 to original
      % and make this new one with suffix 2. If exists with index, increment to find next index.
      
      if isfield(arrayObj.meta, 'hypercubeName')
        hypercubeName = arrayObj.meta.hypercubeName;
        flds = fieldnames(obj.mdData);
        
        hypercubeNameAlreadyExist = any(~cellfun(@isempty, regexp(flds, ['^' hypercubeName])));
        if hypercubeNameAlreadyExist
          tokens = regexp(flds,['^' hypercubeName '(\d+)$'], 'tokens');
          tokens = [tokens{:}]; % enter cells
          if ~isempty(tokens)
            tokens = [tokens{:}]; % get ind
            inds = str2double(tokens);
            fld = [hypercubeName num2str(max(inds)+1)];
          else
            % rename field with index 1
            obj.mdData.([hypercubeName '1']) = obj.mdData.(hypercubeName);
            obj.mdData = rmfield(obj.mdData, hypercubeName);

            fld = [hypercubeName '2'];
          end
        else
          fld = hypercubeName;
        end
      else
        fld = obj.nextMdDataFieldName; % get next fld for mdData.axes#
      end
    end
    
  end
  
  %% Static Methods %%
  methods (Static)
    % Static methods will be capitalized
    
    %% Loading
    function obj = Load(varargin)
      % Load - load gv or gvArray object data
      %   varargin{1} is a dir or a file to load.

      if nargin
        src = varargin{1};
      else
        src = pwd;
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
        end
        
        % in case specify dynasim data dir
        if strcmp(matFile{1}, 'studyinfo.mat')
          obj = gv.importDsData(varargin{:}); % ignore src
          return
        end

      end

      % import data
      data = importdata(src);
      if isa(data, 'gv')
        obj = data;
      elseif isa(data, 'gvArray') || isa(data, 'MDD')
        obj = gv();
        
        [obj, fld] = checkMdDataFieldName(obj, data);
%         fld = obj.nextMdDataFieldName; % get next fld for mdData.axes#
        
%         obj.mdData.(fld) = data;
%       elseif isa(data, 'MDD')
%         obj = gv();

        obj.mdData.(fld) = gvArray(data);
      else
        error('Attempting to load non-gv data. Use ''gv.ImportTabularDataFromFile'' instead.')
      end
    end
    
    
    %% Importing
    obj = importDsData(varargin)
    
    function obj = ImportTabularDataFromFile(varargin)
      % ImportTabularDataFromFile - Imports tabular data from a file to a new
      % set of axes
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
      % See 'MDD.importFile' documentation for more information.
      
      obj = gv();
      
      fld = obj.nextMdDataFieldName; % get next fld for mdData.axes#
      
      obj.mdData.(fld) = gvArray.ImportFile(varargin{:});
    end
    
  end
  
%   methods (Static, Access = protected)
%     
%   end
end
