%% Analyze saved trajectories across a range of parameters
clear all
close all
set(0, 'defaulttextinterpreter', 'tex');

%% Parameters
N = 225;
tmax = 10000;
%mcsteps_all = [0 10 100 1000];

% MC Steps
%{
mcsteps_all = [1 2:2:10 20:20:100 200:200:1000];
save_path_fig = 'H:\My Documents\Multicellular automaton\figures\two_signals\trav_wave_vs_mcsteps'; % folder for saving figures
load_path = 'N:\tnw\BN\HY\Shared\Yiteng\two_signals\randomized lattice'; % folder for loading data
var_all = mcsteps_all;
%}
% Noise
%{
noise_all = [0.01 0.03 0.05 0.1 0.3 0.5 1 3 5 10];
save_path_fig = 'H:\My Documents\Multicellular automaton\figures\two_signals\trav_wave_vs_noise'; % folder for saving data
load_path = 'N:\tnw\BN\HY\Shared\Yiteng\two_signals\trav_wave_with_noise'; % folder for loading data
var_all = noise_all;
%}

network = 15;
num_params = 100;
digits = 3; 

%% Load raw data files
%{
subfolder = sprintf('TW_propagation_network_%d', network);

folder = fullfile(load_path, subfolder);

listing = dir(folder);
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

%% Load data
filecount = zeros(numel(var_all), num_params); 
t_out_all = zeros(numel(var_all), num_params, nruns); % final times
period_all = zeros(numel(var_all), num_params, nruns); % periodicity test
t_onset_all = zeros(numel(var_all), num_params, nruns); 
trav_wave_all = zeros(numel(var_all), num_params, nruns); 
trav_wave_all_2 = zeros(numel(var_all), num_params, nruns); 

% --- Manually set ---
% random posiitons
%{
%pattern = sprintf(...
%    'two_signal_mult_N%d_ini_state_TW_params_%s_mcsteps_%s_t_out_%s_period_%s-v%s',...
%    N, '(\d+)', '(\d+)', '(\d+)', '(\d+|Inf)', '(\d+)'); % '.' = anything
%}
% noise
pattern = sprintf(...
    'two_signal_mult_N%d_ini_state_TW_params_%s_noise_%s_t_out_%s_period_%s-v%s',...
    N, '(\d+)', '(\d+p\d+)', '(\d+)', '(\d+|Inf)', '(\d+)'); % '.' = anything
% --------------------

for i=1:numel(names)
    if isempty(regexp(names{i}, pattern, 'once')) % only load files matching a certain pattern
        continue
    else
        %disp(names{i});
        load( fullfile( folder, strcat(names{i}, '.mat')), 'cells_hist',...
            'save_consts_struct', 'distances', 'period', 't_out', 't_onset');
        
        [tokens, ~] = regexp(names{i}, pattern, 'tokens', 'match');
        
        % --- Manually set ---
        %mcsteps = save_consts_struct.mcsteps;
        %idx = find(mcsteps == mcsteps_all, 1);
        
        noise = save_consts_struct.noise;
        idx = find(noise == noise_all, 1);
        % --------------------
        
        idx2 = str2double(tokens{1}{1});
        %disp(idx2);
        
        if ~isempty(idx)
            filecount(idx, idx2) = filecount(idx, idx2) + 1;
            idx3 = filecount(idx, idx2);
            if idx3>nruns
                % only do up to nruns simulations
                continue
            end
            %disp(idx3);
            disp(names{i});
            
            t_out_all(idx, idx2, idx3) = t_out;
            period_all(idx, idx2, idx3) = period;
            t_onset_all(idx, idx2, idx3) = t_onset;
            
            % test for TW
            a0 = save_consts_struct.a0;
            digits = 3;
            [trav_wave, trav_wave_2] = travelling_wave_test(cells_hist, a0,...
                period, t_out, distances, digits);
            trav_wave_all(idx, idx2, idx3) = trav_wave;
            trav_wave_all_2(idx, idx2, idx3) = trav_wave_2;
        end
        %
    end
end
%}
%% Save the loaded data
%{
subfolder = sprintf('TW_propagation_network_%d', network);
fname_str = sprintf('analyzed_data_%s_nruns_%d_digits_5', subfolder, nruns);

% noise
%{
save_data_path = 'N:\tnw\BN\HY\Shared\Yiteng\two_signals\trav_wave_with_noise';
save( fullfile(save_data_path, strcat(fname_str, '.mat')), 'noise_all',...
    'filecount', 't_out_all', 'period_all', 't_onset_all', 'tmax',...
    'num_params', 'nruns', 'digits', 'trav_wave_all', 'trav_wave_all_2');
%}

% random positions
save_data_path = 'N:\tnw\BN\HY\Shared\Yiteng\two_signals\randomized lattice';
save( fullfile(save_data_path, strcat(fname_str, '.mat')), 'mcsteps_all',...
    'filecount', 't_out_all', 'period_all', 't_onset_all', 'tmax',...
    'num_params', 'nruns', 'digits', 'trav_wave_all', 'trav_wave_all_2');
%}
%% Load the saved data
% noise
%
nruns = 10; %number of runs per parameter set
label = sprintf('TW_propagation_vs_noise_network_%d', network);
fname_str = sprintf('analyzed_data_%s_num_params_%d_nruns_%d_digits_%d',...
    label, num_params, nruns, digits);
save_data_path = 'N:\tnw\BN\HY\Shared\Yiteng\two_signals\trav_wave_with_noise';
load( fullfile(save_data_path, strcat(fname_str, '.mat')), 'noise_all',...
    'filecount', 't_out_all', 'period_all', 't_onset_all', 'tmax',...
    'num_params', 'nruns', 'digits', 'trav_wave_all', 'trav_wave_all_2');
save_path_fig = 'H:\My Documents\Multicellular automaton\figures\two_signals\trav_wave_vs_noise';
%}

% mc steps
%{
nruns = 3; %number of runs per parameter set
label = sprintf('TW_propagation_network_%d', network);
fname_str = sprintf('analyzed_data_%s_nruns_%d_digits_5', label, nruns);
save_data_path = 'N:\tnw\BN\HY\Shared\Yiteng\two_signals\randomized lattice';
load( fullfile(save_data_path, strcat(fname_str, '.mat')), 'mcsteps_all',...
    'filecount', 't_out_all', 'period_all', 't_onset_all', 'tmax',...
    'num_params', 'nruns', 'digits', 'trav_wave_all', 'trav_wave_all_2');
%}
%% Analyze fraction of TWs
%trav_wave_all_mean = sum(sum(trav_wave_all, 3), 2)/(num_params*nruns);
trav_wave_all_2_mean = sum(sum(trav_wave_all_2, 3), 2)/(num_params*nruns);

% rearrange data
%{
trav_wave_all_2_temp = trav_wave_all_2;
trav_wave_all_2(4,:) = trav_wave_all_2_temp(5,:);
trav_wave_all_2(5,:) = trav_wave_all_2_temp(4,:);
noise_all_temp = noise_all;
noise_all(4) = noise_all_temp(5);
noise_all(5) = noise_all_temp(4);
%}
h = figure;
hold on
box on
% noise
%
%x_data = noise_all;
x_data = [10^-4 noise_all];
trav_wave_all_2_mean = [1; trav_wave_all_2_mean]';
%}
% mcsteps
%{
x_data = [10^(-1) mcsteps_all];
trav_wave_all_2_mean = [1; trav_wave_all_2_mean];
%}
plot( x_data, trav_wave_all_2_mean, 'b--', 'LineWidth', 1.5 );
scatter(x_data, trav_wave_all_2_mean, 50, 'b', 'filled');
%xlim([10^(-1) 10^(3)]);

ylim([0 1]);
set(gca, 'XScale', 'log');

% labels (change per case)
%xlabel('Lattice disorder');
%xlabel('Noise $\alpha$');
xlabel('Noise strength');
ylabel('Fraction travelling waves');

% Tick labels
sel_idx = [2 5 8]; % mcsteps
%{
% MC steps
A = {};
A{1} = '0';
tickmarks = [0:3];
A(2:numel(tickmarks)+1) = sprintfc('10^{%d}', tickmarks);
%}
%
% noise
xticks = -4:0;
xtickLabels = cell(1, 5);
xtickLabels{1} = '\infty';
xtickLabels(2:end) = sprintfc('10^{%d}', -3:0 );
%}
%set(gca, 'FontSize', 32, 'XTick', 10.^[-1:3], 'XTickLabels', A);
set(gca, 'FontSize', 32, 'XTick', 10.^xticks, 'XTickLabels', xtickLabels);

qsave = 1;
if qsave
    fname = fullfile(save_path_fig, strcat('analyzed_data_', label,...
        sprintf('_nruns_%d_digits_%d', nruns, digits), '_frac_TW_all_mean_size_12_8_v2'));
    save_figure(h, 10, 8, fname, '.pdf', qsave);
    
    % save data
    y_data = trav_wave_all_2_mean;
    save(fname, 'x_data', 'y_data')
end
%% fraction with period 15
period_15_frac = sum( sum( period_all==15, 3 ), 2)/(num_params*nruns);
period_15_mult_frac = sum( sum( mod(period_all, 15)==0, 3 ), 2)/(num_params*nruns);

h = figure;
hold on
x_data = var_all;

plot( x_data, period_15_frac, 'bo-', 'LineWidth', 1.5  );
plot( x_data, period_15_mult_frac, 'ro-', 'LineWidth', 1.5  );
ylim([0 1]);
set(gca, 'FontSize', 20);
legend({'T=15', 'mod(T,15)=0'}, 'Location', 'sw');
set(gca, 'XScale', 'log');

% labels (change per case)
xlabel('MC steps');
%xlabel('Noise $\alpha$');
ylabel('Fraction period 15');

% Tick labels
sel_idx = [1 6 11 16];
A = sprintfc('10^{%d}', log10(x_data(sel_idx)) );
%{
A = cell( numel(mcsteps_all), 1 );
A{1} = '0';
A(2:end) = sprintfc('%d', mcsteps_all(2:end) );
%}
set(gca, 'FontSize', 20, 'XTick', x_data(sel_idx), 'XTickLabels', A);

qsave = 0;
if qsave
    fname = fullfile(save_path_fig, strcat('analyzed_data_', label,...
        sprintf('_nruns_%d_digits_%d', nruns, digits), '_frac_period_15'));
    save_figure(h, 10, 8, fname, '.pdf', qsave);
end
%% Analyze t_out
% (1) <t_out>
%t_out_mean = mean(t_out_all, 3);

% (2) # trajectories reaching tmax
t_max_reached = (t_out_all == tmax);
t_max_count = sum(sum(t_max_reached, 3), 2);

h2 = figure;
x_data = var_all; 

plot( x_data, t_max_count/(num_params*nruns), 'bo-', 'LineWidth', 1.5  );
set(gca, 'FontSize', 20);
ylim([0 1]);
set(gca, 'XScale', 'log');

xlabel('MC steps');
%xlabel('Noise $\alpha$');
ylabel('Fraction reaching $t_{max}$');
title(sprintf('$t_{max}=10^{%d}$', log10(tmax)));

%imagesc(p1, p2, t_max_count/nruns);
%set(gca, 'YDir', 'Normal');
%c = colorbar;
%caxis([0 1]);
%colormap('parula');
%xlabel('$$p_1$$')
%ylabel('$$p_2$$')
%ylabel(c, 'fraction');

% Tick labels
sel_idx = [1 6 11 16];
A = sprintfc('10^{%d}', log10(x_data(sel_idx)) );
%{
A = cell( numel(mcsteps_all), 1 );
A{1} = '0';
A(2:end) = sprintfc('%d', mcsteps_all(2:end) );
%}
set(gca, 'FontSize', 20, 'XTick', x_data(sel_idx), 'XTickLabels', A);

qsave = 0;
if qsave
    fname = fullfile(save_path_fig, strcat('analyzed_data_', label,...
        sprintf('_nruns_%d_digits_%d', nruns, digits), '_frac_reaching_tmax'));
    save_figure(h2, 10, 8, fname, '.pdf', qsave);
end
%% TW detection algorithm test
%{
folder = 'N:\tnw\BN\HY\Shared\Yiteng\two_signals\randomized lattice\TW_formation_network_15';
fname_str = 'two_signal_mult_N225_ini_state_rand_params_29_mcsteps_0_t_out_2707_period_225-v1';

fname = fullfile(folder, fname_str);
load(fname, 'cells_hist', 'save_consts_struct', 'distances', 'period', 't_out');

a0 = save_consts_struct.a0;
digits = 3;
[trav_wave, trav_wave_2] = travelling_wave_test(cells_hist, a0,...
    period, t_out, distances, digits);
%}
%%
% (3) <t_out> over trajectories that do not reach t_max
%{
t_out_mean_2 = zeros( numel(mcsteps_all), 1 );
for i=1:numel(t_out_all)
    if ~t_max_reached(i)
        [i1,i2,i3] = ind2sub(size(t_out_all), i); 
        t_out_mean_2(i1, i2) = t_out_mean_2(i1, i2) + t_out_all(i1,i2,i3);
    end
end
t_out_mean = t_out_mean_2./(nruns - t_max_count);

h3 = figure(3);

set(gca, 'YDir', 'Normal');
c = colorbar;
xlabel('$$p_1$$')
ylabel('$$p_2$$')
ylabel(c, '$$\langle t_{out} |  t_{out} < t_{max} \rangle$$', ...
    'Interpreter', 'latex', 'FontSize', 20);
set(gca, 'FontSize', 20);
caxis([0 tmax]);
%ylim(c, [0 tmax]);

qsave = 0;
if qsave
    fname = fullfile(save_path_fig, strcat(fname_str, '_mean_t_out_subset'));
    save_figure(h3, 10, 8, fname, '.pdf');
end
%}

%% Analyze periods
%{
% number of chaotic trajectories
n_chaotic = sum((period_all(:)==Inf).*(t_out_all(:) == tmax));

% data
period_data = period_all(period_all~=0);
uniq = unique(period_data);
C = categorical(period_data, uniq);

n_periodic = sum(period_data(:)~=Inf);

% distribution of periods
h4 = figure(4);
histogram(C);
xlabel('Period');
ylabel('Count');
title(sprintf('%d trajectories, %d periodic, %d chaotic',...
    sum(sum(filecount)), n_periodic, n_chaotic));
set(gca, 'FontSize', 20);

qsave = 0;
if qsave
    fname = fullfile(save_path_fig, strcat(fname_str, '_periods_hist_chaotic'));
    save_figure(h4, 10, 8, fname, '.pdf');
end

%% average period (count only found periods)
period_mean = zeros(numel(p1), numel(p2));
period_count = zeros(numel(p1), numel(p2));
for i=1:numel(t_out_all)
    if period_all(i)>0 && period_all(i)<Inf
        [i1,i2,i3] = ind2sub(size(period_all), i); 
        period_count(i1, i2) = period_count(i1, i2) + 1;
        period_mean(i1, i2) = period_mean(i1, i2) + period_all(i1,i2,i3);
    end
end
period_mean = period_mean./period_count;

h5 = figure(5);
imagesc(p1, p2, period_mean);
set(gca, 'YDir', 'Normal');
c = colorbar;
caxis([0 max(uniq(uniq<Inf))])
xlabel('$$p_1$$')
ylabel('$$p_2$$')
ylabel(c, 'Mean period (time steps)', ...
    'Interpreter', 'latex', 'FontSize', 20);
set(gca, 'FontSize', 20);

qsave = 0;
if qsave
    fname = fullfile(save_path_fig, strcat(fname_str, '_mean_period'));
    save_figure(h5, 10, 8, fname, '.pdf');
end
%}