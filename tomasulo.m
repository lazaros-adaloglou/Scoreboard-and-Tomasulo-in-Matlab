function [Board,cycles] = tomasulo(Program,Instructions,Reservation_Stations,Load_Buffers,Store_Buffers,Registers)
    cycles = 0;
    si = size(Instructions,2);
    srs = size(Reservation_Stations,2);
    slb = size(Load_Buffers,2);
    ssb = size(Store_Buffers,2);
    sr = size(Registers,2);
    stage = "";
    for s = 1:si
        stage(s) = "Empty";
    end
    Board = zeros(si,4);
    check = all(Board,'all'); %check == 0 if the board has even one zero.
    while check == 0 % If the board is unfinished we continue the algorithm.
        cycles = cycles+1; % Increase a cycle 
        stage(:) = "Empty";
        for i = 1:si %check each instruction
            if Board(i,1) == 0 %Issue
                
                reg = Instructions(i).Dest_Index;
                structural_hazard = [0 ""];
                for frs = srs:-1:1  %check if a RS,LB or SB is available and WAW Hazard.
                    if any(Reservation_Stations(frs).Assoc(:) == Instructions(i).Name) && Reservation_Stations(frs).Busy == "No"
                        structural_hazard = [frs,"rs"];
                    end
                end
                for flb = slb:-1:1  
                    if any(Load_Buffers(flb).Assoc(:) == Instructions(i).Name) && Load_Buffers(flb).Busy == "No" 
                        structural_hazard = [flb,"lb"];
                    end
                end
                for fsb = ssb:-1:1  
                    if any(Store_Buffers(fsb).Assoc(:) == Instructions(i).Name) && Store_Buffers(fsb).Busy == "No" 
                        structural_hazard = [fsb,"sb"];
                    end
                end
                
                issue = 0;
                if i == 1 && Board(i,1) == 0 %If the first instruction is not issued
                    issue = 1;
                elseif Board(i-1,1) ~= 0 && stage(i-1) ~= "Issue"
                    issue = 1;
                end
                
                index = str2num(structural_hazard(1));
                if index ~= 0 && issue == 1 %if we can issue, begin issue:
                    switch structural_hazard(2)
                        case "rs"
                            
                            Reservation_Stations(index).Time = str2num(Program(i,5));
                            Reservation_Stations(index).RemTime = str2num(Program(i,5));
                            Reservation_Stations(index).Busy = "Yes";
                            Reservation_Stations(index).Op = Instructions(i).Name;
                            
                            if Registers(Instructions(i).S1_Index).Status ~= "Empty"
                                Reservation_Stations(index).VS1 = "Empty";
                            else
                                Reservation_Stations(index).VS1 = "R("+Instructions(i).S1+")";
                            end
                            if Registers(Instructions(i).S2_Index).Status ~= "Empty"
                                Reservation_Stations(index).VS2 = "Empty";
                            else
                                Reservation_Stations(index).VS2 = "R("+Instructions(i).S2+")";
                            end
                            
                            if Registers(Instructions(i).S1_Index).Status ~= "Empty"
                                Reservation_Stations(index).RS1 = Registers(Instructions(i).S1_Index).Status;
                            else
                                Reservation_Stations(index).RS1 = "Empty";
                            end
                            if Registers(Instructions(i).S2_Index).Status ~= "Empty"
                                Reservation_Stations(index).RS2 = Registers(Instructions(i).S2_Index).Status;
                            else
                                Reservation_Stations(index).RS2 = "Empty";
                            end
                            
                            Registers(Instructions(i).Dest_Index).Status = Reservation_Stations(index).Name;
                            Registers(Instructions(i).Dest_Index).RSI = index;
                            Instructions(i).RSI = index;
                            Board(i,1) = cycles;
                            stage(i) = "Issue";
                            
                        case "lb"
                            
                            Load_Buffers(index).Time = str2num(Program(i,5));
                            Load_Buffers(index).RemTime = str2num(Program(i,5));
                            Load_Buffers(index).Busy = "Yes";
                            Load_Buffers(index).Address = "R("+Instructions(i).S1+Instructions(i).S2+")";
                            if Registers(Instructions(i).S2_Index).Status ~= "Empty"
                                Load_Buffers(index).RS = Registers(Instructions(i).S2_Index).Status;
                            else
                                Load_Buffers(index).RS = "Empty";
                            end
                            Registers(Instructions(i).Dest_Index).Status = Load_Buffers(index).Name;
                            Registers(Instructions(i).Dest_Index).LBI = index;
                            Instructions(i).LBI = index;
                            Board(i,1) = cycles;
                            stage(i) = "Issue";
                            
                        case "sb"
                            
                            Store_Buffers(index).Time = str2num(Program(i,5));
                            Store_Buffers(index).RemTime = str2num(Program(i,5));
                            Store_Buffers(index).Busy = "Yes";
                            Store_Buffers(index).Address = "R("+Instructions(i).S1+Instructions(i).S2+")";
                            if Registers(Instructions(i).S2_Index).Status ~= "Empty"
                                Store_Buffers(index).RS = Registers(Instructions(i).S2_Index).Status;
                            else
                                Store_Buffers(index).RS = "Empty";
                            end
                            Registers(Instructions(i).Dest_Index).Status = Store_Buffers(index).Name;
                            Registers(Instructions(i).Dest_Index).SBI = index;
                            Instructions(i).SBI = index;
                            Board(i,1) = cycles;
                            stage(i) = "Issue";
                    end
                end
            end
            
            if Board(i,1) ~= 0 && Board(i,2) == 0 && stage(i) == "Empty" % Read:
                
                if Instructions(i).RSI ~= 0
                    if Reservation_Stations(Instructions(i).RSI).RS1 == "Empty" && Reservation_Stations(Instructions(i).RSI).RS2 == "Empty"
                        Board(i,2) = cycles;
                        stage(i) = "Read";
                    end
                end
                
                if Instructions(i).LBI ~= 0
                    if Load_Buffers(Instructions(i).LBI).RS == "Empty"
                        Board(i,2) = cycles;
                        stage(i) = "Read";
                    end
                end
                
                if Instructions(i).SBI ~= 0
                    if Store_Buffers(Instructions(i).SBI).RS == "Empty"
                        Board(i,2) = cycles;
                        stage(i) = "Read";
                    end
                end
                
            end
            
            if Board(i,2) ~= 0 && Board(i,3) == 0 && stage(i) == "Empty" % Execute:
                
                if Instructions(i).RSI ~= 0
                    Reservation_Stations(Instructions(i).RSI).RemTime = Reservation_Stations(Instructions(i).RSI).RemTime-1;
                    if Reservation_Stations(Instructions(i).RSI).RemTime == 0
                        Board(i,3) = cycles;
                        stage(i) = "Execute";
                        Reservation_Stations(Instructions(i).RSI).RemTime = Reservation_Stations(Instructions(i).RSI).Time;
                    end
                end
                
                if Instructions(i).LBI ~= 0
                    Load_Buffers(Instructions(i).LBI).RemTime = Load_Buffers(Instructions(i).LBI).RemTime-1;
                    if Load_Buffers(Instructions(i).LBI).RemTime == 0
                        Board(i,3) = cycles;
                        stage(i) = "Execute";
                        Load_Buffers(Instructions(i).LBI).RemTime = Load_Buffers(Instructions(i).LBI).Time;
                    end
                end
                
                if Instructions(i).SBI ~= 0
                    Store_Buffers(Instructions(i).SBI).RemTime = Store_Buffers(Instructions(i).SBI).RemTime-1;
                    if Store_Buffers(Instructions(i).SBI).RemTime == 0
                        Board(i,3) = cycles;
                        stage(i) = "Execute";
                        Store_Buffers(Instructions(i).SBI).RemTime = Store_Buffers(Instructions(i).SBI).Time;
                    end
                end
                
            end
            
            if Board(i,3) ~= 0 && Board(i,4) == 0 && stage(i) == "Empty" % Write:
                 war = 0;
                %for frs = 1:i
                  %  if Program(frs,3) == Program(i,2) || Program(frs,4) == Program(i,2)
                   %     kar = 0;
                   %     for k = 1:size(Reservation_Stations,2)
                   %         if Reservation_Stations(k).Op == Program(frs,1) && Reservation_Stations(k).Dest == Program(frs,2) && Reservation_Stations(k).S2 == Program(frs,4)
                   %             kar = k;
                   %         end
                    %    end
                     %   if kar ~= 0
                     %       if Reservation_Stations(kar).S1 == Reservation_Stations(kaiexee).Dest && Board(frs,2) == 0 || stage(frs) == "Read"
                    %            war = 1;
                    %        end
                   %         if Reservation_Stations(kar).S2 == Reservation_Stations(kaiexee).Dest && Board(frs,2) == 0 || stage(frs) == "Read"
                  % %             war = 1;
                  %          end
                 %      end
                 %   end
                %end
                if war == 0
                    Board(i,4) = cycles;
                    stage(i) = "Write";
                    
                    if Instructions(i).RSI ~= 0
                        Reservation_Stations(Instructions(i).RSI).Busy = "No";
                        Reservation_Stations(Instructions(i).RSI).Op = "Empty";
                        Reservation_Stations(Instructions(i).RSI).VS1 = "Empty";
                        Reservation_Stations(Instructions(i).RSI).VS2 = "Empty";
                        Reservation_Stations(Instructions(i).RSI).RS1 = "Empty";
                        Reservation_Stations(Instructions(i).RSI).RS2 = "Empty";
                        
                        for rs = 1:srs
                            if Reservation_Stations(rs).RS1 == Reservation_Stations(Instructions(i).RSI).Name
                                Reservation_Stations(rs).RS1 = "Empty";
                                Reservation_Stations(rs).VS1 = "R("+Instructions(i).Dest+")";
                            end
                            if Reservation_Stations(rs).RS2 == Reservation_Stations(Instructions(i).RSI).Name
                                Reservation_Stations(rs).RS2 = "Empty";
                                Reservation_Stations(rs).VS2 = "R("+Instructions(i).Dest+")";
                            end
                        end
                        
                        for lb = 1:slb
                            if Load_Buffers(lb).RS == Reservation_Stations(Instructions(i).RSI).Name
                                Load_Buffers(lb).RS = "Empty";
                            end
                        end
                        
                        for sb = 1:ssb
                            if Store_Buffers(sb).RS == Reservation_Stations(Instructions(i).RSI).Name
                                Store_Buffers(sb).RS = "Empty";
                            end
                        end
                        
                        Registers(Instructions(i).Dest_Index).Status = "Empty";
                        Registers(Instructions(i).Dest_Index).RSI = 0;
                        Instructions(i).RSI = 0;
                    end
                    
                    if Instructions(i).LBI ~= 0
                        Load_Buffers(Instructions(i).LBI).Busy = "No";
                        Load_Buffers(Instructions(i).LBI).Address = "Empty";
                        Load_Buffers(Instructions(i).LBI).RS = "Empty";
                        
                        for rs = 1:srs
                            if Reservation_Stations(rs).RS1 == Load_Buffers(Instructions(i).LBI).Name
                                Reservation_Stations(rs).RS1 = "Empty";
                                Reservation_Stations(rs).VS1 = "R("+Instructions(i).Dest+")";
                            end
                            if Reservation_Stations(rs).RS2 == Load_Buffers(Instructions(i).LBI).Name
                                Reservation_Stations(rs).RS2 = "Empty";
                                Reservation_Stations(rs).VS2 = "R("+Instructions(i).Dest+")";
                            end
                        end
                        
                        for lb = 1:slb
                            if Load_Buffers(lb).RS == Load_Buffers(Instructions(i).LBI).Name
                                Load_Buffers(lb).RS = "Empty";
                            end
                        end
                        
                        for sb = 1:ssb
                            if Store_Buffers(sb).RS == Load_Buffers(Instructions(i).LBI).Name
                                Store_Buffers(sb).RS = "Empty";
                            end
                        end
                        
                        Registers(Instructions(i).Dest_Index).Status = "Empty";
                        Registers(Instructions(i).Dest_Index).LBI = 0;
                        Instructions(i).LBI = 0;
                    end
                    
                    if Instructions(i).SBI ~= 0
                        Store_Buffers(Instructions(i).SBI).Busy = "No";
                        Store_Buffers(Instructions(i).SBI).Address = "Empty";
                        Store_Buffers(Instructions(i).SBI).RS = "Empty";
                        
                        for rs = 1:srs
                            if Reservation_Stations(rs).RS1 == Store_Buffers(Instructions(i).SBI).Name
                                Reservation_Stations(rs).RS1 = "Empty";
                                Reservation_Stations(rs).VS1 = "R("+Instructions(i).Dest+")";
                            end
                            if Reservation_Stations(rs).RS2 == Store_Buffers(Instructions(i).SBI).Name
                                Reservation_Stations(rs).RS2 = "Empty";
                                Reservation_Stations(rs).VS2 = "R("+Instructions(i).Dest+")";
                            end
                        end
                        
                        for lb = 1:slb
                            if Load_Buffers(lb).RS == Store_Buffers(Instructions(i).SBI).Name
                                Load_Buffers(lb).RS = "Empty";
                            end
                        end
                        
                        for sb = 1:ssb
                            if Store_Buffers(sb).RS == Store_Buffers(Instructions(i).SBI).Name
                                Store_Buffers(sb).RS = "Empty";
                            end
                        end
                        
                        Registers(Instructions(i).Dest_Index).Status = "Empty";
                        Registers(Instructions(i).Dest_Index).SBI = 0;
                        Instructions(i).SBI = 0;
                    end
                end
            end
        end
        check = all(Board,'all');
    end
end