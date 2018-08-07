function cellOut = struct2KeyValueCell(s)
%% struct2KeyValueCell
% Purpose: convert struct to key value comma separated cell array of field names
% and values
%
% Author: Erik Roberts

cellOut = [fieldnames(s), struct2cell(s)]';

cellOut = cellOut(:)';

end