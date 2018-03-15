function march_madness

    % This program generates multiple brackets for varying K-values and is 
    % top-level program in this codebase

    % FIDE chess uses 10-40, with higher values for newer players
        % Source: https://en.wikipedia.org/wiki/Elo_rating_system#Most_accurate_K-factor
        
        % Free parameters:
            % Elo mean
            % Elo K factor
            % Elo: static or dynamic
            
    elo_mean = 1500;%[1000 1500];
    K = 25;%[10 25 40];
    elo_state = {'dynamic'};%{'static','dynamic'};
        
    clc
    close all
    
    addpath('C:\Users\dichter.daniel.AURORA\Documents\Engineering_Reference\code') % for timestamp
    fn = ['march_madness_' timestamp]; % filename
    cc = length(elo_mean)*length(K)*length(elo_state); % config count
    diary([fn '.txt']) % record text in command window
    ci = 1; % config index

    for em = elo_mean
        for k = K
            for es = elo_state
                
                es = es{:};

                disp('=================================================================================================')
                disp(' ')
                disp(['Generating bracket ' num2str(ci) ' of ' num2str(cc) ])
                disp(['elo_mean: ' num2str(em) ])
                disp(['K: ' num2str(k) ])
                disp(['elo_state: ' num2str(es)])
                disp(' ')

                rate_regular_season(em,k)
                simulate_playoffs(es,k)
                visualize_probability
                B = generate_bracket;
                A{ci} = B; % record bracket for polling later
                
                % Write to Excel
                
                sn = [num2str(em) '_' num2str(k) '_' es]; % sheet name
                xlswrite(fn,B,sn)
                ci = ci+1;
                
            end

        end
    end
    
    % Poll all brackets to generate a bracket consensus
    B_poll = cell(size(A{1})); % poll of all brackets
    for i = 1:size(A,2) % for each bracket vote
        B_vote = A{i}; % this particular vote
        for a = 1:numel(B_vote) % for each cell
            if ~isequal(B_vote{a},' ')
                if isempty(B_poll{a})
                    B_poll{a} = B_vote{a};
                else
                    B_poll{a} = [B_poll{a} newline B_vote{a}];
                end
            else
                B_poll{a} = ' ';
            end
        end
    end
    xlswrite(fn,B_poll,'poll')
    
    % Delete Sheet1; source: https://www.mathworks.com/matlabcentral/answers/158143-delete-sheet-number-1-in-excel
    newExcel = actxserver('excel.application');
    newExcel.DisplayAlerts = false;
    excelWB = newExcel.Workbooks.Open([pwd '\' fn '.xls'],0,false);
    excelWB.Sheets.Item(1).Delete;
    excelWB.Save();
    excelWB.Close();
    newExcel.Quit();
    delete(newExcel);
    
    diary off

end