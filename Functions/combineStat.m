function field = combineStat(field,CellNames)
field.Volume=[];field.SurfaceProjected=[];field.TopArea=[];
field.VolumePixel2=[];field.SurfaceProjectedPixel2=[];field.TopAreaPixel2=[];
field.HistoMin=[];field.HistoMax=[];field.HistoGeomean=[];field.HistoMean=[];
field.HistoMedian=[];field.HistoStd=[];field.HistoSem=[];field.HistoGeostd=[];
for CellName = CellNames
    if iscell(CellName)
        CellName = cell2mat(CellName);
    end
    field.Volume = [field.Volume field.(CellName).Volume];
    field.SurfaceProjected = [field.SurfaceProjected field.(CellName).SurfaceProjected];
    field.TopArea = [field.TopArea field.(CellName).TopArea];
    field.VolumePixel2 = [field.VolumePixel2 field.(CellName).VolumePixel2];
    field.SurfaceProjectedPixel2 = [field.SurfaceProjectedPixel2 field.(CellName).SurfaceProjectedPixel2];
    field.TopAreaPixel2 = [field.TopAreaPixel2 field.(CellName).TopAreaPixel2];
    field.HistoMin = [field.HistoMin field.(CellName).HistoMin];
    field.HistoMax = [field.HistoMax field.(CellName).HistoMax];
    field.HistoGeomean = [field.HistoGeomean field.(CellName).HistoGeomean];
    field.HistoMean = [field.HistoMean field.(CellName).HistoMean];
    field.HistoStd = [field.HistoStd field.(CellName).HistoStd];
    field.HistoMedian = [field.HistoMedian field.(CellName).HistoMedian];
    field.HistoSem = [field.HistoSem field.(CellName).HistoSem];
    field.HistoGeostd = [field.HistoGeostd field.(CellName).HistoGeostd];
end

                    