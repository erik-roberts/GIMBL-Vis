function Callback_dsPlot_panel_importDataButton(src, evnt)
pluginObj = src.UserData.pluginObj; % window plugin
modelObj = pluginObj.controller.model;

cwd = pluginObj.controller.app.workingDir;
try
  modelObj.activeHypercube.meta.simData = dsImport(cwd, 'as_cell',1);
  
  pluginObj.vprintf('gvDsPlotWindowPlugin: Imported all DS data\n')
catch
  wprintf('Cannot import data. Tip: Set Working Dir to dir containing studyinfo.mat')
end

end