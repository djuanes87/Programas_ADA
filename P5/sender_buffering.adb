
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Neighbors;

package body Sender_Buffering is
   package ASU renames Ada.Strings.Unbounded;


   procedure Free is new Ada.Unchecked_Deallocation (Tree, Tree_A);


   function Image (EP: LLU.End_Point_Type) return String is
      S : ASU.Unbounded_String := ASU.To_Unbounded_String(LLU.Image (EP));
      IP, Port  : ASU.Unbounded_String;
   begin
      if LLU.Is_Null (EP) then
         return "null";
      else
         S := ASU.Tail (S, ASU.Length (S) - ASU.Index (S, "IP:") + 1 - 4);

         IP := ASU.Head (S, ASU.Index (S, ", Port"));
         Port := ASU.Tail (S, ASU.Length (S) - ASU.Index (S, "Port:") + 1 - 7);

         return "(" & ASU.To_String(IP) & " " & ASU.To_String(Port) & ")";
      end if;
   end Image;



   protected body Map is

      function Tree_Size (P_Tree : Tree_A) return Natural is
      begin
         if P_Tree /= null then
            return 1 + Tree_Size (P_Tree.Left) + Tree_Size (P_Tree.Right);
         else
            return 0;
         end if;
      end Tree_Size;

      function Tree_Size return Natural is
      begin
         return Tree_Size (The_Tree);
      end Tree_Size;

      function Min (P_Tree : Tree_A) return Tree_A is
      begin
         if P_Tree = null then
            return null;
         end if;

         if P_Tree.Left = null then
            return P_Tree;
         else
            return Min (P_Tree.Left);
         end if;

      end Min;

      function Min return Ada.Calendar.Time is
      begin
         return Min (The_Tree).key;
      end;

      function Is_Empty return Boolean is
      begin
         return The_Tree = null;
      end Is_Empty;

      procedure Get (P_Tree  : Tree_A;
                     EP      : in  Llu.End_Point_Type;
                     Seq_N  : in  Types.Seq_N_T;
                     Key     : out Ada.Calendar.Time;
                     Value   : out Value_T;
                     Success : out Boolean) is
      begin
         Success := False;
         Value := Null_Value;

         if P_Tree /= null then
            if P_Tree.Value.Ep = Ep and then P_Tree.Value.Seq_N = Seq_N then
               Value := P_Tree.Value;
               Key   := P_Tree.Key;
               Success := True;
            else
               if P_Tree.Left /= null then
                  Get (P_Tree.Left, Ep, Seq_N, Key, Value, Success);
               end if;
               if not Success and then P_Tree.Right /= null then
                  Get (P_Tree.Right, Ep, Seq_N, Key, Value, Success);
               end if;
            end if;
         end if;
      end Get;

      procedure Get (ep       : in  Llu.End_Point_Type;
                     Seq_N   : in  Types.Seq_N_T;
                     Key      : out Ada.Calendar.Time;
                     Value    : out Value_T;
                     Success  : out Boolean) is
      begin
         Get (The_Tree, Ep, Seq_N, Key, Value, Success);
      end Get;


      procedure Get (P_Tree  : Tree_A;
                     Key     : in  Ada.Calendar.Time;
                     Value   : out Value_T;
                     Success : out Boolean) is
      begin
         Value := Null_Value;
         if P_Tree = null then
            Success := False;
         elsif P_Tree.Key = Key then
            Value := P_Tree.Value;
            Success := True;
         elsif Key > P_Tree.Key then
            Get (P_Tree.Right, Key, Value, Success);
         else
            Get (P_Tree.Left, Key, Value, Success);
         end if;
      end Get;


      procedure Get (Key     : in  Ada.Calendar.Time;
                     Value   : out Value_T;
                     Success : out Boolean) is
      begin
         Get (The_Tree, Key, Value, Success);
      end Get;



      function Put (P_Tree : in Tree_A;
                    Key    : Ada.Calendar.Time;
                    Value  : Value_T)
                   return Tree_A is

      begin

         if P_Tree = null then
            return new Tree'(Key, Value, null, null);
         end if;

         if Key = P_Tree.Key then
            P_Tree.Value := Value;
         elsif Key < P_Tree.Key then
            P_Tree.Left := Put (P_Tree.Left, Key, Value);
         elsif Key > P_Tree.Key then
            P_Tree.Right := Put (P_Tree.Right, Key, Value);
         end if;

         return P_Tree;
      end Put;

      procedure Put (Key   : Ada.Calendar.Time;
                     Value : Value_T) is
      begin
         The_Tree := Put (The_Tree, Key, Value);
      end Put;



      function Delete_Min (P_Tree : Tree_A)  return Tree_A  is
         P_Aux: Tree_A;
         P : Tree_A;
      begin

         P_Aux := P_Tree;

         if P_Aux = null then
            return null;
         end if;

         if P_Aux.Left = null then
            P := P_Aux.Right;
            Free (P_Aux); --P_Aux := null; -- Hay que liberar memoria si no hay GC
            return P;
         else
            P_Aux.Left := Delete_Min (P_Aux.Left);
            return P_Aux;
         end if;

      end Delete_Min;



      function Delete (P_Tree : Tree_A;
                       Key : Ada.Calendar.Time) return Tree_A is
         Min : Tree_A;
         P_Aux : Tree_A;
         P_Free : Tree_A;
      begin

         if P_Tree = null then
            return null;
         end if;

         if Key < P_Tree.Key and then P_Tree.Left /= null Then
            P_Tree.left := Delete (P_Tree.Left, Key);
            return P_Tree;
         end if;

         if Key > P_Tree.Key and then P_Tree.Right /= null then
            P_Tree.Right :=  Delete (P_Tree.Right, Key);
            return P_Tree;
         end if;

         if P_Tree.Key = Key then
            if P_Tree.Left = null then
               P_Aux := P_Tree.Right;
               P_Free := P_Tree; -- Si no hay GC, liberar P_Free
               Free (P_Free);
               return P_Aux;
            elsif P_Tree.Right = null then
               P_Aux := P_Tree.Left;
               P_Free := P_Tree; -- Si no hay GC, liberar P_Free
               Free (P_Free);
               return P_Aux;
            else
               Min := Map.Min (P_Tree.Right);
               if Min /= null then
                  P_Tree.Key := Min.key;
                  P_Tree.Value := Min.Value;
               end if;
               P_Tree.Right := Delete_Min (P_Tree.Right);
               return P_Tree;
            end if;
         end if;

         return P_Tree;

      end Delete;

      procedure Delete (Key : Ada.Calendar.Time) is
      begin
         if The_Tree /= null then
            The_Tree := Map.Delete (The_Tree, Key);
         end if;
      end Delete;

      function Image (T: Ada.Calendar.Time) return String is
         use type ASU.Unbounded_String;

         S_Decimals: constant Integer := 4;
         D: Duration;
         H, M: Integer;
         S: Duration;
         Hst, Mst, Sst, Tst: ASU.Unbounded_String;
      begin
         D := Ada.Calendar.Seconds(T);
         H := Integer(D)/3600;
         D := D - Duration(H)*3600;
         M := Integer(D)/60;
         S := D - Duration(M)*60;
         Hst := ASU.To_Unbounded_String(Integer'Image(H));
         Mst := ASU.To_Unbounded_String(Integer'Image(M));
         Sst := ASU.To_Unbounded_String(Duration'Image(S));
         Hst := ASU.Tail(Hst, ASU.Length(Hst)-1);
         Mst := ASU.Tail(Mst, ASU.Length(Mst)-1);
         Sst := ASU.Tail(Sst, ASU.Length(Sst)-1);
         Sst := ASU.Head(Sst, ASU.Length(Sst)-(9-S_Decimals));
         Tst := Hst & "h:" & Mst & "m:" & Sst & "s:";
         return ASU.To_String(Tst);
      end Image;

      procedure Print_Tree (P_Tree : Tree_A) is
      begin
         if P_Tree /= null then
            if P_Tree.Left /= null then
               Print_Tree (P_Tree.Left);
            end if;


            Ada.Text_IO.Put_Line
              ( Image(P_Tree.Key ) &
                  " (" & Image(P_Tree.Value.Ep) & ":" &
                  P_Tree.Value.Seq_N'Img & ")");

            if P_Tree.Right /= null then
               Print_Tree (P_Tree.Right);
            end if;
         end if;
      end Print_Tree;

      procedure Print_Tree is
      begin
         Ada.Text_IO.Put_Line ("Sender_Buffering");
         Ada.Text_IO.Put_Line ("----------------");

         Print_Tree (The_Tree);
      end Print_Tree;
      
      procedure Comprobar_Ack_Receive (EP_Creat: in LLU.End_Point_Type; Seq_N: in Types.Seq_N_T; EP_ACKer: in LLU.End_Point_Type) is
      	E: Value_T;
      	Time: Ada.Calendar.Time;
      	Success : Boolean;
      	Cont : Integer;
      	Vacio : Boolean;
      begin
      	Vacio := False;
      	Cont := 1;
      	Get(EP_Creat, Seq_N, Time, E, Success);
      	if Success then
      		Delete(Time);
      		for k in 1..10 loop
      			if E.Destinations(k).EP = EP_ACKer then
      				E.Destinations(k).EP := null;
      				E.Destinations(k).Retries := 0;
      			end if;
      			if E.Destinations(k).EP /= null and not Vacio then
      				Vacio := True;
      			end if;
      		end loop;
      		if Vacio then
      			Put(Time, E);
      		end if;
      	end if;     		
      
      end Comprobar_Ack_Receive;
      
      
      procedure Introducir_Ack_Arbol (LN: in out Neighbors.List_Protected_Neighbors; Time: in Ada.Calendar.Time; EP: in LLU.End_Point_Type; Seq_N: in Types.Seq_N_T;  EP_Rsnd: in LLU.End_Point_Type; P_Buffer: in out LLU.Buffer_Type) is
      	E : Value_T;
      	EP_Aux: LLU.End_Point_Type;
      	Key: Ada.Calendar.Time;
      	Cont : Integer;
      	Encontrado : Boolean;
      	Success: Boolean;
      begin
      
      	Encontrado := False;
      	Success := False;
      	Cont := 1;
      	EP_Aux := EP_Rsnd;
      	Get(EP, Seq_N, Key, E, Success );
      	if not Success then
      		E.EP := EP;
      		E.Seq_N := Seq_N;
      		E.P_Buffer := new LLU.Buffer_Type (1024);
      		LLU.Copy(E.P_Buffer, P_Buffer'Access);
      		while EP_Aux /= null loop
      			Neighbors.Crear_Destinations(LN, Cont, EP_Aux);
      			E.Destinations(Cont).EP := EP_Aux;
      			E.Destinations(Cont).Retries := 0;
      			Cont := Cont + 1;
      		end loop;
      		Cont := 1;
      		while Cont <= 10 loop
      			if E.Destinations(Cont).EP = EP_Rsnd then
      				E.Destinations(Cont).EP := null;
      			end if;
      			if E.Destinations(Cont).EP /= null and not Encontrado then
      				Encontrado := True;
      			end if;
      			Cont := Cont + 1;
      		end loop;
      		if Encontrado then
      			Put(Time, E);
      		end if;
      	end if;
      
      end Introducir_Ack_Arbol;
      
      procedure Send_Message (T: in Ada.Calendar.Time; TF: in Ada.Calendar.Time; Success: in out Boolean) is
      	E: Value_T;
      	Vacio : Boolean;
      begin
      	Vacio := False;
      	Get(T, E, Success);
      		If Success then
      			Delete(T);
      			for k in 1..10 loop
      				if E.Destinations(k).EP /= null then
      					LLU.Send(E.Destinations(k).EP, E.P_Buffer);
      					E.Destinations(k).Retries := E.Destinations(k).Retries + 1;
      					if E.Destinations(k).Retries >= 10 then
      						E.Destinations(k).Retries := 0;
      						E.Destinations(k).EP := null;
      					end if;
      				end if;
      				if E.Destinations(k).EP /= null and not Vacio then
      					Vacio := True;
      				end if;
      			end loop;
      			if Vacio then
      				Put(TF, E);
      			else
      				Success := False;
      			end if;
      		end if;
      
      end Send_Message;
      
      procedure Comprobar_Temp (T: out Ada.Calendar.Time) is
      
      begin
      	if Is_Empty then
      		T := Min;
      	else
      		T := Ada.Calendar.Clock + 10.0;
      	end if;
      end Comprobar_Temp;
      	
   end Map;



   procedure Put (M      : in out Map;
                  Key    : in     Ada.Calendar.Time;
                  Value  : in     Value_T) is
      New_Value : Value_T;
   begin
      New_Value := Value;

      New_value.P_Buffer := new LLU.Buffer_Type (1024);
      LLU.Copy (New_Value.P_Buffer, Value.P_Buffer);

      M.Put(Key, New_Value);
   end Put;


   procedure Get (M       : in out Map;
                  Key     : in     Ada.Calendar.Time;
                  Value   : out    Value_T;
                  Success : out    Boolean) is
   begin
      M.Get (Key, Value, Success);
   end Get;

   procedure Get (M       : in out  Map;
                  EP      : in      Llu.End_Point_Type;
                  Seq_N   : in      Types.Seq_N_T;
                  Key     : out     Ada.Calendar.Time;
                  Value   : out     Value_T;
                  Success : out     Boolean) is
   begin
      M.Get (Ep, Seq_N, Key, Value, Success);
   end Get;


   function Is_Empty (M: in Map) return Boolean is
   begin
      return M.Is_Empty;
   end Is_Empty;

   function Min (M: in Map) return Ada.Calendar.Time is
   begin
      return M.Min;
   end;

   procedure Delete (M: in out Map; Key : in Ada.Calendar.Time) is
   begin
      M.Delete (Key);
   end Delete;


   function Size (M: in Map) return Natural is
   begin
      return M.Tree_Size;
   end Size;


   procedure Print (M: in out Map) is
   begin
      M.Print_Tree;
   end Print;
   
   procedure Comprobar_Ack_Receive (M: in out Map; EP_Creat: in LLU.End_Point_Type; Seq_N: in Types.Seq_N_T; EP_ACKer: in LLU.End_Point_Type) is
   
   begin
      M.Comprobar_Ack_Receive(EP_Creat, Seq_N, EP_ACKer);
   end Comprobar_Ack_Receive;
   
   procedure Introducir_Ack_Arbol (M: in out Map; LN: in out Neighbors.List_Protected_Neighbors; Time: in Ada.Calendar.Time; EP: in LLU.End_Point_Type; Seq_N: in Types.Seq_N_T;  EP_Rsnd: in LLU.End_Point_Type; P_Buffer: in out LLU.Buffer_Type) is
   begin
   	M.Introducir_Ack_Arbol(LN, Time, EP, Seq_N, EP_Rsnd, P_Buffer);
   end Introducir_Ack_Arbol;
   
   procedure Send_Message (M: in out Map; T: in Ada.Calendar.Time; TF: in Ada.Calendar.Time; Success: in out Boolean) is
   
   begin
   	M.Send_Message(T, TF, Success);
   end Send_Message;
   
   procedure Comprobar_Temp (M: in out Map; T: out Ada.Calendar.Time) is
   
   begin
   	M.Comprobar_Temp(T);
   end Comprobar_Temp;



end Sender_Buffering;
