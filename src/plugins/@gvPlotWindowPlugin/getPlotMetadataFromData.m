function getPlotMetadataFromData(pluginObj, hypercubeObj)
% getPlotMetadataFromData - get plotting and legend metadata from data and
%                           metadata fields

% TODO: permit function applied to non-numeric data to get labels (eg
% isnonempty)

axesType = gvGetAxisType(hypercubeObj);

if ~isempty(axesType)
  % check for axisType = 'dataType'
  dataTypeAxInd = find(strcmp(axesType, 'dataType'), 1);
end

if ~isempty(axesType) && ~isempty(dataTypeAxInd) % then exists dataType axis
  
  % check for categorical data type in dataTypeAx
  if any(strcmp(hypercubeObj.axis(dataTypeAxInd).axismeta.dataType, 'categorical'))
    % non numeric data so leave as cell array
    hypercubeObj.meta.onlyNumericDataBool = false;
    
    numLogical = cellfun(@isscalar, hypercubeObj.data);
  else % no categorical data
    if iscellscalar(hypercubeObj.data)
      % numeric with full lattice so convert cell to mat
      hypercubeObj.data = cell2mat(hypercubeObj.data);
      
      hypercubeObj.meta.onlyNumericDataBool = true;
      
      numLogical = [];
    else
      % numeric but sparse with empty cells
      hypercubeObj.meta.onlyNumericDataBool = false;
      
      numLogical = cellfun(@isscalar, hypercubeObj.data);
    end
  end
  
  nDims = ndims(hypercubeObj.data);
  
  % loop through the dataType axis' values
  for axValInd = 1:length(hypercubeObj.axis(dataTypeAxInd).values)
    thisSliceDataType = hypercubeObj.axis(dataTypeAxInd).axismeta.dataType{axValInd};
    
    if strcmp(thisSliceDataType, 'categorical')
      % get data slice
      thisSliceInds = cell(1, nDims);
      thisSliceInds{dataTypeAxInd} = axValInd;
      [thisSliceInds{setxor(dataTypeAxInd, 1:nDims)}] = deal(':');
      thisSlice = hypercubeObj.data(thisSliceInds{:});
      
      processCategoricalData(hypercubeObj, thisSlice, axValInd);
      
    end
  end
  
else
  
  if isnumeric(hypercubeObj.data)
    hypercubeObj.meta.onlyNumericDataBool = true;
  elseif iscellscalar(hypercubeObj.data)
    hypercubeObj.meta.onlyNumericDataBool = true;
    
    hypercubeObj.data = cell2mat(hypercubeObj.data);
  else
    hypercubeObj.meta.onlyNumericDataBool = false;
    
    numLogical = cellfun(@isscalar, hypercubeObj.data);
    
    strLogical = cellfun(@ischar, hypercubeObj.data);
    if any(strLogical(:))
      processCategoricalData(hypercubeObj, hypercubeObj.data(strLogical));
    end
  end
  
end

% get numeric data limits
if hypercubeObj.meta.onlyNumericDataBool
  dataMin = nanmin(hypercubeObj.data(:));
  dataMax = nanmax(hypercubeObj.data(:));
else
  numData = cell2mat(hypercubeObj.data(numLogical));
  
  dataMin = nanmin(numData(:));
  dataMax = nanmax(numData(:));
end
hypercubeObj.meta.numericLimits = [dataMin dataMax];


%% Nested Fn
  function processCategoricalData(hypercubeObj, dataSlice, structInd)
    if nargin < 2
      dataSlice = hypercubeObj.data;
    end
    if nargin < 3
      structInd = 1;
    end
    
    if exist('dataTypeAxInd','var') && isfield(hypercubeObj.axis(dataTypeAxInd).axismeta, 'plotInfo')
      plotInfoBool = length(hypercubeObj.axis(dataTypeAxInd).axismeta.plotInfo) >= axValInd;
      thisSlicePlotInfo = hypercubeObj.axis(dataTypeAxInd).axismeta.plotInfo{axValInd};
    else
      plotInfoBool = false;
    end
    
    if plotInfoBool && isfield(thisSlicePlotInfo,'labels')
      groups = thisSlicePlotInfo.labels;
    else
      groups = unique(dataSlice);
      groups(cellfun(@isempty,groups)) = [];
      clear thisDataTypeSlice
      
      % store for future plots
%       hypercubeObj.axis(dataTypeAxInd).axismeta.plotInfo{axValInd}.groups = groups;
    end
    nGroups = length(groups);
    
    if plotInfoBool && isfield(thisSlicePlotInfo,'colors')
      colors = thisSlicePlotInfo.colors;
    else
      colors = distinguishable_colors(nGroups);
      
      % store for future plots
%       hypercubeObj.axis(dataTypeAxInd).axismeta.plotInfo{axValInd}.colors = colors;
    end
    
    if plotInfoBool && isfield(thisSlicePlotInfo,'markers')
      markers = thisSlicePlotInfo.markers;
    else
      markers = cell(nGroups,1);
      [markers{:}] = deal('.');
      
      % store for future plots
%       hypercubeObj.axis(dataTypeAxInd).axismeta.plotInfo{axValInd}.markers = markers;
    end
    
    % Store legend data
    hypercubeObj.meta.legend(structInd).groups = groups;
    hypercubeObj.meta.legend(structInd).colors = colors;
    hypercubeObj.meta.legend(structInd).markers = markers;
  end

end