classdef Instruction
    properties
        Number
        Name
        Dest
        Dest_Index
        S1
        S1_Index
        S2
        S2_Index
        RSI
        LBI
        SBI
    end
    methods        
        function obj = Instruction(number,name,dest,dest_index,s1,s1_index,s2,s2_index,rsi,lbi,sbi)
            obj.Number = number;
            obj.Name = name;
            obj.Dest = dest;
            obj.Dest_Index = dest_index;
            obj.S1 = s1;
            obj.S1_Index = s1_index;
            obj.S2 = s2;
            obj.S2_Index = s2_index;
            obj.RSI = rsi;
            obj.LBI = lbi;
            obj.SBI = sbi;
        end
    end
end