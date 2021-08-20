function field = centering(field,center,center_ref)
FillValues = -10;
data = field.data;
data(isnan(data)) = FillValues;
data_translate = imtranslate(data,...
    [round(center_ref(2)-center(2)), round(center_ref(1)-center(1))],...
    'FillValues',FillValues);
data_translate(data_translate==FillValues) = NaN;
field.data = data_translate;
end