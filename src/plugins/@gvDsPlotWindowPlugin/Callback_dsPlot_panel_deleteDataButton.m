function Callback_dsPlot_panel_deleteDataButton(src, evnt)
pluginObj = src.UserData.pluginObj; % window plugin
modelObj = pluginObj.controller.model;

if isfield(modelObj.activeHypercube.meta, 'simData')
  modelObj.activeHypercube.meta = rmfield(modelObj.activeHypercube.meta, 'simData');
  
  pluginObj.vprintf('[gvDsPlotWindowPlugin] Deleted all DS data\n')
else
  pluginObj.vprintf('[gvDsPlotWindowPlugin] No DS data to delete\n')
end

end