classdef Function_Unit
    properties
        Assoc(1,:)
        Time
        RemTime
        Name
        Busy
        Op
        Dest
        S1
        S2
        FU1
        FU2
        Av1
        Av2
    end
    methods        
        function obj = Function_Unit(assoc,time,remtime,name,busy,op,dest,s1,s2,fu1,fu2,av1,av2)
            obj.Assoc = assoc;
            obj.Time = time;
            obj.RemTime = remtime;
            obj.Name = name;
            obj.Busy = busy;
            obj.Op = op;
            obj.Dest = dest;
            obj.S1 = s1;
            obj.S2 = s2;
            obj.FU1 = fu1;
            obj.FU2 = fu2;
            obj.Av1 = av1;
            obj.Av2 = av2;
        end
    end
end