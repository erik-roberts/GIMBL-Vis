function gvRunDS(data_dir, options)
if ~exist('data_dir', 'var') || isempty(data_dir)
  data_dir = pwd;
end

if ~exist('options', 'var') || isempty(options)
  options = struct();
end

options.overwriteBool = 0;
data = gvLoadDSdata(data_dir, options);

gvMainPanel(data);

end