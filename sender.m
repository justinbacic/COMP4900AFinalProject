classdef sender < communicator
    properties
        
    end
    methods
        function obj = sender()
            obj.stream = RandStream('mt19937ar', 'Seed', 42); % Create independent RNG
            
        end
        function binary_array = messageToBinary(obj, message)
            % Extract the char array from the string
            charArray = char(message);
            % Convert each character to its ASCII value
            asciiValues = double(charArray);
            
            % Convert each ASCII value to 8-bit binary
            binaryStr = dec2bin(asciiValues, 8)';
            
            % Reshape into a single binary string (optional)
            binaryMessage = string(binaryStr(:)');
            binary_array = [];
            while strlength(binaryMessage)>= obj.block_size
                chunk = extractBefore(binaryMessage, obj.block_size+1); % Extracts up to index n
                binaryMessage = extractAfter(binaryMessage, obj.block_size);    % Extracts from index n+1
                binary_array = [binary_array;chunk];
            end
            if strlength(binaryMessage) > 0
                last_chunk = "";
                for i = 1:obj.block_size-strlength(binaryMessage)
                    last_chunk = "0" + last_chunk ;
                end
                last_chunk = binaryMessage+last_chunk;
                binary_array = [binary_array;last_chunk];
            end
        end
        function encrypted_message = encrypt(obj, codeword)
            encrypted_message = {};
            for i = 1:length(codeword)
                cliffordEncrypt = obj.clifford_gates{randi(obj.stream, length(obj.clifford_gates))};
                p = obj.permutations(randi(obj.stream, length(obj.permutations)), :);
                swap_gates = obj.functions.permutationToSwapGates(p);
                gates = [swap_gates; cliffordEncrypt; ];
                C = quantumCircuit(gates);
                s = simulate(C,codeword(i));
                encrypted_message{end+1} = s; 
                %disp(formula(s));
            end
            
        end
    end
end