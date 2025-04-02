classdef sender < communicator
    properties
        
    end
    methods
        function encrypted_message = encrypt(obj, codeword)
            % Define the permutation
            p = randperm(length(codeword)); 
            % Function to generate swap gates
            swapList = obj.functions.permutationToSwapGates(p);
            % Apply the swap gates sequentially
            for i = 1:size(swapList, 1)
                codeword = obj.functions.applySwapGate(codeword, swapList(i).TargetQubits(1), swapList(i).TargetQubits(2));
            end
            encrypted_message = codeword;
        end
    end
end