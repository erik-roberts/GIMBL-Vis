function MakeDefaultConfig()
% Dev Notes: make first characters '#!' for eval on load

%% Get Vars
defaultPlugins = '#!{''gvMainWindowPlugin'', ''gvPlotWindowPlugin''}';
baseFontSize = '14';

%% Write vars to disk
vars = who; % get all vars

configPath = fullfile(gv.RootPath, 'gvConfig.txt');
fid = fopen(configPath, 'w');

for thisVar = vars(:)'
  thisVar = thisVar{1};
  
  fprintf(fid, '%s = "%s"\r\n', thisVar,eval(thisVar));
end

fclose(fid);

end
