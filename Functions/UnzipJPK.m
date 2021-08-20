function finalFolder = UnzipJPK(file)
global unzipsoft answerUnzip iLength
    [filepath, baseFileName, ~] = fileparts(file);
    finalFolder = fullfile(filepath,'ForceCurves',baseFileName);
    if ~exist(finalFolder, 'dir')
        if isempty(answerUnzip)
            quest = 'There are force curves. Do you want to LOAD them? (For the first time, it may take several minutes)';
            answerUnzip = questdlg(quest,'Unzip force curves','Yes','No','Yes');
            switch answerUnzip 
                case 'Yes'
                quest = 'To speed up unzip, it is recommanded to select your own unzip program (e.g. 7z.exe). Proceed?';
                answer2 = questdlg(quest,'Pick you unzip software','Yes','No','Yes');
                switch answer2
                    case 'Yes'
                        [filezip, pathzip] = uigetfile('C:\Program Files\7-Zip\7z.exe');
                        unzipsoft = fullfile(pathzip,filezip);
                    case 'No'
                        unzipsoft = 'rienvide';
                end
            end
        end
        if strcmp(answerUnzip,'Yes')
            disp(['Extracting force curves: ' finalFolder])
            if strcmpi(unzipsoft(end-5:end),'7z.exe')
                disp(['Decompress with ' unzipsoft])
                system(['"' unzipsoft '" x -y "-o' finalFolder '" "' file '"']);
            else
                disp('Decompress with Matlab')
                unzip(file,finalFolder)
            end
        end
    end
    if ~exist(fullfile(finalFolder,'jpkdata.mat'),'file')
        disp('Reading force curves')
        [indent,height,force] = ReadJPK(finalFolder); % unit: m
        save(fullfile(finalFolder,'jpkdata.mat'),'indent','height','force')
    end
end