%nQubits = 4;
%signature_size = 1;
%numCliffords = 1;
%Bob = sender;
%Alice = receiver;
%seed = 2;
%Bob.setSeed(seed);
%Alice.setSeed(seed);
%Bob.makeCliffordGates();
%Alice.makeCliffordGates();
%disp(Bob.clifford_gates);
%disp(Alice.clifford_gates);
%gates = [ Bob.clifford_gates{1}];
%C = quantumCircuit(gates);
%plot(C);
%gates = [ Alice.clifford_gates{1}];
%D = quantumCircuit(gates);
%plot(D);

clear; clc;

% Parameters exactly like in paper
n_values = [2, 3, 4, 5]; % Block sizes
d1_values = [56, 17, 6, 3]; % Clifford operators
ell = 2; % Authentication bits
num_trials = 500; % Number of trials

empirical_collision_probs = zeros(length(n_values),1);
theoretical_collision_probs = zeros(length(n_values),1);

for idx = 1:length(n_values)
    n = n_values(idx);
    d1 = d1_values(idx);
    d2 = factorial(n + ell);

    fprintf('\nTesting with n=%d, d1=%d, d2=%d\n', n, d1, d2);
    
    % Set up sender and receiver explicitly
    Alice = sender();
    Bob = receiver();

    % Configure sender and receiver explicitly
    Alice.setBlockSize(n + ell);
    Alice.setSignSize(ell);
    Alice.num_cliffords = d1;
    Alice.setPermSet();
    Alice.makeCliffordGates();
    
    Bob.setBlockSize(n + ell);
    Bob.setSignSize(ell);
    Bob.num_cliffords = d1;
    Bob.setPermSet();
    Bob.clifford_gates = Alice.clifford_gates;
    
    encrypted_outcomes = [];
    collision_count = 0;

    for trial = 1:num_trials
        random_message = dec2bin(randi([0, 2^(n)-1]), n);
        codeword = Alice.messageToBinary(random_message);
        encrypted_msg = Alice.encrypt(codeword);
        encrypted_signature = strjoin(encrypted_msg, ''); %Need to find valid way to write
        % Check explicitly for collision
        if any(strcmp(encrypted_outcomes, enc_signature))
            collision_count = collision_count + 1;
        else
            encrypted_outcomes = [encrypted_outcomes; enc_signature]; % explicitly add
        end
    end
    % Need to ensure below works
    % Compute explicit empirical collision probability
    collision_counts = cell2mat(values(encrypted_outcomes));
    num_collisions = sum(collision_counts .* (collision_counts - 1) / 2);
    total_pairs = num_trials * (num_trials - 1) / 2;
    empirical_collision_prob = num_collisions / total_pairs;

    empirical_collision_probs(idx) = empirical_collision_prob;

    % Explicit theoretical collision probability calculation
    imax = floor( sqrt( 2^(n+ell) * d1 * d2 ) );
    theoretical_collision_prob = (imax * (imax - 1)) / (2^(n+ell+1) * d1 * d2);
    theoretical_collision_probs(idx) = theoretical_collision_prob;

    fprintf('Empirical Collision Prob: %.4e | Theoretical: %.4e\n', empirical_collision_prob, theoretical_collision_prob);
end

% TODO: Plot explicitly empirical vs theoretical collision probabilities

