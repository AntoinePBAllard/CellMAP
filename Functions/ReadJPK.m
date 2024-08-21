function [indent,height,force] = ReadJPK(folder,jpkqidataFileName,listRow,listCol)
%% This function reads all subfolder in 'folder' (unzip from jpk using UnzipJPK.m)
%% and reconstruct indentation and height maps, as well as force curve.
% This code has been adapted from someone else, written in another langage
% (python?), but to date I cannot find the source. I apologise for that,
% and I am ready to acknowledge the person if they read this message.

zipJavaFile  = java.io.File(fullfile(folder,jpkqidataFileName));
% Create a Java ZipFile
zipFile = org.apache.tools.zip.ZipFile(zipJavaFile);

% Get header.properties
dataTmp = getZipFileContent(zipFile,'header.properties');
format = repmat('%s',1,100);
header_metadata_raw=textscan(dataTmp,format,'whitespace','','delimiter','');
header_metadata_raw=header_metadata_raw{1,1};

j=1;
for i=1:size(header_metadata_raw,1)
    temp=strsplit(header_metadata_raw{i,1},'=');
    if(size(temp,2)==2)
        header_metadata_split{j,1}=temp{1,1};
        header_metadata_split{j,2}=temp{1,2};
        j = j+1;
    end
end

% Get shared-data\header.properties
dataTmp = getZipFileContent(zipFile,'shared-data/header.properties');
header_shared_data_metadata_raw=textscan(dataTmp,format,'whitespace','','delimiter','');
header_shared_data_metadata_raw=header_shared_data_metadata_raw{1,1};
j=1;
for i=1:size(header_shared_data_metadata_raw,1)
    temp=strsplit(header_shared_data_metadata_raw{i,1},'=');
    if(size(temp,2)==2)
        header_shared_data_metadata_split{j,1}=temp{1,1};
        header_shared_data_metadata_split{j,2}=temp{1,2};
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

if nargin==2
    listCol = 1:ilength;
    listRow = ilength:-1:1;
end

processed = dir([folder,filesep,'*tsv']);
fid= fopen(fullfile(processed(end).folder,processed(end).name));
Data_ProcessedTitle = textscan(fid,'%s',13,'delimiter','\t'); % NEEDS TO BE OPEN ONCE!
Data_Processed = textscan(fid,'%s %d8 %u %u %f64 %f64 %u %u %f %f %f %f %f',ilength^2,'delimiter','\t');
fclose(fid);

% strToFind ={'quantitative-imaging-map.settings.force-settings.','.num-points'};
% fun = @(s)contains(header_metadata_split(:,1),s);
% out = cellfun(fun,strToFind,'UniformOutput',false);
% num_points_location = all(horzcat(out{:}),2);
% num_points = header_metadata_split(num_points_location,2);

segment_style = {'extend'};
subfilename = 'index/0/segments/0/segment-header.properties';
dataTmp = getZipFileContent(zipFile,subfilename);
segment_header_metadata_raw = textscan(dataTmp,format,'whitespace','','delimiter','');
segment_header_metadata_raw=segment_header_metadata_raw{1,1};

j=1;
for i=1:size(segment_header_metadata_raw,1)
    temp=strsplit(segment_header_metadata_raw{i,1},'=');
    if(size(temp,2)==2)
        segment_header_metadata_split{j,1}=temp{1,1};
        segment_header_metadata_split{j,2}=temp{1,2};
        j = j+1;
    end
end
channel_name = {'measuredHeight'};
lcd_info_location = strcmp(segment_header_metadata_split(:,1),strcat('channel.',channel_name{:},'.lcd-info.*'))==1;
lcd_info = segment_header_metadata_split(lcd_info_location,2);

offset_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.offset'))==1;
data.(segment_style{:}).(channel_name{:}).offset = str2double(header_shared_data_metadata_split(offset_location,2));
multiplier_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.multiplier'))==1;
data.(segment_style{:}).(channel_name{:}).multiplier = str2double(header_shared_data_metadata_split(multiplier_location,2));
        
conversion_name = {'nominal'};
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

if nargin==2
    indent = NaN(ilength,ilength);
    height = NaN(ilength,ilength);
end

multiplier1 = data.(segment_style{:}).(channel_name{:}).multiplier;
offset1 = data.(segment_style{:}).(channel_name{:}).offset;
multiplier2 = data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).multiplier;
offset2 = data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).offset;
for col = listCol
    for row = listRow
        index = (row-1)*ilength+col-1;
        subfilename = strcat('index/',num2str(index),'/segments/0/channels/',channel_name{:},'.dat');
        flag_temp = getZipFileContentDat(zipFile,subfilename);
        flag_temp = flag_temp*multiplier1+offset1;
        extractheight = (flag_temp+offset2)*multiplier2;
        h = extractheight*1e6; % in [um]
        if nargin==2
            indent(row,col)=h(end);
            l = length(h);
            if l > size(height,3)
                height(:,:,end+1:end+l-size(height,3)) = NaN;
            end
            height(row,col,1:l) = h;
        else
            indent = h(end);
            height = h;
        end
    end
end

channel_name = {'vDeflection'};
lcd_info_location = strcmp(segment_header_metadata_split(:,1),strcat('channel.',channel_name{:},'.lcd-info.*'))==1;
lcd_info = segment_header_metadata_split(lcd_info_location,2);

offset_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.offset'))==1;
data.(segment_style{:}).(channel_name{:}).offset = str2double(header_shared_data_metadata_split(offset_location,2));
multiplier_location = strcmp(header_shared_data_metadata_split(:,1),strcat('lcd-info.',lcd_info{:},'.encoder.scaling.multiplier'))==1;
data.(segment_style{:}).(channel_name{:}).multiplier = str2double(header_shared_data_metadata_split(multiplier_location,2));
        
conversion_name = {'force'};
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

if nargin == 2
    force = NaN(ilength,ilength);
end
for col = listCol
    for row = listRow
        index = (row-1)*ilength+col-1;

        subfilename = strcat('index/',num2str(index),'/segments/0/channels/',channel_name{:},'.dat');

        flag_temp = getZipFileContentDat(zipFile,subfilename);

        multiplier = data.(segment_style{:}).(channel_name{:}).multiplier;
        offset = data.(segment_style{:}).(channel_name{:}).offset;
        flag_temp = flag_temp*multiplier+offset;
        multiplier = data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).multiplier;
        offset = data.(segment_style{:}).(channel_name{:}).(conversion_name{:}).offset;
        extractforce = (flag_temp+offset)*multiplier;
        if nargin == 2
            cond = ~isnan(height(row,col,:));
            f = (extractforce-(squeeze(height(row,col,cond))*1e-6*Data_Processed{1,6}(index+1)+Data_Processed{1,5}(index+1)))*1e9;
            l = length(f);
            if l > size(force,3)
                force(:,:,end+1:end+l-size(force,3)) = NaN;
            end
            force(row,col,1:l) = f;
        else
            cond = ~isnan(height);
            f = (extractforce-(squeeze(height(cond))*1e-6*Data_Processed{1,6}(index+1)+Data_Processed{1,5}(index+1)))*1e9;
            force = f;
        end
    end
end

zipFile.close

end

