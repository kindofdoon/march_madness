function rate_regular_season(elo_mean, K)
    
    %% Inputs
    
    % Elo parameters
    
    % Plot properties
    stf = 17; % show text for N teams to prevent visual overcrowding
    fs = [750 500]; % pixels, figure size
    ts = ' '; % text space to separate text from lines

    %% Computer Elo over time

    load('games_parsed','G')
    load('teams','T')

    R = zeros(size(G,1)+1,size(T,1)); % R for rating, rather than E for Elo, to avoid collision with expected scores E
    G = [cell(1,size(G,2)) ; G]; % pad first row
    for i = 1:numel(R)
        R(i) = NaN;
    end
    R(1,:) = elo_mean;

    disp('Calculating regular-season Elo ratings...')

    for g = 2:size(G,1) % for each game

        % Note: the Elo ratings in row 1 reflect Elo ratings AFTER the game
        % in row 1 of G has been played, and so on

        %% Look up Elo ratings for each team

        % Look up team indices
        for t = 2:3
            i = 1;
            while ~strcmp(T{i,22},G{g,t})
                i = i+1;
            end
            ti(t-1) = i;
        end

        % Source: https://en.wikipedia.org/wiki/Elo_rating_system#Mathematical_details

        % Prior ratings
        R_ = R(g-1,ti);

        % Expected scores
        E(1) = 1/(1+10^((R_(2)-R_(1))/400));
        E(2) = 1/(1+10^((R_(1)-R_(2))/400));

        % A loss is scored as 0, win as 1

        % Actual scores
        switch G{g,4} % the game result
            case 'W'
                S = [1 0];
            case 'L'
                S = [0 1];
            otherwise
                G(g,:)
                error('Game outcome not recognized')
        end

        % Update scores
        for i = 1:2
            R(g,ti(i)) = R(g-1,ti(i)) + K*(S(i)-E(i));
        end

        % Propagate forward all other scores that were not updated
        for i = 1:size(R,2)
            if isnan(R(g,i))
                R(g,i) = R(g-1,i);
            end
        end

    end

    % Strip padded headers
    G(1,:) = [];
    R(1,:) = [];
    
    %% Extract day-by-day summary of Elo ratings

    
    ild = zeros(size(G,1),1); % is last day flag
    for i = 2:size(G,1)
        if G{i,5} ~= G{i-1,5}
            ild(i-1) = 1;
        end
    end
    ild(end) = 1;
    
    R_dbd = R(logical(ild),:);
    dates = cell2mat(G(logical(ild),5));
    
    %% Plot results
    
    % Merge team names with day-by-day Elo for plotting
    T_R = [T(:,22)'; num2cell(R_dbd)];
    T_R = T_R'; % transpose to use sortrows commands
    T_R = sortrows(T_R,-size(T_R,2));
    
    %%  All teams
    figure(1)
    clf
    hold on
    set(gcf,'color','white')
    
    cols = [ % Source: https://sashat.me/2017/01/11/list-of-20-simple-distinct-colors/
                230, 25, 75
                60, 180, 75
                255, 225, 25
                0, 130, 200
                245, 130, 48
                145, 30, 180
                70, 240, 240
                240, 50, 230
                210, 245, 60
                250, 190, 190
                0, 128, 128
                230, 190, 255
                170, 110, 40
%                 255, 250, 200
                128, 0, 0
                170, 255, 195
                128, 128, 0
%                 255, 215, 180
                0, 0, 128
                128, 128, 128
%                 255, 255, 255
                0, 0, 0
           ]/255;
    
    % Pull out a select number of lines to highlight
    li = zeros(1,size(T_R,1)); % label indices
    tn = linspace(0,1,stf); % normalized rating targets
    R_n = [T_R{:,end}]; % ratings, normalized
    R_n = (R_n - min(R_n))/(max(R_n)-min(R_n)); % normalize on 0-1
    for i = 1:stf
        [~, ind] = min(abs(R_n-tn(i)));
        li(ind) = 1;
    end
    
    % Plot non-highlighted lines first
    for t = 1:size(T_R,1) % for each team
        if ~li(t)
            plot(dates,cell2mat(T_R(t,2:end)),'Color',0.7 + zeros(1,3),'LineWidth',0.1)
        end
    end
    
    % Plot highlighted lines second
    ci = 1; % color index
    for t = 1:size(T_R,1) % for each team
        if li(t)
            plot(dates,cell2mat(T_R(t,2:end)),'Color',cols(ci,:),'LineWidth',3)
            text(dates(end),T_R{t,end},[ts T_R{t,1}],'fontsize',8,'horizontalalignment','left','verticalalignment','middle')
            ci = ci+1;
        end
    end
    
    datetick('x', 'yyyy-mm-dd')
    axis([G{1,5} G{end,5} min(R(:)) max(R(:))])
    grid on
    ylabel('Elo rating')
    title({
            'Elo Ratings, NCAA Men''s Basketball, 2017-2018 Season'
            ['\rm\fontsize{10}Elo K: ' num2str(K) ', Mean: ' num2str(elo_mean) '; Team Count: ' num2str(size(T_R,1)) '; Source: Sports-Reference']
          });

    resize_figure
    drawnow
      
    %% Top teams
    
%     figure(2)
%     clf
%     hold on
%     set(gcf,'color','white')
%     for i = 1:top_plot % for each team
%         y = cell2mat(T_R(i,2:end));
%         plot(dates,y,'k','LineWidth',0.1)
%         text(dates(end),y(end),[ts T_R{i,1}],'fontsize',8,'horizontalalignment','left','verticalalignment','middle')
%     end
%     datetick('x', 'yyyy-mm-dd')
%     yl = ylim;
%     axis([G{1,5} G{end,5} yl(1) max(R(:))])
%     grid on
%     ylabel('Elo rating')
%     title({
%             ['Elo ratings of top ' num2str(top_plot) ' D1 NCAA men''s basketball teams, 2017-2018 season']
%             ['\rm\fontsize{10}Elo K: ' num2str(K) ', Mean: ' num2str(elo_av) '; Team Count: ' num2str(size(T_R,1)) '; Source: Sports-Reference']
%           });
%       
%     resize_figure
%     drawnow
    
    %% Output results
    
    disp('All teams sorted by regular-season Elo:')
    disp(' ')
    for i = 1:size(T_R,1)
        disp([num2str(i) '. ' T_R{i,1} ': ' num2str(T_R{i,end}) ])
    end
    disp(' ')
    

    % Show best season-end Elo scores
    
    top_N = 25; % number of top teams to show
    E = cell2mat(T_R(1:top_N,end));
    E = flipud(E); % put best teams at top instead of bottom
    
    figure(5)
    clf
    set(gcf,'color','white')
    barh(E,0.8,'FaceColor',0.8+zeros(1,3),'EdgeColor','flat')
    set(gca,'YTick',[])
    
    % Show bar graph of top teams in terms of Elo
    fntsz = 10; % font size
    vo = 0.1;
    for i = 1:top_N
       
        text(0, top_N-i+1+vo, [' ' num2str(i) ': ' T_R{i,1}],'fontsize',fntsz,'verticalalignment','middle')
        text(T_R{i,end}, top_N-i+1+vo, [num2str(round(T_R{i,end})) ' '],'fontsize',fntsz,'verticalalignment','middle','horizontalalignment','right')
        
    end
    title({['Elo Ratings of Top ' num2str(top_N) ' Teams, Regular Season']
            ['\rm\fontsize{10}Elo mean: ' num2str(elo_mean) ', K: ' num2str(K)]
          })
    axis([0 max(E)*1.05 -0.2000 26.2000])
    set(gcf,'position',[200 200 500 600])
    
    R = R_dbd;
    save('ratings_regular_season','R')
    
    %% ==============================================
    %% Supporting functions below
    %% ==============================================
    
    function resize_figure
        
        set(gcf,'position',[100 100 fs])
        
        pos = get(gca,'position'); % shift figure left to give more room for text labels
        set(gca,'position',[pos(1)-0.05 pos(2:4)])
        
    end

end



















































