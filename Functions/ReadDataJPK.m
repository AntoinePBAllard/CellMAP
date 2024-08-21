function Data = ReadDataJPK(folder)

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

strToFind ={'force-scan-series.header.force-settings.segment.','.num-points'};
fun = @(s)contains(header_metadata_split(:,1),s);
out = cellfun(fun,strToFind,'UniformOutput',false);
num_points_location = all(horzcat(out{:}),2);
num_points = header_metadata_split(num_points_location,2);
num_points = str2double(num_points);
num_points(num_points==0)=[];
segment_header_location = fullfile(InfoDir(1).folder,'segments');

for k = 0:(length(num_points)-1)
    fid=fopen(fullfile(segment_header_location,num2str(k),'segment-header.properties'));
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


    if k == 0
        channelName_location = strcmp(segment_header_metadata_split(:,1),'channels.list')==1;
        channelName = segment_header_metadata_split(channelName_location,2);
        channelName = strsplit(channelName{1},' ');
        indx = listdlg('ListString',channelName);
        for i = indx
            Data.(channelName{i}) = NaN(length(num_points),num_points(1));
        end
    end

        for channel_name = channelName(indx)
            lcd_info_location = strcmp(segment_header_metadata_split(:,1),strcat('channel.',channel_name{:},'.lcd-info.*'))==1;
            lcd_info = segment_header_metadata_split(lcd_info_location,2);

            offset_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.offset'))==1;
            if isempty(str2double(header_shared_data_metadata_split(offset_location,2)))
                data.(['segment' num2str(k)]).(channel_name{:}).offset = 0;
            else
                data.(['segment' num2str(k)]).(channel_name{:}).offset = str2double(header_shared_data_metadata_split(offset_location,2));
            end
            multiplier_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.multiplier'))==1;
            if isempty(str2double(header_shared_data_metadata_split(multiplier_location,2)))
                data.(['segment' num2str(k)]).(channel_name{:}).multiplier = 1;
            else
                data.(['segment' num2str(k)]).(channel_name{:}).multiplier = str2double(header_shared_data_metadata_split(multiplier_location,2));
            end

            conversion_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversions.default'))==1;
            conversionName = header_shared_data_metadata_split(conversion_location,2);

            for conversion_name = conversionName
                base_calibration_slot_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversion.',conversion_name{:},'.base-calibration-slot'))==1;
                base_calibration_slot = header_shared_data_metadata_split(base_calibration_slot_location,2);
                offset_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversion.',conversion_name{:},'.scaling.offset'))==1;
                offset = str2double(header_shared_data_metadata_split(offset_location,2));
                multiplier_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversion.',conversion_name{:},'.scaling.multiplier'))==1;
                multiplier = str2double(header_shared_data_metadata_split(multiplier_location,2));
                while ~isempty(find(strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversion.',base_calibration_slot{:},'.base-calibration-slot'))==1, 1))
                    offset_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversion.',base_calibration_slot{:},'.scaling.offset'))==1;
                    base_offset = str2double(header_shared_data_metadata_split(offset_location,2));
                    multiplier_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversion.',base_calibration_slot{:},'.scaling.multiplier'))==1;
                    base_multiplier = str2double(header_shared_data_metadata_split(multiplier_location,2));
                    multiplier = base_multiplier*multiplier;
                    offset = base_offset + offset/base_multiplier;
                    base_calibration_slot_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversion.',base_calibration_slot{:},'.base-calibration-slot'))==1;
                    base_calibration_slot = header_shared_data_metadata_split(base_calibration_slot_location,2);
                end
                data.(['segment' num2str(k)]).(channel_name{:}).(conversion_name{:}).multiplier = multiplier;
                data.(['segment' num2str(k)]).(channel_name{:}).(conversion_name{:}).offset = offset;

                data.(['segment' num2str(k)]).(channel_name{:}).(conversion_name{:}).data = nan(num_points(k+1),1);

                channel_file = fullfile(InfoDir(1).folder,'segments',num2str(k),'channels',[channel_name{:} '.dat']);
                fid=fopen(channel_file);
                type_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.type')) == 1;
                type = header_shared_data_metadata_split(type_location,2);
                if strcmp(type{1},'integer-data')
                    flag_temp=fread(fid,'integer*4','ieee-be');
                elseif strcmp(type{1},'float-data')
                    flag_temp=fread(fid,'float','ieee-be');
                end
                fclose(fid);
                multiplier = data.(['segment' num2str(k)]).(channel_name{:}).multiplier;
                offset = data.(['segment' num2str(k)]).(channel_name{:}).offset;
                flag_temp = flag_temp*multiplier+offset;
                multiplier = data.(['segment' num2str(k)]).(channel_name{:}).(conversion_name{:}).multiplier;
                offset = data.(['segment' num2str(k)]).(channel_name{:}).(conversion_name{:}).offset;
                data.(['segment' num2str(k)]).(channel_name{:}).(conversion_name{:}).data = (flag_temp+offset)*multiplier;
                data_tmp = data.(['segment' num2str(k)]).(channel_name{:}).(conversion_name{:}).data;
                Data.(channel_name{:})(k+1,1:length(data_tmp)) = data_tmp;
            end
        end

    end

end