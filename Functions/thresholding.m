function [field,cond] = thresholding(field,cond)
if length(cond) == 2
    data = field.data;
    cond = data < cond(1) | data > cond(2);
else
    field.data(cond) = NaN;
end
end