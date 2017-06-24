function strOut = shebangParse(strIn)
% shebangParse - if string input starts with shebang '#!', then eval it

if length(strIn) > 2 && strcmp(strIn(1:2), '#!')
  strOut = evalin('caller', strIn(3:end));
else
  strOut = strIn;
end

end