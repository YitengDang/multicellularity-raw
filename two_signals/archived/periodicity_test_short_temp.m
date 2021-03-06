clear all 
close all
clc
%%
%{
folder = 'L:\BN\HY\Shared\Yiteng\two_signals\sweep K22 new lattice\N625 strong int a0 0p5';
fname_str = 'two_signal_mult_N625_initiateI0_randpos_mcsteps0_K22_16_t_out_100000_period_Inf_tmax_reached_temp-v1';
load(fullfile(folder, fname_str), 'cells_hist');
%}
%%
% (1) Specify parameters by hand 
gz = 15;
N = gz^2;
a0 = 1.5;
K = [0 24; 11 4];
Con = [18 16];
Coff = [1 1];
M_int = [0 1; -1 1];
hill = Inf;
noise = 0;
rcell = 0.2;
%cells = cells_hist{1};
lambda12 = 1.2;
lambda = [1 lambda12];
%p0 = s.p_ini;
p0 = [0.5 0.5];
%tmax =  s.tmax;
%gz = sqrt(N);
Rcell = rcell*a0;

% Settings
InitiateI = 0;
mcsteps = 0;
tmax = 10^5; % cut off simulation if t > tmax

% ----------- simulation ------------------------------------
cells_hist = {};

% generate initial lattice
%[dist, pos] = init_dist_hex(gz, gz);
nodisplay = 1;
[pos, dist] = initial_cells_random_markov_periodic(gz, mcsteps, rcell, nodisplay);

% generate initial state
iniON = round(p0*N);
cells = zeros(N, 2);
for i=1:numel(iniON)
    cells(randperm(N,iniON(i)), i) = 1;
    if InitiateI && hill==Inf
        %fprintf('Generating lattice with I%d(t=0)... \n', i);
        dI = 0.1;
        [cells_temp, test, I_ini] = generate_I_new(cells(:, i), I0(i), I0(i)+dI, dist, a0);
        cells(:,i) = cells_temp;
        %fprintf('Generated initial I%d: %.2f; in range (Y=1/N=0)? %d; \n', i, I_ini, test);
    end
end

% store initial config
cells_hist{end+1} = cells; %{cells(:, 1), cells(:, 2)};

%-------------dynamics-----------------------------------------
t = 0;
period = Inf; %default values
t_onset = Inf; 
[cellsOut, changed] = update_cells_two_signals_multiply_finite_Hill(cells, dist, M_int, a0,...
        Rcell, Con, Coff, K, lambda, hill, noise);
while changed && period==Inf && t<tmax
    %pause(0.2);
    disp(t);
    t = t+1;
    cells = cellsOut;
    cells_hist{end+1} = cells; %{cells(:, 1), cells(:, 2)};
    t_check = 10^3;
    if mod(t,t_check)==0 % check every t_check steps
        [period_ub, t_onset] = periodicity_test_short(cells_hist); 
        % period_ub is upper bound for the period
    end
    %update_cell_figure_continuum(app, pos, dist, a0, cells, app.Time, cell_type, disp_mol, 0);
    [cellsOut, changed] = update_cells_two_signals_multiply_finite_Hill(cells, dist, M_int, a0,...
        Rcell, Con, Coff, K, lambda, hill, noise);
end

% if periodicity found, find `real' period
pause(1);
if period<Inf
    [period, t_onset] = periodicity_test_detailed(cells_hist, t_check, period_ub);
end

t_out = t; % save final time
if changed && t==tmax
    tmax_string = '_tmax_reached';
else
    tmax_string = '';
end
fprintf('t_out = %d, period %d \n', t_out, period);
%% Test simulations from load
fname_str = 'two_signal_mult_N625_initiateI0_randpos_mcsteps0_K22_11_t_out_22754_period_17950_temp-v1';
folder = 'L:\BN\HY\Shared\Yiteng\two_signals\sweep K22 new lattice\N625 strong int a0 0p5';
load(fullfile(folder, fname_str), 'cells_hist');

[period_ub, t_onset] = periodicity_test_short(cells_hist); 
%% 
t_check = 100;
[period, t_onset] = periodicity_test_detailed(cells_hist, t_check, period_ub);
%%
%{
function [period, t_onset] = periodicity_test_short(cells_hist)
% tweak with function to see if it can be sped up
    % tests only if the last state has occured earlier    
    % returns the first found period and the time of onset of the
    % periodicity
    
    % NB works only for data with 1 repeating state. For a final state that
    % has repeated several times, it will return a higher period, which is
    % an integer multiple of the true period.
    t_out = numel(cells_hist) - 1;
    cells_current = cells_hist{end};
    for t=0:t_out-2
        %disp(t);
        cells = cells_hist{t+1};
        eq = cells==cells_current;
        x = find(eq==0, 1);
        if all(all(cells==cells_current))
            period = t_out-t;
            t_onset = t;
            fprintf('t=%d, period %d \n', t_onset, period);
            return
        end
    end
    period = Inf;
    t_onset = Inf;
    %disp('no period found');
end


function [period, t_onset] = periodicity_test_short_orig(cells_hist)
% tweak with function to see if it can be sped up

    % tests only if the last state has occured earlier    
    % returns the first found period and the time of onset of the
    % periodicity
    
    % NB works only for data with 1 repeating state. For a final state that
    % has repeated several times, it will return a higher period, which is
    % an integer multiple of the true period.
    
    t_out = numel(cells_hist) - 1;
    cells_current = cells_hist{end};
    for t=0:t_out-2
        %disp(t);
        cells = cells_hist{t+1};
        eq = cells==cells_current;
        x = find(eq==0, 1);
        if all(all(cells==cells_current))
            period = t_out-t;
            t_onset = t;
            fprintf('t=%d, period %d \n', t_onset, period);
            return
        end
    end
    period = Inf;
    t_onset = Inf;
    %disp('no period found');
end
%}