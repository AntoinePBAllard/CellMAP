% This function calculate the different parameters regarding the volume,
% surfaces and histogram
% INPUT:
% field to update
% data
% pixel for conversion

function field = calcStat(field,data)
n = size(data,1);
m = size(data,2);
H = data;
H(isnan(H)) = 0;
pixel = field.pixel;
field.Volume = sum(H(:))*pixel^2;
field.SurfaceProjected = sum(~isnan(data(:)))*pixel^2;
field.TopArea = surfarea((1:m)*pixel,(1:n)*pixel,H)-(sum(isnan(data(:)))-n-m)*pixel^2;
field.VolumePixel2 = field.Volume/pixel^2;
field.SurfaceProjectedPixel2 = field.SurfaceProjected/pixel^2;
field.TopAreaPixel2 = field.TopArea/pixel^2;
field.HistoMin = min(data(:),[],'omitnan');
field.HistoMax = max(data(:),[],'omitnan');
if sum(data(:)<0) == 0
    field.HistoGeomean = geomean(data(:),1);
else
    field.HistoGeomean = NaN;
end
field.HistoMean = mean(data(:),'omitnan');
field.HistoMedian = median(data(:),'omitnan');
field.HistoStd = std(data(:),'omitnan');
n = sum(~isnan(data(:)));field.HistoSem = std(data(:),'omitnan')/sqrt(n);
field.HistoGeostd = exp(std(log(data(:)),'omitnan'));
p = [.1 .25 .5 .75 .9];
field.HistoQuantile = quantile(data(:),p);