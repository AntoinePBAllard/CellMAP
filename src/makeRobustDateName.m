function nameCell = makeRobustDateName(rawDate)

    rawDate = char(string(rawDate));
    rawDate = strrep(rawDate, '\:', ':');

    % --- Extraire tous les nombres ---
    nums = regexp(rawDate, '\d+', 'match');
    nums = str2double(nums);

    % --- Heuristique intelligente ---
    % Cas ISO : yyyy mm dd HH mm ss
    if length(nums) >= 6 && nums(1) > 1900
        Y = nums(1);
        M = nums(2);
        D = nums(3);
        h = nums(4);
        m = nums(5);
        s = nums(6);

    % Cas type: Fri Nov 22 11:59:35 2019
    elseif length(nums) >= 5
        D = nums(1);
        h = nums(2);
        m = nums(3);
        s = nums(4);
        Y = nums(end);

        % mois en texte → conversion
        months = {'Jan','Feb','Mar','Apr','May','Jun', ...
                  'Jul','Aug','Sep','Oct','Nov','Dec'};

        for k = 1:12
            if contains(rawDate, months{k}, 'IgnoreCase', true)
                M = k;
                break;
            end
        end
    else
        error('Format non reconnu : %s', rawDate);
    end

    % --- Création datetime (sans fuseau) ---
    dt = datetime(Y,M,D,h,m,s);

    % --- Nom unique ---
    nameCell = matlab.lang.makeValidName(string(dt,'yyyyMMdd_HHmmss'));

end