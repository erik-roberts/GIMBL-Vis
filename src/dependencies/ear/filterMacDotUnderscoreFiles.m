function fileList = filterMacDotUnderscoreFiles(fileList)
%% filterMacDotUnderscoreFiles
% purpose: remove the ._* files found in later mac versions from a file list
%
% input/output: fileList cell array of characters

% cases to exclude:
% 1) ._*
% 2) */._*
%
% on windows:
% 3) driveLetter:\._*

% case 1)
fileList = fileList( ~startsWith(fileList, '._') );

% case 2)
fileList = fileList( ~contains(fileList, [filesep '._']) );

% case 3)
if ispc
    fileList = fileList( ~contains(fileList, [':' filesep '._']) );
end

end

