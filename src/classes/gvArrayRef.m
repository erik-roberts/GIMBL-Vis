%% gvArrayRef - GIMBL-Vis multidimensional data handle class wrapper for gvArray
%
% Description: The gvArrayRef class inherets from the MDDRef class. It uses  
%              gvArray instead of MDD as its value object property.
%
% Author: Erik Roberts

classdef gvArrayRef < MDDRef & matlab.mixin.Copyable
  
  properties (Access = private, SetObservable) % allows listener callback, aborts if set to current value
    valueObj
    valueObjClass = gvArray
  end
  
  methods
    
    function obj = gvArrayRef(varargin)
      metaObj = ?gvArrayRef;
      valueObjClass = metaObj.PropertyList(strcmp('valueObjClass', {metaObj.PropertyList.Name})).DefaultValue;
      
      obj@MDDRef(valueObjClass, varargin{:});
    end
    
  end
  
end