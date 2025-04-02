classdef sender < communicator
    properties
        
    end
    methods
        function encrypted_message = encrypt(obj, codeword)
            cliffordEncrypt = obj.clifford_gates{1};
            p = obj.permutations(1, :);
            swap_gates = obj.functions.permutationToSwapGates(p);
            gates = [swap_gates; cliffordEncrypt; ];
            C = quantumCircuit(gates);
            encrypted_message = {};
            for i = 1:length(codeword)
                s = simulate(C,codeword(i));
                encrypted_message{end+1} = s; 
                %disp(formula(s));
            end
            
        end
    end
end