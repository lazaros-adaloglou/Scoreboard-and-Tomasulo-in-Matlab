classdef Register  
    properties
        Name 
        Status
        RSI
        LBI
        SBI
    end
    methods        
        function obj = Register(name,status,rsi,lbi,sbi)
            obj.Name = name;
            obj.Status = status;
            obj.RSI = rsi;
            obj.LBI = lbi;
            obj.SBI = sbi;
        end
    end
end