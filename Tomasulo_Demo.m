% Initialization.
format compact;
clc;
clear;
close all;
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

% User Input.
mode = "Tomasulo"; % "tomasulo loop" %When I dont have eg an Integer RS for exemple for subi and then branch, then those instructions wont enter the tomasulo, and i cant issue for 2 clocks.
Program = ["LD" "F6" "34+" "R2" 1; % Columns: 1 = Instruction. 2 = Destination Register. 3 and 4 = Numbers, Source Registers.
           "LD" "F2" "45+" "R3" 1; % WRITE STORE INSTRUCTIONS WITH SWAPPED REGISTERS!!!!
           "MULTD" "F0" "F2" "F4" 10;
           "SUBD" "F8" "F6" "F2" 2;
           "DIVD" "F10" "F0" "F6" 40;
           "ADDD" "F6" "F8" "F2" 2];
Max_F_Register_Index = 10; % Max Index of F Registers in Program.
R_Register_Indexes = [2 3]; % R Registers to use.
Reservation_Stations_List = ["Add1"; % Names of Reservation Stations and their Execution times.
                             "Add2";
                             "Add3";
                             "Mult1";
                             "Mult2"]; 
Reservation_Stations_Associations = ["ADDD" "SUBD" "ADDD"; % 3 columns and every instruction that can execute in a Reservation Station must be mentioned at least once.
                                     "ADDD" "SUBD" "ADDD";
                                     "ADDD" "SUBD" "ADDD";
                                     "MULTD" "DIVD" "DIVD";
                                     "MULTD" "DIVD" "DIVD"];
Load_Buffers_List = ["Load1"; % Names of Load Buffers and their Load times.
                     "Load2";
                     "Load3"];
Load_Buffers_Associations = ["LD" "LD" "LD"; % 3 columns and every instruction that can execute in a Load Buffer must be mentioned at least once.
                             "LD" "LD" "LD";
                             "LD" "LD" "LD"];
Store_Buffers_List = ["Store1";
                      "Store2";
                      "Store3";]; % Names of Store Buffers and their Write times.
Store_Buffers_Associations = ["SD" "SD" "SD";
                              "SD" "SD" "SD";
                              "SD" "SD" "SD"]; % 3 columns and every instruction that can execute in a Store Buffer must be mentioned at least once.
                          
%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% Reservation Stations Creation
si = size(Program,1);
srs = size(Reservation_Stations_List,1);
Reservation_Stations = Reservation_Station.empty(srs,0);
for i = 1:srs
    Reservation_Stations(i) = Reservation_Station(Reservation_Stations_Associations(i,:),0,0,Reservation_Stations_List(i,1),"No","Empty","Empty","Empty","Empty","Empty");
end

% Load Buffers Creation
sl = size(Load_Buffers_List,1);
Load_Buffers = Load_Buffer.empty(sl,0);
for i = 1:sl
    Load_Buffers(i) = Load_Buffer(Load_Buffers_Associations(i,:),0,0,Load_Buffers_List(i,1),"No","Empty","Empty");
end

% Store Buffers Creation
ss = size(Store_Buffers_List,1);
Store_Buffers = Store_Buffer.empty(ss,0);
for i = 1:ss
    Store_Buffers(i) = Store_Buffer(Store_Buffers_Associations(i,:),0,0,Store_Buffers_List(i,1),"No","Empty","Empty");
end

% F Registers Creation
F_Registers = Register.empty(1+Max_F_Register_Index/2,0);
r = 1;
for i = 1:2:Max_F_Register_Index+1
    F_Registers(r) = Register("F"+int2str(i-1),"Empty",0,0,0);
    r = r+1;
end

% R Registers Creation
srr = size(R_Register_Indexes,2);
R_Registers = Register.empty(srr,0);
for i = 1:srr
    R_Registers(i) = Register("R"+int2str(R_Register_Indexes(i)),"Empty",0,0,0);
end
Registers = cat(2,F_Registers,R_Registers);
numreg = Register("Num","Empty",0,0,0);
Registers = cat(2,Registers,numreg);

% Instructions Creation
sr = size(Registers,2);
Instructions = Instruction.empty(si,0);
for i = 1:si
    
    dest_index = 0;
    for j = 1:sr
        if Registers(j).Name == Program(i,2)
            dest_index = j;
        end
    end
    
    s1 = Program(i,3);
    k1 = char(s1(1));
    k11 = size(str2num(k1(1)),1);
    S1_index = 0;
    for j = 1:sr
        if Registers(j).Name == Program(i,3)
            S1_index = j;
        end
    end
    for j = 1:sr
        if k11 == 1
            S1_index = sr;
        end
    end
    
    s2 = Program(i,4);
    k2 = char(s2(1));
    k22 = size(str2num(k2(1)),1);
    S2_index = 0;
    for j = 1:sr
        if Registers(j).Name == Program(i,4)
            S2_index = j;
        end
    end
    for j = 1:sr
        if k22 == 1
            S2_index = sr;
        end
    end
    
    Instructions(i) = Instruction(i,Program(i,1),Program(i,2),dest_index,Program(i,3),S1_index,Program(i,4),S2_index,0,0,0);
end

[Board,cycles] = tomasulo(Program,Instructions,Reservation_Stations,Load_Buffers,Store_Buffers,Registers);

fprintf("Program executed with the "+mode+" Algorithm in "+cycles+" Cycles")
figure();
uit = uitable('Data',Board);
uit.FontSize = 20;
pause(0);
set(uit,'ColumnWidth',{50});
set(uit,'ColumnName',{'Issued','Read Operands','Execution Completed','Write'});
