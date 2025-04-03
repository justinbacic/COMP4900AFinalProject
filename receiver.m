classdef receiver < communicator
    % parent class for Alice and Bob
    properties
        
    end
    methods
        function plain_text = binaryToMessage(obj,binaryMessage)
            str = "";
            for i=1:length(binaryMessage)
                str = str +binaryMessage(i);
            end
            disp(str);
            % Converts a binary char array back to a text string
            %
            % Inputs:
            %   binaryStr    - Binary string (e.g., '0100100001100101')
            %   bitsPerChar  - Optional: Number of bits per character (default: 8)
            %
            % Output:
            %   textStr      - Reconstructed string (e.g., 'He')
            binaryStr = char(str);
            bitsPerChar = 8; % Default to ASCII (8 bits)
        
            % Ensure input is a char array of '0's and '1's
            if ~ischar(binaryStr) || any(~ismember(binaryStr, '01'))
                error('Input must be a char array of ''0''s and ''1''s.');
            end
            
            %truncate extra
            if mod(length(binaryStr), bitsPerChar) ~= 0
                extraBits = mod(length(binaryStr), bitsPerChar);
                binaryStr = binaryStr(1:end-extraBits); % Truncate the extra bits
                warning('Input truncated by %d bits to match bit grouping.', extraBits);
            end
        
            % Split binary into chunks of 'bitsPerChar' bits
            numChars = length(binaryStr) / bitsPerChar;
            binaryChunks = reshape(binaryStr, bitsPerChar, numChars)';
        
            % Convert each chunk to decimal, then to char
            decimalValues = bin2dec(binaryChunks);
            plain_text = char(decimalValues)';
        end
        function decoded_message = decode(obj,encrypted_message)
            
            decoded_message = {};
            for i = 1:length(encrypted_message)
                DecryptedCircuit = obj.functions.decrypt_clifford(obj.clifford_gates{1}); 
                cliffordDecrypt = DecryptedCircuit;
                p = obj.permutations(1, :);
                swap_gates = obj.functions.permutationToSwapGates(p);
                rev_swap_gates = obj.functions.reverseSwapGates(swap_gates);
                gates = [cliffordDecrypt; rev_swap_gates;];
                D = quantumCircuit(gates);
                s = simulate(D,encrypted_message{i});
                disp(formula(s));
                %Measurement
                decoded_message{end +1} = randsample(s,1).MeasuredStates;
            end
        end
        
    end
end