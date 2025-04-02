classdef communicator < handle
    properties
        permutations = {}
        clifford_gates = {}
        block_size = 0
        sign_size = 0
        functions = functionsContainer;
    end
    methods
        %Seeds the communicators random number generator
        function setSeed(obj, seed)
            rng(seed)
        end
        function setBlockSize(obj, n)
            obj.block_size = n;
        end
        function setSignSize(obj, l)
            obj.sign_size = l;
        end
    end
end