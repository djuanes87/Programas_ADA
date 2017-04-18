--Alumno: Daniel Juanes Quintana
--Curso: Programacion de sistemans telematicos

with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Handlers;
with Lower_Layer_UDP;
with Chat_Messages;
with Neighbors;
with Latest_Msgs;
with Types;
with Sender_Buffering;
with Timed_Handlers;
with Ada.Calendar;

procedure Peer_Chat is
	
	
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames Chat_Messages;
	package SB renames Sender_Buffering;
	
	use type CM.Message_Type;
	
	--Exceptions que se pueden dar
	Usage_Error: exception;
	Message_Error: exception;
	Delay_Error: exception;
	Fault_Error: exception;
	
	function Salir_Chat (Comment : ASU.Unbounded_String) return Boolean is
	
	begin
		return ASU.To_String(Comment) = ".salir"; 
	end Salir_Chat;
	
	procedure Almacenar (IP: in ASU.Unbounded_String; Port: in Integer) is 
		EP_H_Neighbor : LLU.End_Point_Type;
	begin
		EP_H_Neighbor := LLU.Build(ASU.To_String(IP), Port);
		Neighbors.Almacenar_Neighbor(Handlers.Lista_Neighbors, EP_H_Neighbor);
	end;
	
	Expired : Boolean;
	
	--Datos obtenido por los argumentos
	IP_Nodo: ASU.Unbounded_String;
	Port_Handler: Integer;
	Nick_Nodo: ASU.Unbounded_String;
	Neighbor_Host : ASU.Unbounded_String;
	Neighbor_Port : Integer;
	
	--Datos que formaran el mensaje
	Buffer : aliased LLU.Buffer_Type (1024);
	Mess: CM.Message_Type;
	EP_R : LLU.End_Point_Type;
	EP_H : LLU.End_Point_Type;
	Seq_N : Types.Seq_N_T;
	Comment : ASU.Unbounded_String;
	
	Future_Time: Ada.Calendar.Time;
	Temp: Ada.Calendar.Time;

begin
	Expired := False;
	Seq_N := 0;
	
	if ACL.Argument_Count /= 5 and ACL.Argument_Count /= 7 and ACL.Argument_Count /= 9 then 
		raise Usage_Error;
	elsif ACL.Argument_Count = 7 then
		Neighbor_Host := ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(6)));
		Neighbor_Port := Integer'Value(ACL.Argument(7));
		Almacenar(Neighbor_Host, Neighbor_Port);
	elsif ACL.Argument_Count = 9 then
		Neighbor_Host := ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(6)));
		Neighbor_Port := Integer'Value(ACL.Argument(7));
		Almacenar(Neighbor_Host, Neighbor_Port);
		Neighbor_Host := ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(8)));
		Neighbor_Port := Integer'Value(ACL.Argument(9));
		Almacenar(Neighbor_Host, Neighbor_Port);
	end if;
	
	Handlers.Min_Delay := Integer'Value(ACL.Argument(3));
	Handlers.Max_Delay := Integer'Value(ACL.Argument(4));
	Handlers.Fault_Pct := Integer'Value(ACL.Argument(5));
	if Handlers.Min_Delay > Handlers.Max_Delay or Handlers.Min_Delay < 0  then
		raise Delay_Error;
	end if;
	if Handlers.Fault_Pct < 0 or Handlers.Fault_Pct > 100 then
		raise Fault_Error;
	end if;
	LLU.Set_Faults_Percent(Handlers.Fault_Pct);
	LLU.Set_Random_Propagation_Delay(Handlers.Min_Delay, Handlers.Max_Delay);
	
	LLU.Reset(Buffer);
	
	IP_Nodo := ASU.To_Unbounded_String(LLU.To_IP(LLU.Get_Host_Name));
	Port_Handler := Integer'Value(ACL.Argument(1)); 
	Nick_Nodo := ASU.To_Unbounded_String(ACL.Argument(2));
	
	EP_H := LLU.Build(ASU.To_String(IP_Nodo), Port_Handler);
	
	LLU.Bind(EP_H, Handlers.Cliente_Handler'Access);
	if ACL.Argument_Count /= 2 then
		LLU.Bind_Any(EP_R);
		CM.Crear_Message_Init(Buffer , EP_H, Seq_N, EP_H, EP_R, Nick_Nodo);
		Future_Time := Ada.Calendar.Clock;
		SB.Introducir_Ack_Arbol(Handlers.Lista_Acks, Handlers.Lista_Neighbors, Future_Time, EP_H, Seq_N, EP_H, Buffer);
		Handlers.Send_Message_Temp(Future_Time);
		LLU.Reset(Buffer);
		LLU.Receive(EP_R, Buffer'Access, 2.0, Expired);
	else
		Expired := True;
	end if;
	
	if Expired then
		Seq_N := 0;
		Ada.Text_IO.Put_Line("Peer-Chat v2.0");
		Ada.Text_IO.Put_Line("==============");
		Ada.Text_IO.Put_Line("Entramos en el chat con Nick: " & ASU.To_String(Nick_Nodo));
		if ACL.Argument_Count /= 5 then
			CM.Crear_Message_Confirm(Buffer, EP_H, Seq_N, EP_H, Nick_Nodo);
			Future_Time := Ada.Calendar.Clock;
			SB.Introducir_Ack_Arbol(Handlers.Lista_Acks, Handlers.Lista_Neighbors, Future_Time, EP_H, Seq_N, EP_H, Buffer);
			Handlers.Send_Message_Temp(Future_Time);
		end if;
		--Entra en modo escritor una vez enviado el confirm
		loop
			Seq_N := 0;
			LLU.Reset(Buffer);
			Comment := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
			exit when Salir_Chat(Comment);
			CM.Crear_Message_Writer (Buffer, EP_H, Seq_N, EP_H, Nick_Nodo, Comment);
			Future_Time := Ada.Calendar.Clock;
			SB.Introducir_Ack_Arbol(Handlers.Lista_Acks, Handlers.Lista_Neighbors, Future_Time, EP_H, Seq_N, EP_H, Buffer);
			Handlers.Send_Message_Temp(Future_Time);			
		end loop;
		CM.Crear_Message_Logout(Buffer, EP_H, Seq_N, EP_H, Nick_Nodo, True);
		Future_Time := Ada.Calendar.Clock;
		SB.Introducir_Ack_Arbol(Handlers.Lista_Acks, Handlers.Lista_Neighbors, Future_Time, EP_H, Seq_N, EP_H, Buffer);
		Handlers.Send_Message_Temp(Future_Time);
		Temp := Ada.Calendar.Clock;
		Handlers.Wait_End_List(Temp);
				
	else
		Mess := CM.Message_Type'Input(Buffer'Access);
		if Mess /= CM.Reject then
			raise Message_Error;
		else
			Ada.Text_IO.Put_Line("En nick utilizado esta siendo ocupado por otro nodo");
			LLU.Reset(Buffer);
			CM.Crear_Message_Logout(Buffer,EP_H, Seq_N, EP_H, Nick_Nodo, False);
			Future_Time := Ada.Calendar.Clock;
			SB.Introducir_Ack_Arbol(Handlers.Lista_Acks, Handlers.Lista_Neighbors, Future_Time, EP_H, Seq_N, EP_H, Buffer);
			Handlers.Send_Message_Temp(Future_Time);
			Temp := Ada.Calendar.Clock;
			Handlers.Wait_End_List(Temp);
		end if;
	end if;
	
	LLU.Finalize;
	Timed_Handlers.Finalize;
	
exception
	when Usage_Error =>
		Ada.Text_IO.Put_Line("Uso: <port>  <nickname> <min_delay> <max_delay> <fault_pct> [[neighbor_host neighbor_port] [neighbor_host neighbor_port]]");
		Ada.Text_IO.Put_Line("Recuerda como maximo dos neighbor");
		LLU.Finalize;
		Timed_Handlers.Finalize;
	when Message_Error =>
		Ada.Text_IO.Put_Line("Alguien en el periodo de confirmacion te ha enviado un tipo de mensaje no valido");
		LLU.Finalize;
		Timed_Handlers.Finalize;
	when Delay_Error =>
		Ada.Text_IO.Put_Line("Min_Delay debe ser menor que Max_Delay, y ambos deben ser positivos");
		LLU.Finalize;
		Timed_Handlers.Finalize;
	when Fault_Error =>
		Ada.Text_IO.Put_Line("La tasa de error debe estar entre 0 y 100");
		LLU.Finalize;
		Timed_Handlers.Finalize;
	when Except:others =>
		Ada.Text_IO.Put_Line("Excepcion imprevista " & Ada.Exceptions.Exception_Name(Except) & " en: " & Ada.Exceptions.Exception_Message(Except));
		LLU.Finalize;
		Timed_Handlers.Finalize;
end Peer_Chat;
