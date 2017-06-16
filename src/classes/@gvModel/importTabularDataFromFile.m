function importTabularDataFromFile(modelObj, fld, varargin)
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

if isempty(fld)
  fld = modelObj.nextModelFieldName; % get next fld for model.axes#
else
  [modelObj, fld] = checkHypercubeName(modelObj, fld);
end

modelObj.data.(fld) = gvArrayRef.ImportFile(varargin{:});

end