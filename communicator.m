classdef communicator < handle
    properties
        permutations = {}
        clifford_gates = {}
        block_size = 3;
        sign_size = 2;
        num_cliffords = 50;
        functions = functionsContainer
        seed = 0;
        stream;
    end
    methods
        function setPermSet(obj)
            obj.permutations = perms(1:obj.block_size);
        end
        %Seeds the communicators random number generator
        function setSeed(obj, seed)
            rng(seed)
            obj.seed = seed;
        end
        function setBlockSize(obj, n)
            obj.block_size = n;
        end
        function setSignSize(obj, l)
            obj.sign_size = l;
        end
        function swapGates = makeSwapGates(obj)
            p=randperm(obj.block_size + obj.sign_size);
            swapGates = obj.functions.permutationToSwapGates(p);
        end
        function makeCliffordGates(obj)
            % Generate a random Clifford circuit
            obj.clifford_gates = obj.functions.generate_unique_cliffords(obj.block_size + obj.sign_size, obj.num_cliffords,randi(obj.stream,10));
        end
        function val = makeRandVal(obj)
            val = randi(obj.stream, 10);
        end
    end
end