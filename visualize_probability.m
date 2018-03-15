function visualize_probability
    
    fs = [1500 1200]; % pixels, figure size

    for f = 3:4

        load('probabilities','P','O','pc');
        
        % Un-comment to sort graphs in order of championship probability
        if f == 4
            P = sortrows(P,-7); % sort in order of most likely to win championship
            O = sortrows(O,-7); % sort in order of most likely to win championship
        end

        tl = P(:,1); % team list
        P(:,1) = [];
        P = cell2mat(P);

        figure(f)
        clf
        hold on
        set(gcf','color','white')

        I = zeros(size(P,1),size(P,2),3);
        P_ = P; % make a copy to modify for visualization

        % Scale probabilities in each round to [0 1]
        for r = 1:6 % for each round
            P_(:,r) = P_(:,r) - min(P_(:,r));
            P_(:,r) = P_(:,r) / max(P_(:,r));
        end

        % Generate a custom colormap
        cmap = [
                    50,205,50 % green
                    255 255 255 % white
                    255,100,50 % red
               ]/255;
        res = 25; % number of colors in upscaled colormap
        cmap_ = zeros(res,3); % interpolated colormap
        for cc = 1:3
            for i = 1:res
                cmap_(i,cc) = interp1(linspace(0,1,size(cmap,1)),cmap(:,cc),i/res);
            end
        end

        imagesc(flipud(P_))
        colormap(flipud(cmap_))
    %     colorbar
        axis tight
        axis off

        % Overlay team names and probabilities
        for r = 6:-1:1 % for each round
            for t = 1:size(P,1) % for each team
                if r==1 || r==6
                    text(r-0.5,size(P,1)-t+1.1,['  ' O{t,1} ': ' num2str(round(P(t,r)*100*10)/10) '%' ],'HorizontalAlignment','left','fontsize',9)
                else
                    text(r-0.5,size(P,1)-t+1.1,['  '             num2str(round(P(t,r)*100*10)/10) '%'],'HorizontalAlignment','left','fontsize',9)
                end
            end

            text(r,size(P,1)+1.5,['Round of ' num2str(64/(2^r))],'HorizontalAlignment','center')
            title({
                    'March Madness: probability of reaching...'
                    ['\rm\fontsize{10}Colors reflect round-averaged probabilities after ' num2str(pc) ' Monte Carlo simulations']
                  })

        end

        % Shift figure down a bit to account for subtitles
        pos = get(gca,'title');
        set(pos,'Position',pos.Position + [0 2 0])

        P = sortrows(P,-6); % sort in order of most likely to win championship
        O = sortrows(O,-7); % sort in order of most likely to win championship
        
        pos = get(gcf,'position');
        set(gcf,'position',[100 -100 fs])
        
        drawnow
        
    end
    
    top_N = 10;
    disp(' ')
    disp('Teams sorted by probability of winning championship:')
    disp(' ')
    for i = 1:size(P,1)
        disp([num2str(i) '. ' O{i,1} ': ' num2str(round(P(i,end)*100*100)/100) '%'])
    end

end



















































