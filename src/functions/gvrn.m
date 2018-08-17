function gvObj = gvrn(varargin)
  %% gvrn - alias for gv.Run with nonLatticeVarCombineBool = 1
  %
  % Implementation: gv.Run([], 'nonLatticeVarCombineBool',1, varargin{:})
  
  gvObj = gv.Run([], 'nonLatticeVarCombineBool',1, varargin{:});
end