%% params
eqns='IB';
vary={
  'IB','Iapp',1:2;
  'IB','gNa',1:2;
  };

study_dir = fullfile(pwd, 'gvDsPowerExample');

%% simulate
dsSimulate(eqns, 'time_limits',[0 250], 'vary',vary, 'study_dir',study_dir, 'analysis_functions',{@gvCalcPower});

%% move to power_results
resultsDir = fullfile(study_dir, 'results');

powerResultsDir = fullfile(study_dir, 'power_results');
mkdir(powerResultsDir);

powerResultFiles = lscell(fullfile(resultsDir, '*_gvCalcPower.mat'));

for thisFile = powerResultFiles(:)'
  src = fullfile(resultsDir, thisFile{1});
  dest = fullfile(powerResultsDir, thisFile{1});
  
  movefile(src, dest);
end

%% run ds
cd(study_dir);
gvImportDsPower();