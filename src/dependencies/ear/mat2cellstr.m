function out = mat2cellstr(mat)
% mat2cellstr - convert matrix into cell array of strings

out = cellfunu(@num2str, num2cell(mat));

end
