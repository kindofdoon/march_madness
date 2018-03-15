function simulate_playoffs(elo_state, K)

    % Use Monte Carlo method to get a feel for the probability of each team's chances
        % Execute a random playout on the input bracket, updating Elo after each game
        % Parse through the input bracket, incrementing if team made round of 32, 16, 8, 4, 2, 1
        % Repeat preceding two steps a large number of times
        % Normalize results to number of playouts to give probability of making each round
    % Down-select to a final bracket
        % For each matchup, select the winner as the team that has the greater probability of winning the championship
        
    load('teams','T')
    load('ratings_regular_season','R')
    
    %% Control inputs
    
    check_every = 5; % sec, interval at which to check for convergence
    ct = 0.00025; % ~, 0-1, convergence threshold, if max probability changes less than this value between check_every interval, convergence is achieved and function terminates
    
    %%
    
    % Define the blank bracket
        % Syntax: vertically-adjacent teams play each other
        % Team names rather than numbers are used, to be pulled from T(:,22)
        
    % Column 1: 64 teams remain
    % Column 2: 32 teams remain
    % Column 3: 16 teams remain
    % Column 4: 8 teams remain
    % Column 5: 4 teams remain
    % Column 6: 2 teams remain
    % Column 7: 1 teams remain
    
    B = cell(64,7); % empty bracket

    B(:,1) = { % bracket per ESPN
                % Names in comments are as they appear in ESPN's bracket
        
                % South
                    'Virginia' % 'UVA'
                    'UMBC'
                    'Creighton'
                    'Kansas State'
                    'Kentucky'
                    'Davidson'
                    'Arizona'
                    'Buffalo'
                    'Miami (FL)' % 'Miami'
                    'Loyola (IL)' % 'Loyola-Chicago'
                    'Tennessee'
                    'Wright State'
                    'Nevada'
                    'Texas'
                    'Cincinnati'
                    'Georgia State'
                
                % West
                    'Xavier'
                    'Texas Southern'; % First Four: they beat 'North Carolina Central'
                    'Missouri'
                    'Florida State'
                    'Ohio State' % 'OSU'
                    'South Dakota State' % 'South Dakota St...'
                    'Gonzaga'
                    'North Carolina Greensboro' % 'UNCG'
                    'Houston'
                    'San Diego State'
                    'Michigan'
                    'Montana'
                    'Texas A&M'
                    'Providence'
                    'UNC'
                    'Lipscomb'
                
                % East
                    'Villanova'
                    'Radford' % First Four: they beat 'LIU Brooklyn'
                    'Virginia Tech'
                    'Alabama'
                    'West Virginia'
                    'Murray State'
                    'Wichita State'
                    'Marshall'
                    'Florida'
                    'St. Bonaventure' % First Four: they beat 'UCLA'
                    'Texas Tech'
                    'Stephen F. Austin' % 'SF Austin'
                    'Arkansas'
                    'Butler'
                    'Purdue'
                    'Cal State Fullerton' % 'CSU Fullerton'
                
                % Midwest
                    'Kansas'
                    'Penn'
                    'Seton Hall'
                    'North Carolina State' % 'NC State'
                    'Clemson'
                    'New Mexico State'
                    'Auburn'
                    'College of Charleston' % 'Charleston'
                    'Texas Christian' % 'TCU'
                    'Syracuse' % First Four: they beat 'Arizona State'
                    'Michigan State'
                    'Bucknell'
                    'Rhode Island' % 'URI'
                    'Oklahoma'
                    'Duke'
                    'Iona'
                
             };
         
    % Assemble regular season ratings
    R_ = [T(:,22), num2cell(R(end,:)')]; % regular season ratings for all teams
    
    % Generate a matrix representing team ratings in bracket order
    R = zeros(size(B,1),1);
    for t = 1:size(B,1) % for each team that made playoffs
        for r = 1:size(R_,1) % for each D1 team
            if isequal(B(t,1),R_(r,1))
                R(t) = R_{r,2};
                break
            end
        end
    end
    
    % Outcomes, to record results of all Monte Carlo simulations
    O = cell(size(B,1),7); % O for outcomes
    for i = 1:numel(O)
        O{i} = 0;
    end
    O(:,1) = B(:,1);
    P = cell(size(O)); % P for predictions, normalized version of O
    
%     % Delete all teams that did not make playoffs
%     for t = size(R,1):-1:1 % for each team
%         mt = 0; % made tournament flag
%         for a = 1:size(B,1) % for each team that made the tournament
%             if strcmp(R{t,1},B{a,1})
%                 mt = 1;
%                 break
%             end
%         end
%         if ~mt
%             R(t,:) = []; % delete team
%         end
%     end
    
    %% Execute Monte Carlo playouts
    
    pc = 0; % playout count
    tic
    last_check = tic;
    disp('Simulating playoffs...')
    disp(' ')
    
    % Parameters used to monitor convergence
    tp = 1; % top probability, ~, 0-1, intialized with dummy value
    
    is_converged = 0;
    
    while ~is_converged % run until converged
        
        %% Setup for a playout
        
        % Create copies for modification
        R_ = R;
        B_ = B;
        
        %% Execute a playout
        
        for CX = 1:6 % for each playoff round; 1 for 64, 2 for 32, etc.
            
            CY = 1; % cursor y, corresponding to bracket level
            op = 0; % outcomes predicted per round, for knowing when to advance to next round
            on = 64/(2^CX); % outcomes needed in this round
            
%             disp(['================= Round of ' num2str( on*2 ) ' ================='])
%             disp(['Outcomes needed in this round: ' num2str(on)])
%             disp(' ')
            
            while op < on % repeat until outcomes predicted equals outcomes needed

                %% Find the next match

                mi = [0 0]; % match indices: vertical indices for current matchup being examined
                while isempty(B_{CY,CX})
                    CY = CY+1;
                end
                mi(1) = CY;
                CY = CY+1;
                while isempty(B_{CY,CX})
                    CY = CY+1;
                end
                mi(2) = CY;
                CY = CY+1;

%                 disp(['Game ' num2str(op+1)])
%                 disp(['Cursor at ' num2str(CY) ', ' num2str(CX)])
%                 disp([B_{mi(1),CX} ' vs. ' B_{mi(2),CX}])
%                 disp(['Ratings, prior: ' num2str(R_mi(1)) ', ' num2str(R_mi(2)) ])

                % Expected scores
                E(1) = 1/(1+10^((R(mi(2))-R(mi(1)))/400));
                E(2) = 1/(1+10^((R(mi(1))-R(mi(2)))/400));

%                 disp(['Expected scores: ' num2str(E(1)) ', ' num2str(E(2)) ])

                %% Predict the outcome

                if rand <= E(1) % first team wins
                    res = 'W';
                else
                    res = 'L';
                end

                % Actual scores
                switch res % the game result
                    case 'W'
                        S = [1 0];
                        wti = mi(1); % winning team index
                        B_{wti,CX+1} = B{mi(1),1}; % first team advances
                    case 'L'
                        S = [0 1];
                        wti = mi(2); % winning team index
                        B_{wti,CX+1} = B{mi(2),1}; % second team advances
                    otherwise
                        error('Game outcome not recognized')
                end

%                 disp(['Outcome: ' res])

                % Update ratings
                switch elo_state
                    case 'dynamic'
                        for i = 1:2
                            R_(mi(i)) = R_(mi(i)) + K*(S(i)-E(i));
                        end
                    case 'static'
                        % Do not update ratings
                    otherwise
                        error(['elo_state of ''' elo_state ''' not recognized'])
                end

%                 disp(['Ratings, updated: ' num2str(R_{ri(1),2}) ', ' num2str(R_{ri(2),2}) ])
%                 disp(' ')

                O{wti,CX+1} = O{wti,CX+1}+1; % record outcome by incrementing winning team's count
                
%                 disp(['Incremented O(' num2str(wti) ', ' num2str(CX+1) ')'])
%                 pause
                
                op = op+1; % increment the outcomes predicted counter
                
%                 pause
%                 O
%                 pause

            end
            
%             O
%             pause
            
            % Round is complete
            
        end
        
        % Playoffs are complete
        
        pc = pc+1;
        
        %% Save periodically
        
        if toc(last_check) > check_every
            
            normalize_results
            [val, ind] = max([P{:,end}]); % monitor top probability
            
            dp = tp - val; % change in top probability since last check
            tp = val;
            
            if abs(dp) < ct
                is_converged = 1;
            end
            
            last_check = tic; % reset timer
            
            disp(['Current leader: ' B{ind,1} ', ' num2str(round(val*100*100)/100) '%'])
            disp(['Change in top probability since last check: ' num2str(dp*100) '%' ])
            disp(['is_converged: ' num2str(is_converged) ])
            disp(' ')
        end
        
    end
    
    % Convergence is achieved
    
    save('probabilities','P','pc','O','B')
    te = toc; % s, time elapsed
    disp(['Saved: simulated ' num2str(pc) ' playouts in ' num2str(te) ' sec, ' num2str(round(pc/te)) ' playouts/sec'])
    
    function normalize_results
        P = O;
        % Normalize results to playout count for probabilities
        for y = 1:size(P,1)
            for x = 2:size(P,2)
                P{y,x} = P{y,x}/pc;
            end
        end
        
    end

end


















































