classdef sender < communicator
    % parent class for Alice and Bob
    properties
        %rectilinear basis and diagonal basis angles
        basis = [['-','|'] ; ['/','\']]
        %data bits
        data = [];
    end
    methods
        %calculate and return sifted key
        function [key] = siftedKey(obj, Alice_bases, Bob_bases)
            key = obj.data(find(Alice_bases==Bob_bases));
        end
    end
end