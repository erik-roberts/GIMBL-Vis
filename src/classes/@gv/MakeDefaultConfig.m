function MakeDefaultConfig()
% Dev Notes: make first characters '#!' for eval on load

%% Get Vars
defaultPlugins = '#!{''gvMainWindowPlugin'', ''gvSelectPlugin'', ''gvPlotWindowPlugin''}';
baseFontSize = '12';
closeMainWindowSaveDialogBool = '#!true';
verboseModeBool = '#!false';
autoOpenLoadedPluginWindows = '#!true';
initialGuiPlugin = 'gvMainWindowPlugin';
setInitialViewDims = '#!true';

% gvPlotWindowPlugin
plotColormapScope = 'hypercube'; % {'hypercube', 'slice'}

% gvImageWindowPlugin
defaultImagePath = './images/';
defaultImageRegexp = '^(.+)(\d+)\.\w+$'; % 2 capture groups: 1 for image type, 1 for index
initialImageType = '';

% gvDsPlotWindowPlugin
defaultDsPlotStack = "#!{'', '', ''}";
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
