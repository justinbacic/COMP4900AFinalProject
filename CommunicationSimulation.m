% Parameters as given in your scenario
n_values = [2, 3, 4, 5, 6]; % Block sizes
d1_values = [56 17 6 3 3]; % Clifford operators
d2_values = [ factorial(2+2) 17 6 3 3]; % Altered for alternative permutation style
ell = 2; % Authentication bits
empirical_collision_results = {};
trial_count = 20; %set accordingly
inc = 5; %i increment factor

Alice = sender();

for trial = 1:trial_count
    for idx = 1:5
    n = n_values(idx);
    d1 = d1_values(idx);
    d2 = d2_values(idx);
    imax = floor(sqrt(2^(n + ell) * d1 * d2));
    
    fprintf('Testing n=%d | d1=%d | d2=%d | imax=%d trials\n', n, d1, d2, imax);
    Alice.setBlockSize(n);
    Alice.setSignSize(ell);
    Alice.num_cliffords = d1;
    Alice.setPermSet();
    %Alice.num_permutations = d2;
    Alice.makeCliffordGates();
    
    % Generate all possible plaintexts explicitly
    possible_plaintexts = dec2bin(0:(2^n - 1), n);
    num_plaintexts = size(possible_plaintexts, 1);
    i_vals = 1:inc:imax;
    %observed_ratio = zeros(1, imax);
    observed_ratio = zeros(length(i_vals), 1);
    observed_ratio_accum = zeros(length(i_vals), 1);
    for iidx = 1:length(i_vals)
        i = i_vals(iidx);
        collisions = 0;
        encrypted_outcomes = {};
        for j = 1:i
            % Cycle through all plaintext messages explicitly
            plaintext_idx = mod(j - 1, num_plaintexts) + 1;
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
                    collisions = collisions + 1;
                    collision_detected = true;
                    %disp("Collision!!")
                    break;
                end
            end
            if ~collision_detected
                encrypted_outcomes{end+1} = encrypted_state;
            end
        end
        observed_ratio(iidx) = observed_ratio(iidx) + (collisions / i);
        fprintf('Collisions for n=%d | d1=%d | d2=%d | i=%d trials %d\n', n, d1, d2, i, collisions/i)
    end
    averaged_ratio = observed_ratio / trial_count;
    averaged_ratio = averaged_ratio + eps; %to not make log plotting invalid
    empirical_collision_results{idx} = [i_vals(:), averaged_ratio];
    end
end

figure;
hold on;

plot(empirical_collision_results{1}(:,1), empirical_collision_results{1}(:,2), 'x', 'DisplayName', ['n = 2']);
plot(empirical_collision_results{2}(:,1), empirical_collision_results{2}(:,2), 'x', 'DisplayName', ['n = 3']);
plot(empirical_collision_results{3}(:,1), empirical_collision_results{3}(:,2), 'x', 'DisplayName', ['n = 4']);
plot(empirical_collision_results{4}(:,1), empirical_collision_results{4}(:,2), 'x', 'DisplayName', ['n = 5']);
plot(empirical_collision_results{5}(:,1), empirical_collision_results{5}(:,2), 'x', 'DisplayName', ['n = 6']);


xlabel('i');
ylabel('Collision ratio');
set(gca,'YScale','log')
ylim([1e-5 1]);
legend('show');
title('Collision ratio vs. i for different n');
hold off;