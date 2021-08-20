function [neighbor8,k] = holeremoving(data_in)
n = size(data_in,1);
m = size(data_in,2);

dataTmp = nan(n+2,m+2);
dataTmp(2:end-1,2:end-1) = data_in;
neighbor8 = data_in;
k = 0;
for x = 1:n
    for y = 1:m
        if isnan(data_in(x,y))
            tmp = [dataTmp(x,y),dataTmp(x,y+1),dataTmp(x,y+2),dataTmp(x+1,y+2),...
                dataTmp(x+2,y+2),dataTmp(x+2,y+1),dataTmp(x+2,y),dataTmp(x+1,y)];
            if sum(isnan(tmp)) < 4
                k = k + 1;
                neighbor8(x,y) = 1/sum(~isnan(tmp))*nansum([dataTmp(x,y),dataTmp(x,y+1),dataTmp(x,y+2),dataTmp(x+1,y+2),...
                    dataTmp(x+2,y+2),dataTmp(x+2,y+1),dataTmp(x+2,y),dataTmp(x+1,y)]);
            end
        end
    end
end
end
