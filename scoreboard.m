function [Board,cycles] = scoreboard(Program,Instructions,Function_Units,Registers)
    cycles = 0;
    si = size(Instructions,2);
    sfu = size(Function_Units,2);
    sr = size(Registers,2);
    stage = "";
    for s = 1:si
        stage(s) = "Empty";
    end
    Board = zeros(si,4);
    check = all(Board,'all'); %check=0 if the board has even one zero
    while check == 0 %if the board is unfinished we continue the algorithm
        cycles = cycles+1; %increase a cycle
        if cycles == 9
                cycles = 9;
            end
        for m = 1:si
            if stage(m) == "Write"
                
                index = Instructions(m).RSI;
                
                for fu = 1:sfu
                    if Function_Units(fu).FU1 == Function_Units(index).Name
                        Function_Units(fu).FU1 = "Empty";
                    end
                    if Function_Units(fu).FU2 == Function_Units(index).Name
                        Function_Units(fu).FU2 = "Empty";
                    end
                    if Function_Units(fu).S1 == Function_Units(index).Dest
                        Function_Units(fu).Av1 = "Yes";
                    end
                    if Function_Units(fu).S2 == Function_Units(index).Dest
                        Function_Units(fu).Av2 = "Yes";
                    end
                end
                
                Function_Units(index).Busy = "No";
                Function_Units(index).Op = "Empty";
                Function_Units(index).Dest = "Empty";
                Function_Units(index).S1 = "Empty";
                Function_Units(index).S2 = "Empty";
                Function_Units(index).FU1 = "Empty";
                Function_Units(index).FU2 = "Empty";
                Function_Units(index).Av1 = "Empty";
                Function_Units(index).Av2 = "Empty";
                
                Registers(Instructions(m).Dest_Index).Status = "Empty";
                Registers(Instructions(m).Dest_Index).RSI = 0;
                Instructions(m).RSI = 0;
            end
        end
        stage(:) = "Empty";
        for i = 1:si %check each instruction
            
            if Board(i,1) == 0 %If instruction is not issued
                
                reg = Instructions(i).Dest_Index;
                structural_hazard = 0;
                for fu = sfu:-1:1  %check if a FU is available and WAW Hazard
                    if any(Function_Units(fu).Assoc(:) == Instructions(i).Name) && Function_Units(fu).Busy == "No" && Registers(reg).Status == "Empty"
                        structural_hazard = fu;
                    end
                end
                
                issue = 0;
                if i == 1 && Board(i,1) == 0
                    issue = 1;
                elseif Board(i-1,1) ~= 0 && stage(i-1) ~= "Issue"
                    issue = 1;
                end
                
                index = structural_hazard;
                if index ~= 0 && issue == 1%if we can issue, begin issue:
                    
                    Function_Units(index).Time = str2num(Program(i,5));
                    Function_Units(index).RemTime = str2num(Program(i,5));
                    Function_Units(index).Busy = "Yes"; 
                    Function_Units(index).Op = Instructions(i).Name;
                    Function_Units(index).Dest = Instructions(i).Dest;
                    Function_Units(index).S1 = Instructions(i).S1;
                    Function_Units(index).S2 = Instructions(i).S2;
                    for fu = 1:sfu
                        if Function_Units(index).S1 == Function_Units(fu).Dest && Function_Units(index).S1 ~= "Empty"
                            Function_Units(index).FU1 = Function_Units(fu).Name;
                        end
                    end
                    for fu = 1:sfu
                        if Function_Units(index).S2 == Function_Units(fu).Dest && Function_Units(index).S2 ~= "Empty"
                            Function_Units(index).FU2 = Function_Units(fu).Name;
                        end
                    end
                    if Function_Units(index).FU1 == "Empty"
                        Function_Units(index).Av1 = "Yes";
                    else
                        Function_Units(index).Av1 = "No";
                    end
                    if Function_Units(index).FU2 == "Empty"
                        Function_Units(index).Av2 = "Yes";
                    else
                        Function_Units(index).Av2 = "No";
                    end
                    Registers(reg).Status = Function_Units(index).Name;
                    Registers(reg).RSI = index;
                    Instructions(i).RSI = index;
                    Board(i,1) = cycles;
                    stage(i) = "Issue";
                end
            end
            
            if Board(i,1) ~= 0 && Board(i,2) == 0 && stage(i) == "Empty" % Read:
                index = Instructions(i).RSI;
                if Function_Units(index).Av1 == "Yes" && Function_Units(index).Av2 == "Yes"
                    Board(i,2) = cycles;
                    stage(i) = "Read";
                end
            end
            
            if Board(i,2) ~= 0 && Board(i,3) == 0 && stage(i) == "Empty" % Execute:
                index = Instructions(i).RSI;
                Function_Units(index).RemTime = Function_Units(index).RemTime-1;
                if Function_Units(index).RemTime == 0
                    Board(i,3) = cycles;
                    stage(i) = "Execute";
                    Function_Units(index).RemTime = Function_Units(index).Time;
                end
            end
            
            if Board(i,3) ~= 0 && Board(i,4) == 0 && stage(i) == "Empty" % Write:
                war = 0;
                index = Instructions(i).RSI;
                for f = 1:i
                    if Program(f,3) == Program(i,2) || Program(f,4) == Program(i,2)
                        kar = Instructions(f).RSI;
                        if kar ~= 0
                            if Function_Units(kar).S1 == Function_Units(index).Dest && Board(f,2) == 0 || stage(f) == "Read"
                                war = 1;
                            end
                            if Function_Units(kar).S2 == Function_Units(index).Dest && Board(f,2) == 0 || stage(f) == "Read"
                                war = 1;
                            end
                        end
                    end
                end
                if war == 0
                    Board(i,4) = cycles;
                    stage(i) = "Write";
                end
            end
        end
        check = all(Board,'all');
    end
end