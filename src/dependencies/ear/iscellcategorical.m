function OUT = iscellcategorical(IN)
% iscellcategorical(S) returns 1 if IN is a cell array of categoricals and 0 otherwise.
    
    if iscell(IN)
        OUT = all(cellfun(@iscategorical,IN(:)));
    else
        OUT = false;
    end

end