classdef uixVRadioBox < uix.VBox
  %uixVRadioBox  Vertical box
  %
  %  b = uixVRadioBox(p1,v1,p2,v2,...) constructs a vertical box and sets
  %  parameter p1 to value v1, etc.
  %
  %  A vertical box lays out radio buttons from top to bottom.
  %
  %  See also: uix.VBox, uix.HBox, uix.Grid, uix.VButtonBox, uix.VBoxFlex
  
  properties
    Callback
  end
  
  properties (Dependent)
    Value
    String
    Button
  end
  
  methods
    
    function obj = uixVRadioBox( varargin )
      %uixVRadioBox  Vertical box constructor
      %
      %  b = uixVRadioBox() constructs a horizontal box.
      %
      %  b = uixVRadioBox(p1,v1,p2,v2,...) sets parameter p1 to value v1,
      %  etc.
      
      % Set properties
      obj@uix.VBox(varargin{:});
      
    end % constructor
    
    
    function value = get.Value(obj)
      value = find([obj.Children.Value]);
    end
    
    
    function str = get.String(obj)
      str = {obj.Children.String}';
    end
    
    
    function button = get.Button(obj)
      button = obj.Children(obj.Value);
    end
    
  end
  
  methods (Access = protected)
    
    function addChild( obj, child )
      %addChild  Add child
      %
      %  c.addChild(d) adds the child d to the container c.
      
      child.Style = 'radiobutton';
      child.Callback = @uixVRadioBox.Callback_radiobutton;
      
      if isequal(obj.Children, child)
        child.Value = 1;
      end
      
      % Call superclass method
      addChild@uix.VBox( obj, child )
      
    end % addChild
    
  end
  
  methods (Static)
    
    function Callback_radiobutton(src,~)
      % ensure src is value=1
      src.Value = 1;

      % make other values 0
      buttonHandles = src.Parent.Children;
      [buttonHandles(src ~= buttonHandles).Value] = deal(0);
      
      % call box callback
      if ~isempty(src.Parent.Callback)
        feval(src.Parent.Callback, src.Parent);
      end
    end
    
  end
  
end

