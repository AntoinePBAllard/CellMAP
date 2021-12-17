function [field,cond] = cleaning(field,cond)
if length(cond) == 1
    data = field.data;
    data(isnan(data)) = 0;
    cond = ~bwareaopen(data,cond,8);
else
    field.data(cond) = NaN;
end
end