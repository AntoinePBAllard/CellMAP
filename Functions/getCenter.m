function [r,c] = getCenter(data)
[row, col] = find(~isnan(data));
r = mean(row);
c = mean(col);
end