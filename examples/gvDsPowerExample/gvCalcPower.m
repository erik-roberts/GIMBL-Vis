function cellOut = gvCalcPower(data,varargin)
%% gvCalcPower
%  Purpose: This wrapper function for dsCalcPower is used as a DynaSim analysis
%           function for calculating the power spectrum vector of a
%           simulation. It should be used in tandem with gvImportDsPower.
%
%  Inputs:
%   unit_type: power calculated for 'SUA' or 'MUA' (default).
%
% See also: dsCalcPower, gvImportDsPower

%% Check inputs
options=dsCheckOptions(varargin,{...
  'variable',[],[],...
  'output_suffix','',[],...
  'unit_type', 'MUA', {'SUA', 'MUA'},...
  },false);

% select variable
var = dsSelectVariables(data(1),options.variable, varargin{:});
var = var{1};

% calculate the power
data = dsCalcPower(data, varargin{:});

% pull out power and freqs
switch options.unit_type
  case 'SUA'
    sxx = data.([var '_Power_SUA' options.output_suffix]).Pxx;
    freq = data.([var '_Power_SUA' options.output_suffix]).frequency;
  case 'MUA'
    sxx = data.([var '_Power_MUA' options.output_suffix]).Pxx;
    freq = data.([var '_Power_MUA' options.output_suffix]).frequency;
end

% store power and freqs in a matrix
cellOut = {[sxx(:), freq(:)]};

end % gvCalcPower