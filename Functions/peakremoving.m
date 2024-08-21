function [r,c,neighbor8] = peakremoving(data_in,step)
n = size(data_in,1);
m = size(data_in,2);
r = [];c=[];

dataTmp = nan(n+2,m+2);
dataTmp(2:end-1,2:end-1) = data_in;
neighbor8 = data_in;
for x = 1:n
    for y = 1:m
        tmp = [dataTmp(x,y),dataTmp(x,y+1),dataTmp(x,y+2),dataTmp(x+1,y+2),...
            dataTmp(x+2,y+2),dataTmp(x+2,y+1),dataTmp(x+2,y),dataTmp(x+1,y)];
        neighbor8(x,y) = 1/sum(~isnan(tmp))*sum([dataTmp(x,y),dataTmp(x,y+1),dataTmp(x,y+2),dataTmp(x+1,y+2),...
            dataTmp(x+2,y+2),dataTmp(x+2,y+1),dataTmp(x+2,y),dataTmp(x+1,y)],'omitnan');
    end
end
[M,loc] = max(data_in(:)-neighbor8(:));
if M >= step
    [r,c] = ind2sub(size(data_in),loc);
end
end
