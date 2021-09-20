classdef Store_Buffer
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
        function obj = Store_Buffer(assoc,time,remtime,name,busy,address,rs)
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