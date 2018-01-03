classdef JPDA_Feasible_Events < handle
   % JPDA_FEASIBLE_EVENTS Class for calculating feasible events within the JPDA filter.
   %
   % This class calculates feasible events given validation matrix.
   % It should be used within the JPDA filter and in similar algorithms.
   %
   % Marcelo L. de Souza <marcelo.l.desouza@ieee.org> Jan 2018
   
   properties(SetAccess = private)
      Feasible_Events
   end
   
   methods
      
      function Obj = JPDA_Feasible_Events(Validation_Matrix)
         % Class constructor
         %
         % Constructor parameter is a validation matrix with
         % size M x N whose fesible events are to be calculated.
                  
         [M, N] = size(Validation_Matrix);
         
         %
         % First, build Row_Configuration_Matrix where each (:,:,i) contains
         % all fesible rows for the i-th row of the Validation_Matrix
         %
         Row_Configuration_Matrix = zeros(N, N, M);
         Row_Configuration_Counter = zeros(M,1);
         for I = 1:M
            Row_Configuration_Matrix_Index = 1;
            for J_Temp = 1:N
               if Validation_Matrix(I, J_Temp) == 1
                  Row_Temp = zeros(1,N);
                  Row_Temp(1,J_Temp) = 1;
                  Row_Configuration_Matrix(Row_Configuration_Matrix_Index,:, I) = Row_Temp;
                  Row_Configuration_Matrix_Index = Row_Configuration_Matrix_Index + 1;
                  Row_Configuration_Counter(I) = Row_Configuration_Counter(I) + 1;
               end
            end
         end
         
         %
         % Secondly, list all events for the Row_Configuration_Matrix and
         % store them in the All_Events matrix.
         %
         Number_Of_Events = prod(Row_Configuration_Counter);
         All_Events = zeros(M, N, Number_Of_Events);
         Last_Repetition_Factor = Number_Of_Events;
         for J = 1:M
            Repetition_Factor = Last_Repetition_Factor / Row_Configuration_Counter(J);
            Repetition_Counter = 0;
            Index = 1;
            for K = 1:Number_Of_Events
               All_Events(J,:,K) = Row_Configuration_Matrix(Index,:,J);
               Repetition_Counter = Repetition_Counter + 1;
               if Repetition_Counter >= Repetition_Factor
                  Index = Index + 1;
                  Repetition_Counter = 0;
                  if Index > Row_Configuration_Counter(J)
                     Index = 1;
                  end
               end
            end
            Last_Repetition_Factor = Repetition_Factor;
         end
         
         %
         % Finally, validate and save feasible events in All_Events matrix
         % in the class attribute Feasible_Events
         %
         Obj.Feasible_Events = zeros(M, N, Number_Of_Events);
         Feasible_Events_Counter = 0;
         for I = 1:Number_Of_Events
            if Obj.Is_Event_Feasible(All_Events(:,:,I)) == 1
               Feasible_Events_Counter = Feasible_Events_Counter + 1;
               Obj.Feasible_Events(:,:,Feasible_Events_Counter) = All_Events(:,:,I);
            end
         end
         Obj.Feasible_Events = Obj.Feasible_Events(:,:,1:Feasible_Events_Counter);
      end
      
      function Events = Get_Fesible_Events(Obj)
         % Returns calculated fesible events in a matrix with dimension
         % N x M x K. Each matrix with dimension M x N
         % is a feasible event.
         % The number of feasible events is K.
         
         Events = Obj.Feasible_Events;
      end
      
      function Result = Is_Event_Feasible(Obj,Event)
         % Returns true if "Event" is feasible according to the JPDA definition.
         
         Result = 1;
         Sum_Columns = sum(Event,1);
         
         if length(Sum_Columns) > 1
            for I = 2:length(Sum_Columns)
               if Sum_Columns(I) > 1
                  Result = 0;
               end
            end
         end
         Sum_Rows = sum(Event,2);
         for I = 1:length(Sum_Rows)
            if Sum_Rows(I) ~= 1
               Result = 0;
            end
         end
      end
      
   end
   
end

