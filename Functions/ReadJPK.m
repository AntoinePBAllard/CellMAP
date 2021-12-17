function [indent,height,force] = ReadJPK(folder)
%% This function reads all subfolder in 'folder' (unzip from jpk using UnzipJPK.m)
%% and reconstruct indentation and height maps, as well as force curve.
% This code has been adapted from someone else, written in another langage
% (python?), but to date I cannot find the source. I apologise for that,
% and I am ready to acknowledge the person if they read this message.

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

% The following is only useful for the retraction
% segment_count_location = strcmp(header_shared_data_metadata_split(:,1),'force-segment-header-infos.count')==1;
% segment_count = str2double(header_shared_data_metadata_split(segment_count_location,2));
% strToFind ={'force-segment-header-info.';'.settings.style'};
% fun = @(s)contains(header_shared_data_metadata_split(:,1),s);
% out = cellfun(fun,strToFind,'UniformOutput',false);
% segment_style_location = all(horzcat(out{:}),2);
% segment_style = header_shared_data_metadata_split(segment_style_location,2);


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
    
%     channelName_location = strcmp(segment_header_metadata_split(:,1),'channels.list')==1;
%     channelName = segment_header_metadata_split(channelName_location,2);
%     channelName = strsplit(channelName{1},' ');

    for channel_name = {'measuredHeight'}
        lcd_info_location = strcmp(segment_header_metadata_split(:,1),strcat('channel.',channel_name{:},'.lcd-info.*'))==1;
        lcd_info = segment_header_metadata_split(lcd_info_location,2);
        
        offset_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.offset'))==1;
        data.(segment_style{:}).(channel_name{:}).offset = str2double(header_shared_data_metadata_split(offset_location,2));
        multiplier_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.multiplier'))==1;
        data.(segment_style{:}).(channel_name{:}).multiplier = str2double(header_shared_data_metadata_split(multiplier_location,2));
        
%         conversion_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversions.list'))==1;
%         conversionName = header_shared_data_metadata_split(conversion_location,2);
%         conversionName = strsplit(conversionName{1},' ');
        
        for conversion_name = {'nominal'}%conversionName
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
            data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).multiplier = multiplier;
            data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).offset = offset;
            
            indent = NaN(ilength,ilength);
            height = NaN(ilength,ilength);
            for x = 1:ilength
                for y = 1:ilength
                    row = ilength-y+1;
                    col = x;
                    data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).data = nan(str2double(num_points{1}),1);
                    index = (row-1)*ilength+col-1;
                    channel_file = fullfile(InfoDir(1).folder,'index',num2str(index),'segments','0','channels',[channel_name{:} '.dat']);
                    fid=fopen(channel_file);
                    flag_temp=fread(fid,'integer*4','ieee-be');
                    fclose(fid);
                    multiplier = data.(segment_style{:}).(channel_name{:}).multiplier;
                    offset = data.(segment_style{:}).(channel_name{:}).offset;
                    flag_temp = flag_temp*multiplier+offset;
                    multiplier = data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).multiplier;
                    offset = data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).offset;
                    data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).data = (flag_temp+offset)*multiplier;
                    indent(row,col) = data.extend.measuredHeight.nominal.data(end)*1e6; % unit: µm
                    extractheight = data.extend.measuredHeight.nominal.data;
                    h = extractheight*1e6; % in [um]
                    l = length(h);
                    if l > size(height,3)
                        height(:,:,end+1:end+l-size(height,3)) = NaN;
                    end
                    height(row,col,1:l) = h;
                end
            end
        end
    end
    
    for channel_name = {'vDeflection'}
        lcd_info_location = strcmp(segment_header_metadata_split(:,1),strcat('channel.',channel_name{:},'.lcd-info.*'))==1;
        lcd_info = segment_header_metadata_split(lcd_info_location,2);
        
        offset_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.offset'))==1;
        data.(segment_style{:}).(channel_name{:}).offset = str2double(header_shared_data_metadata_split(offset_location,2));
        multiplier_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.multiplier'))==1;
        data.(segment_style{:}).(channel_name{:}).multiplier = str2double(header_shared_data_metadata_split(multiplier_location,2));
        
%         conversion_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.conversion-set.conversions.list'))==1;
%         conversionName = header_shared_data_metadata_split(conversion_location,2);
%         conversionName = strsplit(conversionName{1},' ');
        
        for conversion_name = {'force'}%conversionName
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
            data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).multiplier = multiplier;
            data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).offset = offset;
     
            force = NaN(ilength,ilength);
            for x = 1:ilength
                for y = 1:ilength
                    row = ilength-y+1;
                    col = x;
                    data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).data = nan(str2double(num_points{1}));
                    index = (row-1)*ilength+col-1;
                    channel_file = fullfile(InfoDir(1).folder,'index',num2str(index),'segments','0','channels',[channel_name{:} '.dat']);
                    fid=fopen(channel_file);
                    flag_temp=fread(fid,'integer*4','ieee-be');
                    fclose(fid);
                    multiplier = data.(segment_style{:}).(channel_name{:}).multiplier;
                    offset = data.(segment_style{:}).(channel_name{:}).offset;
                    flag_temp = flag_temp*multiplier+offset;
                    multiplier = data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).multiplier;
                    offset = data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).offset;
                    data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).data = (flag_temp+offset)*multiplier;
                    extractforce = data.extend.vDeflection.force.data;
                    temp = strsplit(folder,filesep);
                    idx = strfind(folder,filesep);
                    ProcForce = folder(1:idx(end-1)-1);
                    processed = dir(fullfile(ProcForce,strcat(temp{end},'*tsv')));
                    fid= fopen(fullfile(processed(end).folder,processed(end).name));
                    Data_ProcessedTitle = textscan(fid,'%s',13,'delimiter','\t'); % NEEDS TO BE OPEN ONCE!
                        Data_Processed = textscan(fid,'%s %d8 %u %u %f64 %f64 %u %u %f %f %f %f %f',ilength^2,'delimiter','\t');
                    fclose(fid);
                    
                    cond = ~isnan(height(row,col,:));
                    f = (extractforce-(squeeze(height(row,col,cond))*1e-6*Data_Processed{1,6}(index+1)+Data_Processed{1,5}(index+1)))*1e9;
                    l = length(f);
                    if l > size(force,3)
                        force(:,:,end+1:end+l-size(force,3)) = NaN;
                    end
                    force(row,col,1:l) = f;
                end
            end
        end
    end
end

end

