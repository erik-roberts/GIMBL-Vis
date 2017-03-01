function varargout = imdpPlot(hObject, eventdata, handles)

nViewDims = handles.PlotPanel.nViewDims;
viewDims = handles.PlotPanel.viewDims;
% nAxDims = handles.PlotPanel.nAxDims;
hFig = handles.PlotPanel.figHandle;
hAx = handles.PlotPanel.axHandle;
mdData = handles.mdData;
dimNames = mdData.dimNames;

if ~isValidFigHandle(hFig)
  return
end

lFontSize = 14;
lMarkerSize = 16; %legend marker size

figure(hFig); % set hFig for gcf

if isfield(handles.data,'Label')
  colors = cat(1,handles.PlotPanel.Label.colors{:});
  markers = handles.PlotPanel.Label.markers;
  groups = handles.PlotPanel.Label.names;
  plotVarNum = handles.PlotPanel.Label.varNum;
  plotLabels = mdData.data{plotVarNum};
end

switch nViewDims
  case 1
    % 1 1d pane
    axes(hAx)
    plotDim = find(viewDims);
    sliceInd = handles.PlotPanel.axInd;
    sliceInd = num2cell(sliceInd);
    sliceInd{plotDim} = ':';
    
    plotData.xlabel = dimNames{plotDim};
    plotData.x = mdData.dimVals{plotDim};
    plotData.y = zeros(length(plotData.x),1);
    plotData.g = plotLabels(sliceInd{:});
    plotData.g = plotData.g(:)';
    plotData.clr = [];
    plotData.sym = '';
    for grp = unique(plotData.g)
      gInd = strcmp(groups, grp);
      thisClr = colors(gInd,:);
      thisSym = markers{gInd};
      plotData.clr(end+1,:) = thisClr;
      plotData.sym = [plotData.sym '+' thisSym];
    end
    plotData.sym(1) = []; %remove starting '+'
    
    % Marker Size
    set(gca,'unit', 'pixels');
    pos = get(gca,'position');
    axSize = pos(3:4);
    markerSize = min(axSize) / length(plotData.x);
    set(gca,'unit', 'normalized');
    plotData.siz = markerSize;
    
    scatter2dPlot(plotData);
    set(gca,'YTick', []);
  case 2
    % 1 2d pane
    axes(hAx)
  case 3
    % 3 2d panes + 1 3d pane = 4 subplots
  case 4
    % 6 2d panes + 4 3d pane = 10 subplots
  case 5
    % 10 2d panes + 10 3d pane = 20 subplots
  case 6
    % 15 2d panes = 15 subplots
  case 7
    % 21 2d panes = 21 subplots
  case 8
    % 28 2d panes = 28 subplots
end

% hFig.hide_empty_axes;

if nargout > 0
  varargout{1} = handles;
end

%% Sub functions
  function scatter2dPlot(plotData)
    gscatter(plotData.x,plotData.y,categorical(plotData.g),plotData.clr,plotData.sym,plotData.siz,'off',plotData.xlabel)
    uG = unique(plotData.g);
    [lH,icons] = legend(uG); % TODO: hide legend before making changes
    
    % Increase legend width
%     lPos = lH.Position;
%     lPos(3) = lPos(3) * 1.05; % increase width of legend
%     lH.Position = lPos;
    
    [icons(1:length(uG)).FontSize] = deal(lFontSize);
    [icons(1:length(uG)).FontUnits] = deal('normalized');

    shrinkText2Fit(icons(1:length(uG)))
    
    [icons(length(uG)+2:2:end).MarkerSize] = deal(lMarkerSize);
  end

  function scatter3dPlot()
    %     [uniqueGroups, uga, ugc] = unique(group);
    %     colors = colormap;
    %     markersize = 20;
    %     scatter3(x(:), y(:), z(:), markersize, colors(ugc,:));
  end

  function shrinkText2Fit(txtH)
    for iTxt=1:length(txtH)
      % Check width
      ex = txtH(iTxt).Extent;
      bigBool = ( (ex(1) + ex(3)) > 1 );
      while bigBool
        txtH(iTxt).FontSize = txtH(iTxt).FontSize * 0.99;
        ex = txtH(iTxt).Extent;
        bigBool = ( (ex(1) + ex(3)) > 1 );
      end
    end
  end

end