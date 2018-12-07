function [cells_out, changed] = ...
    update_cells_two_signals_multiply_finite_Hill_w_cell_sizes(cells, dist, M_int, a0,...
    Rcell_all, Con, Coff, K, lambda, hill, noise)

% Update cells without noise in a positive feedback loop with infinite hill
% coefficient
N = size(cells, 1);

% Calculate f(rij), taking into account different radii
M1 = ones(size(dist)); % Account for self-influence
M2 = ones(size(dist));
for ii=1:N
    idx = setdiff(1:N, ii);
    M1(ii, idx) = (Rcell_all(idx)./Rcell_all(ii)).*sinh( Rcell_all(ii) )...
        ./(a0*dist(ii, idx)'/lambda(1))...
        .*exp((Rcell_all(idx)-a0*dist(ii, idx)')/lambda(1));
    M2(ii, idx) = (Rcell_all(idx)./Rcell_all(ii)).*sinh( Rcell_all(ii) )...
        ./(a0*dist(ii, idx)'/lambda(2))...
        .*exp((Rcell_all(idx)-a0*dist(ii, idx)')/lambda(2));
end

% Concentration in each cell
C0 = Coff + (Con-Coff).*cells; 

% Reading of each cell
Y1 = M1*C0(:, 1); 
Y2 = M2*C0(:, 2);
Y = [Y1 Y2];

% Add noise to K
K_cells = K.*ones(2, 2, N);
dK = normrnd(0, noise, 2, 2, N);
K_cells = max(K_cells + dK, 1); % do not allow K < 1 = Coff

%%
% Multiplicative interaction
if hill==Inf
    out11 = ((Y1-squeeze(K_cells(1,1,:)))*M_int(1,1) > 0) + (1 - abs(M_int(1,1)));
    out12 = ((Y2-squeeze(K_cells(1,2,:)))*M_int(1,2) > 0) + (1 - abs(M_int(1,2)));
    out21 = ((Y1-squeeze(K_cells(2,1,:)))*M_int(2,1) > 0) + (1 - abs(M_int(2,1)));
    out22 = ((Y2-squeeze(K_cells(2,2,:)))*M_int(2,2) > 0) + (1 - abs(M_int(2,2)));
    X1 = out11.*out12;
    X2 = out21.*out22;
elseif hill > 0
    %fX1 = (Y.^hill.*(1+M_int(1,:))/2 + (K(1,:).^hill.*(1-M_int(1,:))/2))...
    %    ./(K(1,:).^hill+Y.^hill).*abs(M_int(1,:)) + (1-abs(M_int(1,:))).*ones(N,2);
    %fX2 = (Y.^hill.*(1+M_int(2,:))/2 + (K(2,:).^hill.*(1-M_int(2,:))/2))...
    %    ./(K(2,:).^hill+Y.^hill).*abs(M_int(2,:)) + (1-abs(M_int(2,:))).*ones(N,2);
    %fX1 = (Y.^hill.*(1+M_int(1,:))/2 + (squeeze(K_cells(1,:,:))'.^hill.*(1-M_int(1,:))/2))...
    %    ./(squeeze(K_cells(1,:,:))'.^hill+Y.^hill).*abs(M_int(1,:)) + (1-abs(M_int(1,:))).*ones(N,2);
    %fX2 = (Y.^hill.*(1+M_int(2,:))/2 + (squeeze(K_cells(2,:,:))'.^hill.*(1-M_int(2,:))/2))...
    %    ./(squeeze(K_cells(2,:,:))'.^hill+Y.^hill).*abs(M_int(2,:)) + (1-abs(M_int(2,:))).*ones(N,2);
    K_cells_1 = squeeze(K_cells(1,:,:))';
    K_cells_2 = squeeze(K_cells(2,:,:))';
    
    fX1 = 1./( 1 + ...
        ((Y./K_cells_1).*(1-M_int(1,:))/2).^hill + ... % case repression 
        ((K_cells_1./Y).*(1+M_int(1,:))/2).^hill ... % case activation
        ).*abs(M_int(1,:)) + ... 
        (1-abs(M_int(1,:))).*ones(N,2); % case no interaction
    fX2 = 1./( 1 + ...
        ((Y./K_cells_2).*(1-M_int(2,:))/2).^hill + ... % case repression 
        ((K_cells_2./Y).*(1+M_int(2,:))/2).^hill ... % case activation
        ).*abs(M_int(2,:)) + ... 
        (1-abs(M_int(2,:))).*ones(N,2); % case no interaction

    X1 = prod(fX1, 2);
    X2 = prod(fX2, 2);
end

%% output
cells_out = [X1 X2];
% if no connections to a gene, output = input (remains constant)
idx2 = find(sum(abs(M_int), 2)==0); % find channel(s) that don't have any input
cells_out(:, idx2) = cells(:, idx2); % revert to input

changed = ~isequal(cells_out, cells);
%%
% hamiltonian
%hlist = -(2*cells-1).*([Y1 Y2]-K);
%h = sum(hlist);        