function indexName = gvDataIndexName(mddObj)
% gvDataIndexName - get data index name from mdd object

axesType = gvGetAxisType(mddObj);

if ~isempty(axesType)
  % check for axisType = 'dataType'
  dataTypeAxInd = find(strcmp(axesType, 'dataType'), 1);
  
  if ~isempty(dataTypeAxInd)
    dataTypeAx = mddObj.axis(dataTypeAxInd);
    
    indexAxInd = find(strcmp(dataTypeAx.axismeta.dataType, 'index'),1);
    
    if ~isempty(indexAxInd)
      indexName = dataTypeAx.values{indexAxInd};
    end
  end
end

if ~exist('indexName', 'var')
  indexName = [];
end

end