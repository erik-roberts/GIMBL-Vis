%% gvLegendWindow - UI Legend Window Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMB-Vis legend window

% classdef gvLegendWindow < handle
%   
%   methods
%     
%     function obj = gvLegendWindow()
%       
%     end
    
    
    function openLegendWindow(pluginObj)
      
      mainWindowExistBool = pluginObj.view.checkMainWindowExists;
      
      if mainWindowExistBool && pluginObj.checkWindowExists()
        
        hypercubeObj = pluginObj.controller.activeHypercube;
        
        if length(hypercubeObj.meta.legend) > 1
          axesType = gvGetAxisType(hypercubeObj);
          dataTypeAxInd = find(strcmp(axesType, 'dataType'), 1);
          
          sliderVals = pluginObj.view.dynamic.sliderVals;
          legendInfo = hypercubeObj.meta.legend(sliderVals(dataTypeAxInd));
        else
          legendInfo = hypercubeObj.meta.legend(1);
        end
        
        colors = legendInfo.colors;
        markers = legendInfo.markers;
        groups = legendInfo.groups;
        nGroups = length(groups);
        
        fontSize = pluginObj.fontSize;
        fontHeight = pluginObj.fontHeight;
        markerSize = fontHeight*2;
        
        makeCategoricalLegendWindow(pluginObj);
        
        %Make Legend
        hold on
        h = zeros(nGroups, 1);
        for iG = 1:nGroups
          %     h(iG) = plot(nan,nan,'Color',colors(iG,:),'Marker',markers{iG});
          h(iG) = scatter(nan,nan,markerSize,colors(iG,:),markers{iG});
        end
        
        [leg,labelhandles] = legend(h, groups, 'Position',[0 0 1 1], 'Box','off', 'FontSize',fontSize, 'Location','West');
        objs = findobj(labelhandles,'type','Patch');
        [objs.MarkerSize] = deal(markerSize);
        objs = findobj(labelhandles,'type','Text');
        [objs.FontSize] = deal(fontSize);
      end
      
      %% Nested Functions
      function makeCategoricalLegendWindow(pluginObj)
        mainWindowPos = pluginObj.view.main.handles.fig.Position;
        ht = fontHeight*1.1 * nGroups;
        wd = fontHeight*max(cellfun(@length,groups))/2*1.1 + markerSize; % TODO improve auto width
        legendWindowHandle = figure('Name','GIMBL-Vis: Legend Window','NumberTitle','off','menubar','none',...
          'Position',[mainWindowPos(1),max(mainWindowPos(2)-ht-50, 0),wd,ht]);
        
        axes(legendWindowHandle, 'Position', [0 0 1 1], 'XTickLabels',[], 'YTickLabels',[],...
          'XTick',[], 'YTick',[]);
        
        % set legend handle
        pluginObj.handles.legendWindow = legendWindowHandle;
      end
      
    end
    
%   end
%   
% end
