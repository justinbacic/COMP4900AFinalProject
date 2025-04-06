clear; clc;

% Parameters as given in your scenario
n_values = [2, 3, 4, 5]; % Block sizes
d1_values = [56, 17, 6, 3]; % Clifford operators
d2_values = [ 56 17 6 3]; % NOT EVEN IMPLEMENTED???
ell = 2; % Authentication bits

% Results storage
empirical_collision_probs = zeros(length(n_values), 1);
theoretical_collision_probs = zeros(length(n_values), 1);

for idx = 1:length(n_values)
    % Set parameters explicitly
    n = n_values(idx);
    d1 = d1_values(idx);
    %d2 = d2_values(idx);
    d2 = factorial(n+1);
    
    % Compute theoretical maximum distinguishable states
    imax = floor(sqrt(2^(n + ell) * d1 * d2));
    num_trials = imax; % explicitly match theoretical scenario
    
    fprintf('Testing n=%d | d1=%d | d2=%d | imax=%d trials\n', n, d1, d2, imax);
    
    % Initialize sender
    Alice = sender();
    Alice.setBlockSize(n);
    Alice.setSignSize(ell);
    Alice.num_cliffords = d1;
    Alice.setPermSet();
    %Alice.num_permutations = d2;
    Alice.makeCliffordGates();
    
    % Generate all possible plaintexts explicitly
    possible_plaintexts = dec2bin(0:(2^n - 1), n);
    num_plaintexts = size(possible_plaintexts, 1);
    
    % Empirical collision tracking
    encrypted_outcomes = {}; % explicit array for storing outcomes
    collision_count = 0;
    
    trials_per_plaintext = ceil(num_trials / num_plaintexts);
    
    for trial = 1:num_trials
        % Cycle through all plaintext messages explicitly
        plaintext_idx = mod(trial - 1, num_plaintexts) + 1;
        plaintext = string(possible_plaintexts(plaintext_idx, :));
        %disp(plaintext)
        % Encrypt explicitly
        encrypted_msg = Alice.encrypt(plaintext);
        
        % Capture explicitly the encrypted quantum state signature
        encrypted_state = encrypted_msg{1}.Amplitudes;
        
        % Explicit collision check
        collision_detected = false;
        for k = 1:length(encrypted_outcomes)
            if isequal(encrypted_state, encrypted_outcomes{k})
                collision_count = collision_count + 1;
                collision_detected = true;
                %disp("Collision!!")
                break;
            end
        end
        
        if ~collision_detected
            encrypted_outcomes{end+1} = encrypted_state;
        end
    end
    
    % Compute empirical collision probability explicitly
    empirical_collision_prob = collision_count / num_trials;
    empirical_collision_probs(idx) = empirical_collision_prob;
    
    % Explicit theoretical collision probability
    theoretical_collision_prob = (imax * (imax - 1)) / (2^(n + ell + 1) * d1 * d2);
    theoretical_collision_probs(idx) = theoretical_collision_prob;
    
    fprintf('Empirical Probability: %.4e | Theoretical Probability: %.4e\n\n', empirical_collision_prob, theoretical_collision_prob);
end

% Explicitly plot empirical vs theoretical probabilities
figure;
semilogy(n_values, empirical_collision_probs, '-ok', 'LineWidth', 2, 'MarkerSize',8);
hold on;
semilogy(n_values, theoretical_collision_probs, '--xr', 'LineWidth', 2, 'MarkerSize',8);
xlabel('Block Size (n)','FontSize',14);
ylabel('Collision Probability','FontSize',14);
title('Empirical vs. Theoretical Collision Probabilities','FontSize',16);
legend('Empirical','Theoretical','Location','southwest');
grid on;