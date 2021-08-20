% Get the list of a subpopulation of cells
% INPUT: 
% varList is the list of cells (items)
% nLimit is the max number of cells

function [list,answer] = getListCells(cellList)
    nLimit = length(cellList);
    list = [];
    prompt = {strcat('Enter the list of the subpopulation: e.g. for a list of 6 images',...
       ' "all" takes all images, "1,2,3,6" or "1-3,6" or "1-3,end" or "~4,5" or "~4-5" takes the same four images')};
    dlgtitle = 'Input';
    dims = [1 50];
    definput = {'all'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    if ~isempty(answer)
        answer = answer{1};
        if strcmp(answer,'all')
            list = cellList;
        else
            temp = strsplit(answer,'~');
            temp = strsplit(temp{end},',');
            for i = 1:size(temp,2)
                temp_2 = strsplit(temp{1,i},'-');
                if size(temp_2,2) == 1
                    if strcmp(temp_2{1},'end')
                        temp_2{1} = num2str(nLimit);
                    end
                    list = cat(2,list,str2double(temp_2{1}));
                else
                    if strcmp(temp_2{2},'end')
                        temp_2{2} = num2str(nLimit);
                    end
                    list = cat(2,list,str2double(temp_2{1}):str2double(temp_2{2}));
                end
            end
            if strcmp(answer(1),'~')
                completeList = 1:nLimit;
                completeList(list) = [];
                list = cellList(completeList);
            else
                list = cellList(list);
            end
        end
    end
end