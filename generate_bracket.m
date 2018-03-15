function res = generate_bracket

    % To consider: given that different rounds have different point values,
    % with games further downstream being more valuable, is it possible to
    % weight Monte Carlo probability with bracket value to maximize score
    % rather than value?
    
    
    % ESPN point values:
        % Round 2: 10 points per pick
        % Round 3: 20 points per pick
        % Round 4: 40 points per pick
        % Round 5: 80 points per pick
        % Round 6: 160 points per pick
        % Championship: 320 points per pick
        
    % Method: for each match, select the winner as the team that has the
    % greatest probability of winning the championship
    
    % This steers the bracket towards making the most accurate long-term
    % predictions, since these are more highly weighted and valuable
    
	load('probabilities','P','pc','O','B')
    
    cwp = 'tight'; % column width preference: 'equal' or 'tight'
    sbc = 2; % spacing between columns, required when cwp = 'tight'
    
    %%
    
    for CX = 1:6 % for each playoff round; 1 for 64, 2 for 32, etc.

        CY = 1; % cursor y, corresponding to bracket level
        op = 0; % outcomes predicted per round, for knowing when to advance to next round
        on = 64/(2^CX); % outcomes needed in this round

%         disp(['================= Round of ' num2str( on*2 ) ' ================='])
%         disp(' ')

        while op < on % repeat until outcomes predicted equals outcomes needed

            %% Find the next match

            mi = [0 0]; % match indices: vertical indices for current matchup being examined
            while isempty(B{CY,CX})
                CY = CY+1;
            end
            mi(1) = CY;
            CY = CY+1;
            while isempty(B{CY,CX})
                CY = CY+1;
            end
            mi(2) = CY;
            CY = CY+1;

            %% Look up ratings for each team

%             disp(['Game ' num2str(op+1)])
%             disp(['Cursor at ' num2str(CY) ', ' num2str(CX)])
%             disp([B{mi(1),CX} ' vs. ' B{mi(2),CX}])
%             disp(['Champion probabilities: ' num2str(P{mi(1),end}*100) '%, ' num2str(P{mi(2),end}*100) '%'])

            %% Predict the outcome
            
            if P{mi(1),end} > P{mi(2),end} % first team wins
                wti = mi(1); % winning team index
            else
                wti = mi(2);
            end
            
%             disp(['Predicted outcome: ' B{wti,CX} ' advances'])
%             disp(' ')
            B{wti,CX+1} = B{wti,CX}; % write winner into next round

            op = op+1; % increment the outcomes predicted counter

        end

        % Round is complete

    end
    
    % Playoffs are complete
    
    save('bracket','B')
    
    % Generate a nicely-formatted bracket for viewing
    % Show only Round of 32 onwards for compactness
    
    B_ = cell(size(B,1)/2,size(B,2)-1);
    
    dy = 1; % vertical spacing between entries
    vo = 0.5; % vertical offset
    
    for x = 2:size(B,2)
        i = 1; % index of team in round
        for y = 1:size(B,1)
            if ~isempty(B{y,x})
                B_{round(i+vo),x-1} = B{y,x};
                i = i+dy;
            end
        end
        dy = dy*2; % double vertical spacing between rounds
        vo = vo*2;
    end
    B_(1,:) = []; % crop empty first row
    
    % Fill empty cells with single spaces
    for i = 1:numel(B_)
        if isempty(B_{i})
            B_{i} = ' ';
        end
    end
    
    disp(' ')
	disp('Bracket solution:')

    disp(' ')
    
    % Build the format spec
    switch cwp
        case 'equal'
            fs = '%-23s';
            fs = [fs fs fs fs fs fs '\n'];
        case 'tight'
            % For a tight fit, record max width of each column
            cw = zeros(1,size(B_,2));
            for i = 1:length(cw) % for each column
                cw(i) = 0;
                for a = 1:size(B_,1) % for each entry
                    cw(i) = max([cw(i) length(B_{a,i})]);
                end
            end
            cw = cw+sbc;
            fs = ''; % initialize empty
            for i = 1:size(B_,2)
                fs = [fs '%-' num2str(cw(i)) 's'];
            end
            fs = [fs '\n'];
        otherwise
            error(['Column width preference ''' cwp ''' not recognized; options are ''equal'' and ''tight'''])
    end
    
    % Output bracket
    res = B_; % save a copy between transposing for saving to Excel
    B_ = B_'; % transpose for text output
    fprintf(fs,B_{:});
    disp(' ')
    
end



















































