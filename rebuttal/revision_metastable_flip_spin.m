%% Check whether a metastable state is at a local minimum or not
clear all
close all

% Parameters
gridsize = 11;
N = gridsize^2;
a0 = 1.5;
Rcell = 0.2*a0;
K = 10;
Con = 21;

% initial conditions
p0 = 0.7;
iniON = round(p0*N);

% use hexagonal lattice
[dist, pos] = init_dist_hex(gridsize, gridsize);
dist_vec = a0*dist(1,:);
r = dist_vec(dist_vec>0); % exclude self influence
fN = sum(sinh(Rcell)*sum(exp(Rcell-r)./r)); % calculate signaling strength

% generate cell_type (0 case type 1, 1 case type 2)
cell_type = zeros(N,1); % all the same here

% Load data
fname_str = 'dynamics_N121_n85_neq_98_a0_15_K_10_Son_21_t_5';
fname = fullfile(pwd, 'rebuttal', 'single_cell_h', 'activation_metastable', fname_str);
load(fname, 'cells', 'h', 't');

%% Flip individual cells and change in h
cells_final = cells; %store final config. for later use
h_old = h(end); %hamiltonian of stable config.
delh = zeros(N, 1); % change in h due to flipping 1 cell
change_list = zeros(N,1); % dynamics changed?
%cells_flipped = {};
for i=1:N
    cells(i) = ~cells(i);
    [~, changed, h_flipped, ~] = update_cells(cells, dist, Con, K, a0, Rcell);
    %cells_flipped{end+1} = cells_out;
    change_list(i) = changed;
    delh(i) = h_flipped - h_old;
    cells(i) = ~cells(i); %change back
end

% histogram of changes in h
h3=figure();
histogram(delh, -40:5:40, 'Normalization', 'count');
xlabel('\Deltah');
%ylabel('P(\Delta h)');
ylabel('count');
set(gca,'FontSize', 24);

qsave = 1;
if qsave
    fname_str = sprintf('delh_flip_spin_N%d_n%d_neq_%d_a0_%d_K_%d_Con_%d_t_%d',...
        N, iniON, sum(cells_final), 10*a0, K, Con, t);
    fname = fullfile(pwd, 'rebuttal', 'single_cell_h', fname_str);
    save_figure_pdf(h3, 10, 8, fname);
end
%%
i=7;
cells(i) = ~cells(i);
[cells_out, changed, h_flipped, h_list] = update_cells(cells, dist, Con, K, a0, Rcell);
cells(i) = ~cells(i);

figure();
scatter(h_traj(:, end), h_list);

%% Get trajectories of single flips
for i=1:N
    %if change_list(i)
        disp(i)

        %hin = figure();
        cells = cells_final;
        cells(i) = ~cells(i);
        t = 0;
        I = [];
        Non = [];
        hvals = [];
        cells_hist = {};
        hlist_all = {};
        
        % store initial values
        Non(end+1) = sum(cells);
        I(end+1) = moranI(cells, a0*dist);
        cells_hist{end+1} = cells;
        [cells_out, changed, hvals(end+1), hlist] = update_cells(cells, dist, Con, K, a0, Rcell);
        hlist_all{end+1} = hlist;
        while changed
            t = t+1;
            %k = waitforbuttonpress;
            %update_cell_figure(hin, pos, a0, cells_out, cell_type, t);
            cells_hist{end+1} = cells_out;
            I(end+1) = moranI(cells_out, a0*dist);
            Non(end+1) = sum(cells_out);
            cells = cells_out;
            [cells_out, changed, hvals(end+1)] = update_cells(cells, dist, Con, K, a0, Rcell);
        end

        fname_str = sprintf('N%d_n%d_neq_%d_a0%d_K_%d_Con_%d_t_%d', ...
            N, iniON, Non(end), 10*a0, K, Con, t);
        i = 1;
        fname = fullfile(pwd, 'rebuttal', 'trajectories',...
            strcat(fname_str,'-v',int2str(i),'.mat'));
        while exist(fname, 'file') == 2
            i=i+1;
            fname = fullfile(pwd, 'rebuttal', 'trajectories', 'data',...
                strcat(fname_str,'-v',int2str(i),'.mat'));
        end
        
        qsave = 1;
        if qsave
            save(fname)        
        end
    %end
end

%% Plot trajectories in p,I space
% Path to search for the saved data. It searchs by the name, defined by the
% parameters chosen
path = 'H:\My Documents\Multicellular automaton\rebuttal\trajectories\data';
straux = '(\d+)';
fpattern = sprintf('N%d_n%d_neq_%s_a0%d_K_%d_Con_%d_t_%s-v%s', ...
    N, iniON, straux, 10*a0, K, Con, straux, straux);

% Get all file names in the directory
listing = dir(path);
num_files = numel(listing)-2; %first two entries are not useful
count = 0;
for i = 1:num_files
    filename = listing(i+2).name;
    % remove extension and do not include txt files
    [~,name,ext] = fileparts(filename);
    if strcmp(ext, '.mat')
        count = count + 1;
        names{count} = name;
    end
end

% Initialize all variables and figures
h1 = figure(1);
hold on
first = true;
pini = zeros(numel(names),1);
pend = pini;
Iini = pini;
Iend = pini;
hini = pini;
hend = pini;
tend = pini;
for i = 1:numel(names)
    % first get the filename given by the student
    [tokens, ~] = regexp(names{i},fpattern,'tokens','match');
    if numel(tokens) > 0
        disp(names{i}) % displays the file name
        % load the data
        load(fullfile(path,strcat(names{i},'.mat')), 'cells_hist', 'fN', 'I', 'hvals', 't');
        % Get the sequence of p
        p = zeros(numel(cells_hist),1);
        for k = 1:numel(cells_hist)
            p(k) = sum(cells_hist{k})/N;
        end
        figure(h1)
        % plot energy contour before plotting the lines
        if first
            first = false;
            E = @(p, I) -0.5*(Con-1)*(1 + 4*fN.*p.*(1-p).*I + fN*(2*p-1).^2) ...
                -(2*p-1).*(0.5*(Con+1)*(1+fN) - K);
            piv = (0:N)/N;
            Iv = -0.05:0.05:1;
            [p_i,Imesh] = meshgrid(piv, Iv);
            contourf(piv, Iv, E(p_i, Imesh),'LineStyle', 'none')
            colormap('summer')
            c = colorbar;
        end
        theta = 4*I'.*p.*(1-p) + (2*p-1).^2;
        % Plot the line
        plot(p, I, 'Color', 'r')
        % Save the initial and end points for plotting the marks later
        pend(i) = p(end);
        Iend(i) = I(end);
        pini(i) = p(1);
        Iini(i) = I(1);
        hini(i) = hvals(1)/N;
        hend(i) = hvals(end)/N;
        tend(i) = t;
    end
end

% Plot the initial and final points in both figures
figure(h1)
scatter(pend, Iend, 'kx')
scatter(pini, Iini, 'ko')

% Plot the maximum I estimated with first neighbour approx.
figure(h1)
fa0 = sinh(Rcell)*exp(Rcell-a0)/a0;
Imax = @(p) (6 - 4./sqrt(p*N) - 6./(p*N) - 6*p)*fa0./(1-p)/fN;
Imax2 = @(p) (6*p - 4./sqrt((1-p)*N) - 6./((1-p)*N))*fa0./p/fN;
%plot(piv, Imax(piv), 'b')
%plot(piv, max(Imax(piv), Imax2(piv)), '--b', 'Linewidth', 1.5)
ylim([-0.05 1])

% Set fonts and labels of the map
figure(h1)
hold off

set(gca,'FontSize', 20)
xlabel('p', 'FontSize', 24)
ylabel('I', 'FontSize', 24)
ylabel(c, 'h=H/N', 'FontSize', 24)
%ylim([-0.05 0.3])

% save the map
qsave = 1;
if qsave
name = sprintf('N%d_n%d_a0%d_K_%d_Con_%d', ...
    N, iniON, 10*a0, K, Con);
out_file = fullfile(pwd, 'rebuttal', 'trajectories',...
    strcat(name,'_hmap_pI')); %filename
save_figure_pdf(h1, 10, 6, out_file);
end