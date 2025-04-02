classdef functionsContainer
   methods
        % Function to simulate a swap gate for testing
        function swappedWord = applySwapGate(obj,codeword, i, j)
            swappedWord = codeword;
            temp = swappedWord(i);
            swappedWord(i) = swappedWord(j);
            swappedWord(j) = temp;
        end
        
        function reversedSwapGates = reverseSwapGates(obj,swapList)
            reversedSwapGates = flipud(swapList);
        end
        function DecryptedClifford = decrypt_clifford(obj,EncryptedClifford)
            % Reverse the gate order
            DecryptedClifford = flipud(EncryptedClifford);
            % Loop through each gate and modify it if needed
            for i = 1:length(DecryptedClifford)
                gate = DecryptedClifford(i); %Get the current gate
                if strcmp(gate.Type, "s")
                    DecryptedClifford(i) = siGate(gate.TargetQubits);
                end
                % hGate and cxGate remain unchanged
            end
        end
        % function to turn a qubit permutation into a set of transpositions to fit
        % it into the swapGate function
        function swapList = permutationToSwapGates(obj, p)
            n = length(p);
            visited = false(1, n);
            swapList = [];
            for i = 1:n
               if ~visited(i)
                   cycle = [];
                   j = i;
                   while ~visited(j)
                       visited(j) = true;
                       cycle(end+1) = j;
                       j = p(j);
                   end
                   if length(cycle) > 1
                       for k = length(cycle):-1:2
                           newGate = swapGate(cycle(1), cycle(k));
                           swapList = [swapList; newGate];
                       end
                   end
               end
            end
        end
        
        function CliffordSet = generate_unique_cliffords(obj, nQubits, d1,seed)
               rng(seed)
               CliffordSet = cell(1, d1);
              
               for i = 1:d1
                   qc = quantumCircuit(nQubits);
                   newClifford = [];
                   switch nQubits
                       case 2
                           gatecount = 1:randi([2, 3]);
                       case 3
                           gatecount = 1:randi([3, 50]);
                       case 4
                           gatecount = 1:randi([3, 110]);
                       otherwise
                           gatecount = 1:randi([3, 200]);
                   end
                  
                   % Generate random Clifford explicitly
                   for gateIdx = gatecount
                       gateType = randi(3);
                       targetQubit = randi(nQubits);
                       switch gateType
                           case 1, g = hGate(targetQubit);
                           case 2, g = sGate(targetQubit);
                           case 3
                               control = randi(nQubits);
                               while control == targetQubit
                                   control = randi(nQubits);
                               end
                               g = cxGate(control, targetQubit);
                       end
                       newClifford = [newClifford; g];
                   end
                   CliffordSet{i} = newClifford;
               end
            end
   end
end