classdef Reservation_Station
    properties
        Assoc(1,:)
        Time
        RemTime
        Name
        Busy
        Op
        VS1
        VS2
        RS1
        RS2
    end
    methods        
        function obj = Reservation_Station(assoc,time,remtime,name,busy,op,vs1,vs2,rs1,rs2)
            obj.Assoc = assoc;
            obj.Time = time;
            obj.RemTime = remtime;
            obj.Name = name;
            obj.Busy = busy;
            obj.Op = op;
            obj.VS1 = vs1;
            obj.VS2 = vs2;
            obj.RS1 = rs1;
            obj.RS2 = rs2;
        end
    end
end