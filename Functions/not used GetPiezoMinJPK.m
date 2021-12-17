function indent = GetPiezoMinJPK(folder)
InfoDir=dir(folder);
index_header=find(strcmp({InfoDir.name},'header.properties')==1);
index_shared_data=find(strcmp({InfoDir.name},'shared-data')==1);

header_location=fullfile(InfoDir(index_header).folder,InfoDir(index_header).name);
header_shared_data_location=fullfile(InfoDir(index_shared_data).folder,InfoDir(index_shared_data).name,'header.properties');

fid=fopen(header_shared_data_location);
format = repmat('%s',1,100);
header_shared_data_metadata_raw=textscan(fid,format,'whitespace','','delimiter','');
header_shared_data_metadata_raw=header_shared_data_metadata_raw{1,1};
fclose(fid);
j=1;
for i=1:size(header_shared_data_metadata_raw,1)
    temp=strsplit(header_shared_data_metadata_raw{i,1},'=');
    if(size(temp,2)==2)
        header_shared_data_metadata_split{j,1}=temp{1,1};
        header_shared_data_metadata_split{j,2}=temp{1,2};
        j = j+1;
    end
end
fid=fopen(header_location);
header_metadata_raw=textscan(fid,format,'whitespace','','delimiter','');
header_metadata_raw=header_metadata_raw{1,1};
fclose(fid);
j=1;
for i=1:size(header_metadata_raw,1)
    temp=strsplit(header_metadata_raw{i,1},'=');
    if(size(temp,2)==2)
        header_metadata_split{j,1}=temp{1,1};
        header_metadata_split{j,2}=temp{1,2};
        j = j+1;
    end
end

ilength_location = strcmp(header_metadata_split(:,1),'quantitative-imaging-map.position-pattern.grid.ilength')==1;
ilength = str2double(header_metadata_split(ilength_location,2));

strToFind ={'quantitative-imaging-map.settings.force-settings.','.num-points'};
fun = @(s)contains(header_metadata_split(:,1),s);
out = cellfun(fun,strToFind,'UniformOutput',false);
num_points_location = all(horzcat(out{:}),2);
num_points = header_metadata_split(num_points_location,2);

segment_header_location = fullfile(InfoDir(1).folder,'index','0','segments');
for segment_style = {'extend'}
    fid=fopen(fullfile(segment_header_location,'0','segment-header.properties'));
    segment_header_metadata_raw = textscan(fid,format,'whitespace','','delimiter','');
    segment_header_metadata_raw=segment_header_metadata_raw{1,1};
    fclose(fid);

    j=1;
    for i=1:size(segment_header_metadata_raw,1)
        temp=strsplit(segment_header_metadata_raw{i,1},'=');
        if(size(temp,2)==2)
            segment_header_metadata_split{j,1}=temp{1,1};
            segment_header_metadata_split{j,2}=temp{1,2};
            j = j+1;
        end
    end

    for channel_name = {'measuredHeight'}
        lcd_info_location = strcmp(segment_header_metadata_split(:,1),strcat('channel.',channel_name{:},'.lcd-info.*'))==1;
        lcd_info = segment_header_metadata_split(lcd_info_location,2);

        offset_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.offset'))==1;
        data.(segment_style{:}).(channel_name{:}).offset = str2double(header_shared_data_metadata_split(offset_location,2));
        multiplier_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.multiplier'))==1;
        data.(segment_style{:}).(channel_name{:}).multiplier = str2double(header_shared_data_metadata_split(multiplier_location,2));

        for conversion_name = {'nominal'}
            offset_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversion.',conversion_name{:},'.scaling.offset'))==1;
            offset = str2double(header_shared_data_metadata_split(offset_location,2));
            multiplier_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversion.',conversion_name{:},'.scaling.multiplier'))==1;
            multiplier = str2double(header_shared_data_metadata_split(multiplier_location,2));
            data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).multiplier = multiplier;
            data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).offset = offset;

            indent = NaN(ilength,ilength);
            for x = 1:ilength
                for y = 1:ilength
                    row = ilength-y+1;
                    col = x;
                    data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).data = nan(str2double(num_points{1}));
                    index = (row-1)*ilength+col-1;
                    channel_file = fullfile(InfoDir(1).folder,'index',num2str(index),'segments','0','channels',[channel_name{:} '.dat']);
                    fid=fopen(channel_file);
                    fseek(fid,0,'eof');
                    flag_temp = [];
                    i = 0;
                    while isempty(flag_temp)
                        i = i-1;
                        fseek(fid,i,'cof');
                        flag_temp=fread(fid,1,'integer*4','ieee-be');
                    end
                    fclose(fid);
                    multiplier = data.(segment_style{:}).(channel_name{:}).multiplier;
                    offset = data.(segment_style{:}).(channel_name{:}).offset;
                    flag_temp = flag_temp*multiplier+offset;
                    multiplier = data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).multiplier;
                    offset = data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).offset;
                    data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).data = (flag_temp+offset)*multiplier;
                    indent(row,col) = data.extend.measuredHeight.nominal.data(end);
                end
            end
            
        end
    end
end
end