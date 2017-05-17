function gvLegendPanel(hObject, eventdata, handles)

if ~isValidFigHandle(handles.LegendPanel.handle)
  handles = createLegendPanel(handles);
  
  mdData = handles.mdData;
  
  colors = cat(1,handles.PlotPanel.Label.colors{:});
  markers = handles.PlotPanel.Label.markers;
  groups = handles.PlotPanel.Label.names;
  nGroups = length(groups);
  
  itemSize = 16;
  
  %Make Legend
  hold on
  h = zeros(nGroups, 1);
  for iG = 1:nGroups
%     h(iG) = plot(nan,nan,'Color',colors(iG,:),'Marker',markers{iG});
    h(iG) = scatter(nan,nan,itemSize,colors(iG,:),markers{iG});
  end
  
  [leg,labelhandles] = legend(h, groups, 'Position',[0 0 1 1], 'Box','off', 'FontSize',20, 'Location','West');
  objs = findobj(labelhandles,'type','Patch');
  [objs.MarkerSize] = deal(itemSize);
  objs = findobj(labelhandles,'type','Text');
  [objs.FontSize] = deal(itemSize);

  % Update handles structure
  guidata(hObject, handles);
end


  function handles = createLegendPanel(handles)
    mainPanelPos = handles.output.Position;
    ht = 30 * length(handles.PlotPanel.Label.names);
    hFig = figure('Name','Legend Panel','NumberTitle','off','menubar','none',...
      'Position',[mainPanelPos(1),max(mainPanelPos(2)-ht-50, 0),250,ht]);
    
    axes(hFig, 'Position', [0 0 1 1], 'XTickLabels',[], 'YTickLabels',[],...
      'XTick',[], 'YTick',[]);
    handles.LegendPanel.handle = hFig;
  end

end