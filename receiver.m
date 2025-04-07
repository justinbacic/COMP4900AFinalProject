classdef receiver < communicator
    properties
        
    end
    methods
        %function obj = receiver()
        %    obj.stream = RandStream('mt19937ar', 'Seed', 42); % Create independent RNG
        %end
        function obj = receiver(seed,n,l,d1)
            %Seeds the communicators random number generator
            obj.stream = RandStream('mt19937ar', 'Seed', seed); % Create independent RNG
            obj.setBlockSize(n);
            obj.setSignSize(l);
            obj.num_cliffords = d1;
            obj.setPermSet();
            obj.makeCliffordGates();
        end
        function plain_text = binaryToMessage(obj,binaryMessage)
            str = "";
            for i=1:length(binaryMessage)
                str = str +binaryMessage(i);
            end
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
                %warning('Input truncated by %d bits to match bit grouping.', extraBits);
            end
        
            % Split binary into chunks of 'bitsPerChar' bits
            numChars = length(binaryStr) / bitsPerChar;
            binaryChunks = reshape(binaryStr, bitsPerChar, numChars)';
        
            % Convert each chunk to decimal, then to char
            decimalValues = bin2dec(binaryChunks);
            plain_text = char(decimalValues)';
        end
        function decoded_message = decode(obj,encrypted_message)
            authBits = "";
            for i = 1:obj.sign_size
                authBits = "1" + authBits;
            end
            decoded_message = {};
            for i = 1:length(encrypted_message)
                DecryptedCircuit = obj.functions.decrypt_clifford(obj.clifford_gates{randi(obj.stream, length(obj.clifford_gates))}); 
                cliffordDecrypt = DecryptedCircuit;
                p = obj.permutations(randi(obj.stream, length(obj.permutations)), :);
                swap_gates = obj.functions.permutationToSwapGates(p);
                rev_swap_gates = obj.functions.reverseSwapGates(swap_gates);
                gates = [rev_swap_gates;cliffordDecrypt; ];
                D = quantumCircuit(gates);
                s = simulate(D,encrypted_message{i});
                %disp(randi(10));
                %disp(formula(s));
                %Measurement
                Measured = randsample(s,1).MeasuredStates;
                Measured = char(Measured);
                % Check the authentication bits: they should all be 1s
                authPart = Measured(end - obj.sign_size + 1 : end);
                if ~isequal(authPart, authBits)
                    error('Authentication failed: invalid authentication bits.');
                end
                decoded_message{end + 1} = Measured(1:obj.block_size);
            end
        end
        
    end
end