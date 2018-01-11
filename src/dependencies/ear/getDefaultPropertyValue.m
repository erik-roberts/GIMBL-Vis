function value = getDefaultPropertyValue(class, propertyName)
% Author: Erik Roberts

if isobject(class)
  metaObj = metaclass(class);
else
  metaObj = metaclass(feval(class));
end

value = metaObj.PropertyList(strcmp(propertyName, {metaObj.PropertyList.Name})).DefaultValue;

end
