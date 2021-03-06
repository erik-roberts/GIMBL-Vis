%% gvArrayAxis
%
% Purpose: stores axis information (see superclass 'MDDAxis'), but also stores
% axis type and plot info.
%
% Notes:
%   Axis Type: stored in property 'axismeta.axisType'. Example is 'dataType'.
%
%   If axisType=='dataType', then this axis stores different data types,
%   including index, numeric, ordinal, and categorical. The data type for
%   each axis is stored in 'axismeta.dataType'. Plot metadata for each
%   data type index is stored in 'axismeta.plotInfo' in cells corresponding 
%   to the given data type index. Categorical data may store data labels,
%   along with corresponding marker colors and styles.
%
% Author: Erik Roberts

classdef gvArrayAxis < MDDAxis
  
  methods
    
    function axObj = gvArrayAxis(varargin)
      % gvArrayAxis - constructor
      %
      % Usage:
      %   obj = gvArrayAxis()
      %   obj = gvArrayAxis(axis_vals)
      %   obj = gvArrayAxis(axis_vals, axis_name)
      %   obj = gvArrayAxis(axis_vals, axis_name, axismeta)
            
      axObj@MDDAxis(varargin{:});
    end
    
    function vals = valueAsStr(axObj, ind)
       vals = axObj.getvalue_char(ind);
    end
    
  end
  
end
