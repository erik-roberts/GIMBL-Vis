function Callback_dsPlot_panel_importDataButton(src, evnt)
pluginObj = src.UserData.pluginObj; % window plugin
modelObj = pluginObj.controller.model;

cwd = pluginObj.controller.app.workingDir;
try
  modelObj.activeHypercube.meta.simData = dsImport(cwd);
catch
  wprintf('Cannot import data. Tip: Set Working Dir to dir containing studyinfo.mat')
end

end