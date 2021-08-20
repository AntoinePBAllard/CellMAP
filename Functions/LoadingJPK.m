function out = LoadingJPK(selpath)
global answerUnzip
global iLength
answerUnzip = [];

% First folder to scan is selpath
foldersToEval{1} = selpath;
txtDir = [];
jpkDir = [];
n = 1;
h = waitbar(0.1,'Please wait... CellMAP is reading your data.');

while length(foldersToEval) - n >= 0
    InfoDir = dir(fullfile(foldersToEval{n}));
    InfoDirSize = size(InfoDir,1);
    for i = 1:InfoDirSize
        %% Find all subfolders to scan
        [~,~,ext] = fileparts(InfoDir(i).name);
        if InfoDir(i).isdir&&~strcmp(InfoDir(i).name,'.')&&~strcmp(InfoDir(i).name,'..')&&~strcmp(InfoDir(i).name,'ForceCurves')
            foldersToEval{end+1} = fullfile(InfoDir(i).folder,InfoDir(i).name); % Add a folder to be scanned
        elseif strcmp(ext,'.txt')
            txtDir = [txtDir;dir(fullfile(InfoDir(i).folder,InfoDir(i).name))]; % Read if there is .txt files to be scanned
        elseif strcmp(ext,'.jpk-qi-data')
            jpkDir = [jpkDir;dir(fullfile(InfoDir(i).folder,InfoDir(i).name))]; % Read if there is .jpk-qi-data files to be scanned
        end
    end
    waitbar(0.2,h,['Number of subfolders scanned: ' num2str(length(foldersToEval)) ...
        ' (' num2str(length(txtDir)) ' .txt and '...
        num2str(length(jpkDir)) ' .jpk-qi-data )']);
    n = n + 1;
end

if ~isempty(txtDir)
    % Read .txt files
    waitbar(0,h,'Reading .txt files. Remaining time: Calculating...');
    for txt = 1:length(txtDir)
        tic
        try
            temp = strsplit(txtDir(txt).name,{'_','.txt'});
            temp = regexp(strcat(temp{1}),'\d*','Match');
            nameCell = strcat(temp{:});
            nameCell = matlab.lang.makeValidName(nameCell);
            filename = fullfile(txtDir(txt).folder,txtDir(txt).name);
            importedData = importdata(filename,'\t');
            if isstruct(importedData)
                nbHeader = size(importedData.textdata,1);
            else
                nbHeader = 0;
                for j = 1:size(importedData,1)
                    if importedData{j}(1) == '#'
                        nbHeader = nbHeader + 1;
                    end
                end
                importedData = importdata(fullfile(txtDir(txt).folder,txtDir(txt).name),' ',nbHeader);
            end
            j=1;
            for k=1:nbHeader
                temp=strsplit(importedData.textdata{k,1},{'# ',': '},'CollapseDelimiters',true);
                if(size(temp,2)==3)
                    importedData_split{j,1}=temp{1,2};
                    importedData_split{j,2}=temp{1,3};
                    j = j+1;
                end
            end
            nameVar_location = strcmp(importedData_split(:,1),'channel')==1;
            nameVar = matlab.lang.makeValidName(importedData_split{nameVar_location,2});
            out.(nameVar).(nameCell).data = importedData.data;
            fastSize_location = find(strcmp(importedData_split(:,1),'fastSize')==1);
            iLength_location = find(strcmp(importedData_split(:,1),'iLength')==1);
            if ~isempty(fastSize_location) || ~isempty(iLength_location)
                fastSize = str2double(importedData_split{fastSize_location,2})*1e6;
                iLength = str2double(importedData_split{iLength_location,2});
                out.(nameVar).(nameCell).pixel = fastSize/iLength;
            else
                out.(nameVar).(nameCell).pixel = 1;
            end
            Unit_location = strcmp(importedData_split(:,1),'Unit')==1;
            out.(nameVar).(nameCell).unit =importedData_split{Unit_location,2};
            if strcmp(out.(nameVar).(nameCell).unit,'N')
                out.(nameVar).(nameCell).unit = 'pN';
                out.(nameVar).(nameCell).data = out.(nameVar).(nameCell).data*1e12;
            elseif strcmp(out.(nameVar).(nameCell).unit,'m')
                out.(nameVar).(nameCell).unit = 'µm';
                out.(nameVar).(nameCell).data = out.(nameVar).(nameCell).data*1e6;
            elseif strcmp(out.(nameVar).(nameCell).unit,'Pa')
                out.(nameVar).(nameCell).unit = 'kPa';
                out.(nameVar).(nameCell).data = out.(nameVar).(nameCell).data*1e-3;
            end
        catch ME
            disp(ME.identifier)
            disp(['Unable to read data from ' txtDir(txt).name])
        end
        t = toc;
        waitbar(txt/length(txtDir),h,{'Reading .txt files.',['Remaining time: ' num2str(round(t*(length(txtDir)-txt)/60)) ' min.']});
    end
end

if ~isempty(jpkDir)
    % Read .jpk-qi-data files
    waitbar(0.1,h,{'Reading .jpk-qi-data files.',['Remaining time: Calculating... (> ' num2str(round(2*length(jpkDir))) ' min)']});
    for jpk = 1:length(jpkDir)
        tic
        temp = strsplit(jpkDir(jpk).name,'_');
        temp = regexp(strcat(temp{1}),'\d*','Match');
        nameCell = strcat(temp{:});
        nameCell = matlab.lang.makeValidName(nameCell);
        ForceCurvesFolder = UnzipJPK(fullfile(jpkDir(jpk).folder,jpkDir(jpk).name));
        
        if ~strcmp(answerUnzip,'No')
            jpkdata = load(fullfile(ForceCurvesFolder,'jpkdata'));
            out.Force.(nameCell) = jpkdata;
            load(fullfile(ForceCurvesFolder,'jpkdata'),'indent');
            out.('Indentation').(nameCell).data = indent;
            out.('Indentation').(nameCell).unit = 'µm';
            out.('Indentation').(nameCell).pixel = 1;
        end
        if exist(fullfile(ForceCurvesFolder,'newVar.mat'),'file')
            load(fullfile(ForceCurvesFolder,'newVar.mat'),'newVar')
            fields = fieldnames(newVar);
            for i = 1:length(fields)
                out.(fields{i}).(nameCell).data = newVar.(fields{i}).(nameCell).data;
                if isempty(newVar.(fields{i}).(nameCell).unit)
                    out.(fields{i}).(nameCell).unit = '';
                else
                    out.(fields{i}).(nameCell).unit = newVar.(fields{i}).(nameCell).unit;
                end
                out.(fields{i}).(nameCell).pixel = newVar.(fields{i}).(nameCell).pixel;
            end
        end
        t = toc;
        waitbar(jpk/length(jpkDir),h,['Reading .jpk-qi-data files. Remaining time: ' num2str(round(t*(length(jpkDir)-jpk)/60)) ' min.']);
    end
end
close(h);
pause(0.1)
clear h