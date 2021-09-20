% Initialization.
format compact;
clc;
clear;
close all;
%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

% User Input.
mode = "Scoreboard";
Program = ["LD" "F6" "34+" "R2" 1; % 1st column: name of instruction. 2nd: destination register 3rd and 4th: source registers.
           "LD" "F2" "45+" "R3" 1;
           "MULTD" "F0" "F2" "F4" 10;
           "SUBD" "F8" "F6" "F2" 2;
           "DIVD" "F10" "F0" "F6" 40;
           "ADDD" "F6" "F8" "F2" 2];
Max_F_Register_Index = 10; % Max Index of F Registers in Program.
R_Register_Indexes = [2 3]; % R Registers to use.
Function_Units_List = ["Integer";
                       "Mult1";
                       "Mult2";
                       "Add";
                       "Divide"];                      
Function_Units_Associations = ["LD" "LD" "LD";
                               "MULTD" "MULTD" "MULTD";
                               "MULTD" "MULTD" "MULTD";
                               "ADDD" "SUBD" "ADDD";
                               "DIVD" "DIVD" "DIVD"];
                                
%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% Function Units Creation
si = size(Program,1);
sfu = size(Function_Units_List,1);
Function_Units = Function_Unit.empty(sfu,0);
for i = 1:sfu
    Function_Units(i) = Function_Unit(Function_Units_Associations(i,:),0,0,Function_Units_List(i,1),"No","Empty","Empty","Empty","Empty","Empty","Empty","Empty","Empty");
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

[Board,cycles] = scoreboard(Program,Instructions,Function_Units,Registers);

fprintf("Program executed with the "+mode+" Algorithm in "+cycles+" Cycles")
figure();
uit = uitable('Data',Board);
uit.FontSize = 20;
pause(0);
set(uit,'ColumnWidth',{50});
set(uit,'ColumnName',{'Issued','Read Operands','Execution Completed','Write'});
