%% gvArray - GIMBL-Vis multidimensional data storage class
%
% Description: The gvArray class inherets from the MDD class. It uses gvArrayAxis 
%              instead of MDDAxis.
%
% gvArray adds the following methods to MDD:
%
% Methods (public):
%   axisValues - alias for MDD's exportAxisVals
%   axisNames - alias for MDD's exportAxisNames
%   summary - alias for MDD's printAxisInfo
%
% Methods (static):
%   mdd2gv - convert MDD superclass object to gvArray subclass
%
% Author: Erik Roberts
%
% See also: MDD documentation

classdef gvArray < MDD
  
  properties (Access = private)
    data_pr        % Storing the actual data (multi-dimensional matrix or cell array)
    axis_pr        % 1xNdims - array of gvArrayAxis classes for each axis. Ndims = ndims(data)
    axisClass = gvArrayAxis
  end
  
  properties (Hidden)
    hypercubeName = ''
  end
  
  methods
    
    function obj = gvArray(varargin)
      % gvArray - constructor
      %
      % Usage:
      %   obj = gvArray()
      %   obj = gvArray(data) % multidimensional data
      %   obj = gvArray(data, axis_vals, axis_names) % multidimensional or linear data
      %   obj = gvArray(mddObj) % convert MDD to gvArray
      
      metaObj = ?gvArray;
      axisClass = metaObj.PropertyList(strcmp('axisClass', {metaObj.PropertyList.Name})).DefaultValue;
      
      % constructor conversion to gvArray from MDD step 1
      if nargin==1 && (isa(varargin{1}, 'MDD') || isa(varargin{1}, 'MDDRef'))
        mdobj = varargin{1};
        varargin = {};
      end
      
      % call superclass constructor
      obj@MDD(axisClass, varargin{:});
      
      % constructor conversion to gvArray from MDD step 2
      if exist('mdobj', 'var')
        obj = gvArray.mdd2gv(mdobj);
      end
    end
    
    
    function out = axisValues(obj)
      % axisValues - alias for MDD's exportAxisVals
      
      out = exportAxisVals(obj);
    end
    
    
    function out = axisNames(obj)
      % axisNames - alias for MDD's exportAxisNames
       
      out = exportAxisNames(obj);
    end
    
    
    function out = summary(obj, varargin)
      % summary - alias for MDD's printAxisInfo
      if nargout > 0
        out = printAxisInfo(obj, varargin{:});
      else
        printAxisInfo(obj, varargin{:});
      end
    end
    
    
%     function obj = str2ind(obj)
%       % convert all string data to numerical indicies
%       % TODO if necesary
%     end
    
    
    function mddobj = gv2mdd(gvObj)
      % Convert gvArray subclass object to MDD superclass
      
      data = gvObj.data;
      ax_vals = gvObj.exportAxisVals;
      ax_names = gvObj.exportAxisNames;
      
      mddobj = MDD(data, ax_vals, ax_names);
      
      mddobj = gvArray.addMeta(gvObj, mddobj);
    end
    
    %% Overloaded built-ins
    
  end
  
  
  methods (Access = protected)
    
    function fld = nextAxesDataTypeName(obj)
      % Get next data type label for given axes. This should only be called if
      % dataType label not specified elsewhere.
      %
      % Example:
      %  gvArrayObj.axis(end).name = 'dataType';
      %  gvArrayObj.axis(end).values = {'str', 'data1', 'data#'}; -> find #
      
      axisNames = obj.axisNames;
      
      typeInd = strcmp(axisNames, 'dataType');
      
      types = obj.axis(typeInd).values;
      
      tokens = regexp(types,'data(\d+)$', 'tokens');
      tokens = [tokens{:}]; % enter cells
      if ~isempty(tokens)
        tokens = [tokens{:}]; % get ind
        inds = str2double(tokens);
        fld = ['data' num2str(max(inds)+1)];
      else
        fld = 'data1';
      end
    end
    
    function obj = fillnan(obj)
      % fillnan - fill empty cells with nan
      
      if iscell(obj.data)
        obj.data(cellfun(@isempty, obj.data)) = deal({nan});
      end
    end
    
  end % methods (Access = protected)
  
  
  methods (Static)
    
    % ** start Import Methods **
    %   Note: these can be called as static (ie class) methods using
    %   uppercase version or as object methods using lowercase version
    function obj = ImportDataTable(varargin)    % Function for importing data in a 2D table format
      % instantiate object
      obj = gvArray();
      
      % call object method
      obj = importDataTable(obj, varargin{:});
    end
    
    function obj = ImportData(varargin)
      % instantiate object
      obj = gvArray();
      
      % call object method
      obj = importData(obj, varargin{:});
    end
    
    function obj = ImportFile(varargin) % import linear data from data file (using importDataTable method)
      % instantiate object
      obj = gvArray();
      
      % call object method
      obj = importFile(obj, varargin{:});
    end
    % ** end Import Methods **
    
    
    function gvobj = mdd2gv(mddobj)
      % mdd2gv - Convert MDD superclass object to gvArray subclass
      
      % input already a gvArray
      if isa(mddobj, 'gvArray')
        gvobj = mddobj;
        return
      end
      
      data = mddobj.data;
      ax_vals = mddobj.exportAxisVals;
      ax_names = mddobj.exportAxisNames;
      
      gvobj = gvArray(data, ax_vals, ax_names);
      
      gvobj = gvArray.addMeta(mddobj, gvobj);
    end
    
    
    function targetObj = addMeta(sourceObj, targetObj)
      % add meta
      targetObj.meta = sourceObj.meta;
      
      % add axis meta
      nAx = length(sourceObj.axis);
      for axInd = 1:nAx
        targetObj.axis(axInd).axismeta = sourceObj.axis(axInd).axismeta;
      end
    end
    
  end % methods (Static)
  
end % classdef