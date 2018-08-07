function importDsPower(modelObj, varargin)
%% importDsPower
% Purpose: This function imports power data from a DynaSim simulation to a gv
% hypercube, enabling each simulation point to hold the vector data of
% frequencies, instead of just a scalar, for each simulation.
%
% Implementation:
%   1) Add a new axis to the gvArray hypercube for the vector data, in this case  
%      the frequencies for the fft power.
%   2) Import the power data and store in a separate gvArray hypercube.
%   3) Merge the gvArray hypercube objects
%
% Author: Erik Roberts, 2018

%% Check Options
options = checkOptions(varargin,{...
  'powerFn', @gvCalcPower, [],... % the function used to calculate the power
  'powerResultsPath', fullfile(modelObj.app.workingDir, 'results'), [],... % the path to the directory storing the power results
  'maxFreq', 100, [],... % hz, max freq to plot
},false);

modelObj.vprintf('[gvModel] Importing power results...\n')

% grab the axis metadata which would be discarded
axismeta = modelObj.data.dsData.axis(1).axismeta;

dsDataSize = modelObj.data.dsData.size;
dsDataNdims = modelObj.data.dsData.ndims;

%% power data
% import ds power data separately
powerResults = dsImportResults(options.powerResultsPath, 'import_scope','custom', 'func',options.powerFn, 'as_cell',1);

% trim to maxFreq
powerResults = cellfun(@trim2maxFreq, powerResults, 'uni',0);

nFreqs = length(powerResults{1});
freqs = powerResults{1}(:,2);

% remove freqs
powerResults = cellfun(@removeFreqCol, powerResults, 'uni',0);

% take log power
powerResults = cellfun(@log, powerResults, 'uni',0);

%% power freq axis
% Add freq axis to original ds data in gv hypercube. All the scalar simulation
% data will be stored in the first value of the frequency axis. The rest of the
% frequencies will be empty for other data types besides power.

% add new axes for power
modelObj.data.dsData.axis(end+1) = gvArrayAxis;

% add axis info
modelObj.data.dsData.axis(end).name = 'freq';
modelObj.data.dsData.axis(end).values = freqs(1);

%% sim IDS
analysisFnAxInd = contains(modelObj.data.dsData.axisNames, 'analysisFn');
simIDind = contains(modelObj.data.dsData.axis(1).values, 'simID');
simIDs = sliceAnyDim(modelObj.data.dsData.data, simIDind, analysisFnAxInd);

simIDs = cell2mat(simIDs);

simIDsSize = size(simIDs);
if length(simIDsSize) < dsDataNdims
  simIDsSize(end+1:dsDataNdims) = dsDataSize(length(simIDsSize)+1:end);
end

simIDsSize(end+1) = nFreqs; % for later reshape

simIDs = simIDs(:); % reshape to col vector

%% get axis names and vals
axis_names = modelObj.data.dsData.exportAxisNames;
axis_vals = modelObj.data.dsData.exportAxisVals;
axis_vals{1} = {'power'};
axis_vals{end} = freqs;

%% make new data of correct dims
data = zeros(length(simIDs), nFreqs); % col vector

nSims = length(powerResults);
for simID = 1:nSims
  if ~isempty(powerResults{simID})
    data(simIDs == simID, :) = powerResults{simID};
  else
    data(simIDs == simID, :) = nan;
  end
end

% reshape the data
data = reshape(data, simIDsSize);

%% add data to new gvArray obj
tempObj = gvArray;
tempObj = tempObj.importData(data, axis_vals, axis_names);

%% merge objects
modelObj.data.dsData.merge(tempObj);

%% add axis metadata
% this was dropped in merge

axismeta.dataType{end+1} = 'numeric';
modelObj.data.dsData.axis(1).axismeta = axismeta;


%% Nested Fn
  function cellOut = removeFreqCol(cellIn)
    % just take first sxx col, discarding second freq col
    cellOut = cellIn(:,1);
  end

  function cellOut = trim2maxFreq(cellIn)
    % remove freqs above maxFreq
    selectedFreqs = cellIn(:,2) <= options.maxFreq;
    
    cellOut = cellIn(selectedFreqs,:);
  end

end