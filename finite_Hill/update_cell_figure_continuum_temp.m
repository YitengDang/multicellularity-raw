function update_cell_figure_continuum_temp(hin, pos, a0, cells, cell_type, t, sigmaC)
    % Plot the cell state in a diagram according to their type. If
    % cell_type(i) = 0, the cell is plotted as circle, if 1 it is plotted
    % as square. hin is the figure handle.
    
    % calculate I2 
    p = mean(cells);
    sigma = std(cells);
    
    % clear figure and hold on to keep the graphics
    clf(hin,'reset');
    title(strcat('$$\langle X_i \rangle$$',...
        sprintf('= %.2f, sigma = %.3f, sigmaC = %.3f, Time: %d', p, sigma, sigmaC, t)), ...
        'FontSize', 24, 'Interpreter', 'latex');
    %title(sprintf('Noff = %d, Non =  %d,  Time: %d', sum(~cells), sum(cells), t), ...
    %    'FontSize', 24, 'Interpreter', 'latex');
    set(gca,'YTick',[],'XTick',[]);
    box on
    hold on
    
    % set the diameter of the graphics (unitary)
    diameter = 0.5;
    
    for i = 1:size(pos,1)
        switch cell_type(i)
            case 0
                curv = [1 1];
            otherwise
                curv = [0 0];
        end
        
        % greyscale, cells(i) = Xi indicates greyness
        Xi = cells(i);
        face_clr = [1-Xi 1-Xi 1-Xi];
        
        r = diameter/2;
        position = a0.*[pos(i,1)-r pos(i,2)-r diameter diameter];
        
        % draw the rectangle in the figure with handle hin
        rectangle('Position', position, 'FaceColor', face_clr, ...
            'EdgeColor', 'k', 'Curvature', curv);
    end
    
    % set hold off and draw figure
    hold off
    drawnow;
    
    % set image properties
    h = gcf;
    %set(h,'Units','px');
    set(h, 'Position', [500 300 560 420]);
    
    
        
                
    
    

