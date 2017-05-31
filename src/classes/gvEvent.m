classdef (ConstructOnLoad) gvEvent < event.EventData
  %% gvEvent - event class for GIMBL-Vis
  %
  % Description: This subclass of event.EventData permits storage of a value. If
  % the constructor is passed a char cast of a numeric, it will be recast to a
  % numeric.
  
  properties
    value
  end
  
  methods
    function eventData = gvEvent(value)
      if ~exist('value','var')
        value = [];
      end
      
      if ischar(value) && ~isnan(str2double(value))
        value = str2double(value);
      end
      
      eventData.value = value;
    end
  end
end