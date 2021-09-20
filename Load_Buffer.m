classdef Load_Buffer
    properties
        Assoc(1,:)
        Time
        RemTime
        Name
        Busy
        Address
        RS
    end
    methods        
        function obj = Load_Buffer(assoc,time,remtime,name,busy,address,rs)
            obj.Assoc = assoc;
            obj.Time = time;
            obj.RemTime = remtime;
            obj.Name = name;
            obj.Busy = busy;
            obj.Address = address;
            obj.RS = rs;
        end
    end
end