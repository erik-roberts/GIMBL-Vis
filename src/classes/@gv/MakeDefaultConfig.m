function MakeDefaultConfig()
% Dev Notes: make first characters '#!' for eval on load

%% Get Vars
defaultPlugins = '#!{''gvMainWindowPlugin'', ''gvSelectPlugin'', ''gvPlotWindowPlugin''}';
baseFontSize = '12';
closeMainWindowSaveDialogBool = '#!true';
verboseModeBool = '#!false';
autoOpenLoadedPluginWindows = '#!true';

% gvPlotWindowPlugin
plotColormapScope = 'hypercube'; % {'hypercube', 'slice'}

% gvImageWindowPlugin
defaultImagePath = './images/';
defaultImageRegexp = '^(.+)(\d+)\.\w+$'; % 2 capture groups: 1 for image type, 1 for index

% gvDsPlotWindowPlugin
defaultDsPlotFn = '@dsPlot';
defaultDsPlotFnOpts = '''fig_handle'',h';
defaultDsPlotImportMode = 'withPlot';

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
