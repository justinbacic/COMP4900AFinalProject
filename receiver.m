classdef receiver < communicator
    % parent class for Alice and Bob
    properties
        
    end
    methods
        function decoded_message = decode(obj,encrypted_message)
            DecryptedCircuit = obj.functions.decrypt_clifford(obj.clifford_gates{1}); 
            cliffordDecrypt = DecryptedCircuit;
            p = obj.permutations(1, :);
            swap_gates = obj.functions.permutationToSwapGates(p);
            rev_swap_gates = obj.functions.reverseSwapGates(swap_gates);
            gates = [cliffordDecrypt; rev_swap_gates;];
            D = quantumCircuit(gates);
            decoded_message = {}
            for i = 1:length(encrypted_message)
                s = simulate(D,encrypted_message{i});
                decoded_message{end+1} = s;
                disp(formula(s));
            end
        end
    end
end