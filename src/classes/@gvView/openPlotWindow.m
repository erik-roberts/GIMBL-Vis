function openPlotWindow(viewObj)

mainWindowExistBool = viewObj.checkMainWindowExists;

nViewDims = viewObj.plotWindow.nViewDims;
nViewDimsLast = viewObj.plotWindow.nViewDimsLast;

if mainWindowExistBool && ~isValidFigHandle(viewObj.plotWindow.windowHandle) || nViewDims ~= nViewDimsLast
  
  % Make New Panel
  if ~isValidFigHandle(viewObj.plotWindow.windowHandle)
    mainWindowPos = viewObj.mainWindow.windowHandle.Position;
    
    plotWindowHandle = figure('Name','Plot Window','NumberTitle','off',...
      'Position',[mainWindowPos(1)+mainWindowPos(3)+50, mainWindowPos(2), 600,500]);
    plotWindowHandle.WindowButtonMotionFcn = @gvPlotWindowMouseMoveCallback;
    
    % set plot windowHandle
    viewObj.plotWindow.windowHandle = plotWindowHandle;
    
    newPanelBool = true;
  else
    plotWindowHandle = viewObj.plotWindow.windowHandle;
    
    newPanelBool = false;
  end
  
  % Add user data to figure
  plotWindowHandle.UserData.mdData = handles.mdData;
  plotWindowHandle.UserData.MainFigH = handles.output;
  
  % Data cursor
  dm = datacursormode(plotWindowHandle);
  dm.UpdateFcn = @gvDataCursorCallback;
  
  %   if isfield(handles.PlotWindow, 'handle') && isvalid(handles.PlotWindow.figHandle)
  %     hFig = handles.PlotWindow.figHandle;
  %
  %     if ~ishandle(hFig)
  %       close(hFig.hfig)
  %       hFig = figure;
  %       axes(hFig)
  %     end
  %   else
  %     hFig = figure;
  %     axes(hFig)
  %     handles.PlotWindow.figHandle = hFig;
  %
  %     % Update handles structure
  %     guidata(hObject, handles);
  %   end
  
  % Update Panel
  clf(plotWindowHandle) %clear fig
  gap = 0.1;
  marg_h = 0.1;
  marg_w = 0.1;
  switch nViewDims
    case 1
      % 1 1d pane
      %         axes(hFig)
      %       hspg = subplot_grid(1,'no_zoom', 'parent',hFig);
      hAx = tight_subplot2(1, 1, gap, marg_h, marg_w, plotWindowHandle);
    case 2
      % 1 2d pane
      %         axes(hFig)
      %       hspg = subplot_grid(1,'no_zoom', 'parent',hFig);
      hAx = tight_subplot2(1, 1, gap, marg_h, marg_w, plotWindowHandle);
    case 3
      % 3 2d panes + 1 3d pane = 4 subplots
      %       hspg = subplot_grid(2,2, 'parent',hFig);
      hAx = tight_subplot2(2, 2, gap, marg_h, marg_w, plotWindowHandle);
    case 4
      % 6 2d panes + 4 3d pane = 10 subplots
      %       hspg = subplot_grid(2,5, 'parent',hFig);
      hAx = tight_subplot2(2, 5, gap, marg_h, marg_w, plotWindowHandle);
    case 5
      % 10 2d panes + 10 3d pane = 20 subplots
      %       hspg = subplot_grid(3,7, 'parent',hFig); % 1 empty
      hAx = tight_subplot2(3, 7, gap, marg_h, marg_w, plotWindowHandle);
    case 6
      % 15 2d panes = 15 subplots
      %       hspg = subplot_grid(3,5, 'parent',hFig);
      hAx = tight_subplot2(3, 5, gap, marg_h, marg_w, plotWindowHandle);
    case 7
      % 21 2d panes = 21 subplots
      %       hspg = subplot_grid(3,7, 'parent',hFig);
      hAx = tight_subplot2(3, 7, gap, marg_h, marg_w, plotWindowHandle);
    case 8
      % 28 2d panes = 28 subplots
      %       hspg = subplot_grid(4,7, 'parent',hFig);
      hAx = tight_subplot2(4, 7, gap, marg_h, marg_w, plotWindowHandle);
    otherwise
      if newPanelBool
        wprintf('Select at least 1 ViewDim to plot.')
      end
  end
  
  %   if exist('hspg', 'var')
  %     handles.PlotWindow.figHandle = hspg;
  %
  %     % Update handles structure
  %     guidata(hObject, handles);
  %
  %     % Plot
  %     gvPlot(hObject, eventdata, handles);
  %   end
  
  if nViewDims > 0
    % Axis handle
    handles.PlotWindow.axHandle = hAx;
    
    % Plot
    handles = gvPlot(hObject, eventdata, handles);
  end
end

end % main fn