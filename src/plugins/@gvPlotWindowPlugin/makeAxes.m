function makeAxes(pluginObj)
% makeAxes - make plot window figure axes grid based on number of viewDims

plotWindowHandle = pluginObj.handles.fig;

if ~pluginObj.checkWindowExists()
  pluginObj.vprintf('Skipping axis creation since window not open.\n')
  return
end

clf(plotWindowHandle) %clear fig

nViewDims = pluginObj.view.dynamic.nViewDims;

gap = 0.1;
marg_h = 0.1;
marg_w = 0.1;

gap_s = 0.03;
marg_h_s = 0.03;
marg_w_s = 0.03;

switch nViewDims
  case 1
    % 1 1d pane
    %         axes(hFig)
    %       hspg = subplot_grid(1,'no_zoom', 'parent',hFig);
    tight_subplot2(1, 1, gap, marg_h, marg_w, plotWindowHandle);
  case 2
    % 1 2d pane
    %         axes(hFig)
    %       hspg = subplot_grid(1,'no_zoom', 'parent',hFig);
    tight_subplot2(1, 1, gap, marg_h, marg_w, plotWindowHandle);
  case 3
    % 3 2d panes + 1 3d pane = 4 subplots
    %       hspg = subplot_grid(2,2, 'parent',hFig);
    tight_subplot2(2, 2, gap, marg_h, marg_w, plotWindowHandle);
  case 4
    % 6 2d panes + 4 3d pane = 10 subplots
    %       hspg = subplot_grid(2,5, 'parent',hFig);
    tight_subplot2(2, 5, gap_s, marg_h_s, marg_w_s, plotWindowHandle);
  case 5
    % 10 2d panes + 10 3d pane = 20 subplots
    %       hspg = subplot_grid(3,7, 'parent',hFig); % 1 empty
    tight_subplot2(3, 7, gap_s, marg_h_s, marg_w_s, plotWindowHandle);
  case 6
    % 15 2d panes = 15 subplots
    %       hspg = subplot_grid(3,5, 'parent',hFig);
    tight_subplot2(3, 5, gap_s, marg_h_s, marg_w_s, plotWindowHandle);
  case 7
    % 21 2d panes = 21 subplots
    %       hspg = subplot_grid(3,7, 'parent',hFig);
    tight_subplot2(3, 7, gap_s, marg_h_s, marg_w_s, plotWindowHandle);
  case 8
    % 28 2d panes = 28 subplots
    %       hspg = subplot_grid(4,7, 'parent',hFig);
    tight_subplot2(4, 7, gap_s, marg_h_s, marg_w_s, plotWindowHandle);
  otherwise
    pluginObj.vprintf('Select 1-8 dimensions to plot.\n')
end

hAx = plotWindowHandle.Children;
hAxBool = false(length(hAx),1);

for hInd = 1:length(hAx)
  hAxBool(hInd) = strcmp(hAx(hInd).Type, 'axes');
end
hAx = hAx(hAxBool);

hAx = flip(hAx); % since given backwards

if nViewDims > 0
  pluginObj.handles.ax = hAx;
else
  pluginObj.handles.ax = [];
end

end
