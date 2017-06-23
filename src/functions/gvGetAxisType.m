function dataAxesType = gvGetAxisType(mddObj)
% gvGetAxisType - get axis type from axismeta of mdd object

dataAxes = mddObj.axis;

dataAxesMeta = {dataAxes.axismeta};

dataAxesType = cellfunu(@getAxisType, dataAxesMeta);
  
  function axisType = getAxisType(s)
    if isfield(s, 'axisType')
      axisType = s.axisType;
    else
      axisType = [];
    end
  end

end