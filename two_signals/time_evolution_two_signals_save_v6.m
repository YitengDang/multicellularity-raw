% Runs multiple simulations of the system with two signalling molecules and saves
% them.
% Parameters can be input by hand, or loaded from a saved simulation file
% with the correct syntax.
% First counts how many simulations to run, based on the number of
% simulation files already present in the specified folder.
% Then, runs the simulations by looping over some given parameter loop, in
% such a way that each parameter set should have the same number of final
% simulations (+-1).

% ----------- Updates ----------------
% v3: use the randomization algorithm to place the cells on a
% different lattice
% v4: inner loop over K12 to keep the number of simulations with given
% parameters more or less constant
% v5: decrease the number of periodicity checks to one every t_check time
% steps
% v6: shortened loop over simulations by defining a function for each run
close all
clear all
%% Simulation parameters
% variable to loop over
%p_all = 0:0.1:1; % loop variable (to be specified below)
%noise_all = [0 0.01 0.05 0.1 0.5];
%I_all = -0.1:0.1:0.4;
N_all = [1:7].^2;
% K12_all = 5;

% number of simulations to do 
sim_count = 500;

% other settings
%InitiateI = 0; % generate lattice with input I?
%tmax = 10^5; % max. number of time steps 

% folder to save simulations in
%save_folder = 'L:\BN\HY\Shared\Yiteng\two_signals\travelling_wave_analysis\vs_noise\K12_9';
%save_folder = 'N:\tnw\BN\HY\Shared\Yiteng\two_signals\travelling_wave_analysis\vs_noise\K12_9';
parent_folder = 'N:\tnw\BN\HY\Shared\Yiteng\two_signals\trav_wave_vs_N';
%parent_folder = 'N:\tnw\BN\HY\Shared\Yiteng\two_signals\sweep K12 new lattice\sensitivity_init_cond';
%subfolder = sprintf('K12_%d', K12_all);
%save_folder = fullfile(parent_folder, subfolder);
  
% default file name
sim_ID = 'two_signal_mult';

%% System parameters
%
% lattice parameters
%gz = 15;
%N = gz^2;

% (1) Specify parameters by hand 
a0 = 1.5;
M_int = [0 1; -1 1];
K = [0 10; 11 4];
Con = [18 16];
Coff = [1 1];
hill = Inf;
noise = 0;
rcell = 0.2;
%cells = cells_hist{1};
lambda12 = 1.2;
lambda = [1 lambda12];
p0 = [Inf Inf]; %[0.5 0.5];
I0 = [0 0];
Rcell = rcell*a0;

% get pos, dist
%nodisplay = 1;
mcsteps = 0;
%[positions, distances] = initial_cells_random_markov_periodic(gz, mcsteps, rcell);

% Settings
InitiateI = 0;
mcsteps = 0;
tmax = 10^4; % cut off simulation if t > tmax
cells_ini = []; % [] : random initial conditions
%}
%% (2) Load parameters from saved trajectory
%{
% with parameters saved as structure array 
% load data
data_folder = 'H:\My Documents\Multicellular automaton\app\data\time_evolution\travelling waves';
%file = 'two_signal_mult_M_int0_1_-1_1_long_t_trans_wave_to_period10_trav_wave-v1';
%file = 'two_signal_mult_M_int0_1_-1_1_transient_wave_to_travelling_wave-v1';
%file = 'two_signal_mult_N225_initiateI1_I_ini_0p50_0p50_t_out_2436_period_15-v1';
file = 'two_signal_mult_M_int0_1_-1_1_hillInf_N225_a0_1p50_K0p0_22p0_11p0_4p0_Con18p0_16p0_Coff1p0_1p0-v1';
%[file, data_folder] = uigetfile(fullfile(data_folder, '\*.mat'), 'Load saved simulation');
load(fullfile(data_folder, file));

s = save_consts_struct;
N = s.N;
a0 = s.a0;
K = s.K;
Con = s.Con;
Coff = s.Coff;
M_int = s.M_int;
hill = s.hill;
noise = s.noise;
rcell = s.rcell;
%cells = cells_hist{1};
lambda12 = s.lambda12;
lambda = [1 lambda12];
mcsteps = str2double(s.mcsteps);

p0 = s.p_ini;
%tmax =  s.tmax;
gz = sqrt(N);
Rcell = rcell*a0;
cell_type = zeros(N,1);

% Initial I
%
InitiateI = 0;
I0 = [0 0];
s_fields = fieldnames(s);
for i=1:numel(s_fields)
    if strcmp(s_fields{i},'I_ini_str')
        if ~isempty(s.I_ini_str)
            I0 = s.I_ini;
            InitiateI = 1;
        end
    end
end
%

I_ini_str = '';
if InitiateI
    I_ini_str = sprintf('_I_ini_%.2f_%.2f', I0(1), I0(2));
end
%}

%% Loop over N
%for ii=1:numel(N_all)
    %N = N_all(ii);
    %subfolder = sprintf('N%d', N);
    %save_folder = fullfile(parent_folder, subfolder);

    %% First, calculate how many simulations are needed 
    %sim_to_do = zeros(numel(noise_all), 1);
    % sim_to_do = zeros(numel(loopvar_all), 1);
    %sim_to_do = zeros(numel(noise_all));
    %sim_to_do = zeros(numel(I_all));
    sim_to_do = zeros(numel(N_all));

    for idx_loop=1:numel(N_all) %numel(K12_all)
        %p0 = [p_all(idx1) p_all(idx2)];
        %noise = noise_all(idx1);
        %hill = loopvar_all(inner_idx);
        %I0 = [I_all(idx1) I_all(idx2)];
        N = N_all(idx_loop);   
        %K(1,2) = K12_all(idx_loop);
        
        % Count how many simulations have already been done
        %subfolder = strrep(sprintf('N%d strong int a0 %.1f', N, a0), '.', 'p');
        %subfolder = strrep(sprintf('ini_p1_%.2f_p2_%.2f', p0(1), p0(2)), '.', 'p');
        %folder = fullfile('L:\HY\Shared\Yiteng\two_signals\parameter set 2b', sprintf('N%d', N));
        %folder = fullfile('L:\HY\Shared\Yiteng\two_signals', 'sweep K22 new lattice', subfolder);
        %folder = 'L:\BN\HY\Shared\Yiteng\two_signals\travelling_wave_analysis\vs_Hill';
        %parent_folder = 'L:\BN\HY\Shared\Yiteng\two_signals\travelling_wave_analysis\vs_noise\K12_9';
        %parent_folder = 'L:\BN\HY\Shared\Yiteng\two_signals\travelling_wave_analysis\vs_p0_set2';
        subfolder = sprintf('N%d', N);
        save_folder = fullfile(parent_folder, subfolder);
        
        % subfolder
        folder = save_folder;
        if exist(folder, 'dir') ~= 7
            mkdir(folder);
        end
        %}
        if exist(folder, 'dir') ~= 7
            warning('Folder does not exist! ');
            break
        end

        % Filename pattern
        %pattern = strrep(sprintf('%s_N%d_initiateI%d%s_noise_%.2f_t_out_%s_period_%s%s-v%s',...
        %        sim_ID, N, InitiateI, I_ini_str, noise,...
        %        '(\d+)', '(\d+|Inf)', '\w*', '(\d+)'), '.', 'p');
        %pattern = strrep(sprintf('%s_N%d_p1_%.2f_p2_%.2f_K12_%d_t_out_%s_period_%s-v%s',...
        %        sim_ID, N, p0(1), p0(2), K(1,2), '(\d+)', '(\d+|Inf)',...
        %        '(\d+)'), '.', 'p');
        %pattern = strrep(sprintf('%s_N%d_t_out_%s_period_%s-v%s',...
        %        sim_ID, N, '(\d+)', '(\d+|Inf)', '(\d+)'), '.', 'p');
        pattern = strrep(sprintf('%s_N%d_t_out_%s_period_%s-v%s',...
                sim_ID, N, '(\d+)', '(\d+|Inf)', '(\d+)'), '.', 'p');

        listing = dir(folder);
        num_files = numel(listing)-2;
        names = {};
        filecount = 0;
        for i = 1:num_files
            filename = listing(i+2).name;
            % remove extension and do not include txt files
            [~,name,ext] = fileparts(filename);
            if strcmp(ext, '.mat')
                match = regexp(name, pattern, 'match');
                %disp(match);
                if ~isempty(match)
                    filecount = filecount + 1;
                    names{end+1} = name;
                end
            end
        end

        fprintf('N=%d, noise = %.2f sim to do: %d \n', N, noise, sim_count-filecount);
        %fprintf('N=%d, p0 = [%.1f %.1f], sim to do: %d \n', N, p0(1), p0(2), max_trials-filecount);

        sim_to_do(idx_loop) = sim_count-filecount;
    end

    %% Then, do the simulations
    for trial=1:sim_count
        for idx_loop=1:numel(N_all)
            N = N_all(idx_loop);
            
            subfolder = sprintf('N%d', N);
            save_folder = fullfile(parent_folder, subfolder);
            %for idx2=1:numel(I_all)
                %noise = noise_all(idx1);
                %hill = p_all(idx1);
                %p0 = [p_all(idx1) p_all(idx2)];
                %I0 = [I_all(idx_loop) I_all(idx2)];
                %N = N_all(idx_loop);
                
                fprintf('N %d, trial %d \n', N, trial);
                %fprintf('trial %d, N %d, I0 = [%.2f %.2f] \n', trial, N, I0(1), I0(2));
                %fprintf('trial %d, N %d, noise %.2f \n', trial, N, noise);
                %fprintf('trial %d, N %d, p0 = [%.1f %.1f] \n', trial, N, p0(1), p0(2));

                % skip simulation if enough simulations have been done
                if trial > sim_to_do(idx_loop)
                    disp('continue');
                    continue;
                end
                
                [positions, distances] = initial_cells_random_markov_periodic(...
                    sqrt(N), mcsteps, rcell);
                
                fname_str_template = sprintf('two_signal_mult_N%d', N);
                display_fig = 0;
                % ----------- simulation ------------------------------------
                [cells_hist, period, t_onset] = time_evolution_save_func_efficient_checks(...
                    N, a0, Rcell, lambda, hill, noise, M_int, K, Con, Coff,...
                    distances, positions, sim_ID, mcsteps, InitiateI, p0, I0, cells_ini, tmax,...
                    save_folder, fname_str_template, display_fig);
                %--------------------------------------------------------------------------
                %}
            %end
        end
    end
%end