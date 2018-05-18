function gvObj = gvImportDsPower
%% gvImportDsPower
% Purpose: This function imports power data from a DynaSim simulation to a gv
% hypercube, enabling each simulation point to hold the vector data of
% frequencies, instead of just a scalar, for each simulation. Importantly, one
% should keep the power data in a separate folder, so it is not imported with
% the rest of the data initially. After creation of the gvArrayData.mat object,
% one can run GV using the normal commands (i.e., gvr, gvRun, gv.Run).
%
% Implementation:
%   1) Add a new axis to the gvArray hypercube for the vector data, in this case  
%      the frequencies for the fft power.
%   2) Import the power data and store in a separate gvArray hypercube.
%   3) Merge the gvArray hypercube objects
%
% Author: Erik Roberts, 2018

%% ---- Edit ----
powerFnName = @gvCalcPower; % the function used to calculate the power
powerResultsPath = fullfile(pwd, 'power_results'); % the path to the directory storing the power results
maxFreq = 100; % hz
%% --------------

% make gv object
gvObj = gv();

% import ds data
gvObj.importDsData(pwd, 'saveBool', 0);

% grab the axis metadata which would be discarded
axismeta = gvObj.model.data.dsData.axis(1).axismeta;

%% power data
% import ds power data separately
powerResults = dsImportResults(powerResultsPath, 'import_scope','custom', 'func',powerFnName, 'as_cell',1);

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
gvObj.model.data.dsData.axis(end+1) = gvArrayAxis;

% add axis info
gvObj.model.data.dsData.axis(end).name = 'freq';
gvObj.model.data.dsData.axis(end).values = freqs(1);

%% sim IDS
analysisFnAxInd = contains(gvObj.model.data.dsData.axisNames, 'analysisFn');
simIDind = contains(gvObj.model.data.dsData.axis(1).values, 'simID');
simIDs = sliceAnyDim(gvObj.model.data.dsData.data, simIDind, analysisFnAxInd);

simIDs = cell2mat(simIDs);

simIDsSize = size(simIDs);
simIDsSize(end+1) = nFreqs; % for later reshape

simIDs = simIDs(:); % reshape to col vector

%% get axis names and vals
axis_names = gvObj.model.data.dsData.exportAxisNames;
axis_vals = gvObj.model.data.dsData.exportAxisVals;
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
gvObj.model.data.dsData.merge(tempObj);

%% add axis metadata
% this was dropped in merge

axismeta.dataType{end+1} = 'numeric';
gvObj.model.data.dsData.axis(1).axismeta = axismeta;

%% save gvArrayData
dynasimData = gvObj.model.data.dsData;
filePath = fullfile(pwd, 'gvArrayData.mat');
save(filePath, 'dynasimData') % save gvArray obj


%% Nested Fn
  function cellOut = removeFreqCol(cellIn)
    % just take first sxx col, discarding second freq col
    cellOut = cellIn(:,1);
  end

  function cellOut = trim2maxFreq(cellIn)
    % remove freqs above maxFreq
    selectedFreqs = cellIn(:,2) <= maxFreq;
    
    cellOut = cellIn(selectedFreqs,:);
  end

end