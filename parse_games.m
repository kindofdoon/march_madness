function parse_games

    load('games','G')
    load('teams','T')

    %% Check that all team names match

    % List of teams that played with D1 schools, including some non-D1
    U = unique(G(:,3));
    U = sortrows(U);

    disp(['Unique teams that played D1 schools this year: ' num2str(size(U,1)) ])

    % Find all non-D1 schools by comparing to previous team list
    for i = 1:size(U,1)
        U{i,2} = 0; % 0 if not D1, 1 if D1
        for a = 1:size(T,1)
            if strcmp(U{i},T{a,22})
                U{i,2} = 1;
                break
            end
        end
    end

    % Output summary
    disp(['D1 schools: ' num2str(sum([U{:,2}])) ])
    nm = size(T,1)-sum([U{:,2}]);
    disp(['Missing D1 schools: ' num2str(nm) ])

    % Show missing D1 schools, if applicable
    if nm > 0
        disp(' ')
        disp('List of missing D1 schools:')
        disp(' ')
        for i = 1:size(T,1)
            is_missing = 1;
            for a = 1:size(U,1)
                if strcmp(T{i,22},U{a,1})
                    is_missing = 0;
                    continue
                end
            end
            if is_missing
                disp(T{i,22})
            end
        end
    end

    %% Align team lists
    T = sortrows(T,22);

    % Re-number teams to account for shifts due to alphabetizing
    for i = 1:size(T,1)
        T{i,1} = i;
    end

    %% Delete non-D1 games from the game log
    disp('Deleting non-D1 games from the game log...')
    gn = size(G,1); % number of games before non-D1 deletion

    for g = size(G,1):-1:1 % for each game

        game_is_D1 = 0;

        for t = 1:size(T,1) % for each D1 team

            if strcmp(G{g,3},T{t,22})
                game_is_D1 = 1;
                break
            end

        end

        if ~game_is_D1
            G(g,:) = []; % delete the game
        end

    end

    disp(['Non-D1 games deleted from game log: ' num2str(gn-size(G,1))])

    %% Delete duplicate games

    disp('Sorting games chronologically...')
    for g = 1:size(G,1)
        G{g,5} = datenum(G{g,1});
    end
    G = sortrows(G,5);

    % Convert cells to chars
    for y = 1:size(G,1)
        for x = 1:size(G,2)-1
            G{y,x} = char(G{y,x});
        end
    end

    %% Delete duplicate games

    gn = size(G,1); % number of games before duplicate deletion

    disp('Deleting duplicate games...')
    for g = size(G,1):-1:1 % for each game

        % Generate a reciprocal entry
        G_ = {
            G{g,1}
            G{g,3}
            G{g,2}
            0
            G{g,5}
         };

        switch G{g,4}
            case 'W'
                G_{4} = 'L';
            case 'L'
                G_{4} = 'W';
            otherwise
            error(['Game outcome in row ' num2str(g) ', ' G{g,4} ', is unrecognized'])
        end

        G_ = G_';

        i = min(find([G{:,5}]==G_{5})); % index for starting search: first game of that day

        while i<=size(G,1) && G{i,5}<=G_{5}

            if isequal(G(i,:),G_)
                G(i,:) = []; % delete duplicate
                break
            end

            i = i+1;

        end

    end

    disp(['Duplicate games deleted from game log: ' num2str(gn-size(G,1))])

    %% Verify that no duplicates are present

    disp('Verifying that all duplicate games have been deleted...')
    for g = 1:size(G,1) % for each game

        % Generate a reciprocal entry
        G_ = {
            G{g,1}
            G{g,3}
            G{g,2}
            0
            G{g,5}
         };

        switch G{g,4}
            case 'W'
                G_{4} = 'L';
            case 'L'
                G_{4} = 'W';
            otherwise
            error(['Game outcome in row ' num2str(g) ', ' G{g,4} ', is unrecognized'])
        end

        G_ = G_';

        i = min(find([G{:,5}]==G_{5})); % index for starting search: first game of that day

        while i<=size(G,1) && G{i,5}<=G_{5}

            if isequal(G(i,:),G_)
                warning(['Game ' num2str(g) ' is a duplicate of game ' num2str(i)])
                break
            end

            i = i+1;

        end

    end
    
    disp(['Unique D1-only games: ' num2str(size(G,1))])
    disp(['Average D1-only games per team: ' num2str( size(G,1) *2 /size(T,1) )])
    
    save('games_parsed','G');

end



















































