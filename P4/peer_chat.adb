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

procedure Peer_Chat is
	
	
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames Chat_Messages;
	
	use type CM.Message_Type;
	
	--Exceptions que se pueden dar
	Usage_Error: exception;
	Message_Error: exception;
	
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
	Seq_N : CM.Seq_N_T;
	Comment : ASU.Unbounded_String;

begin
	Expired := False;
	Seq_N := 0;
	
	if ACL.Argument_Count /= 2 and ACL.Argument_Count /= 4 and ACL.Argument_Count /= 6 then 
		raise Usage_Error;
	elsif ACL.Argument_Count = 4 then
		Neighbor_Host := ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(3)));
		Neighbor_Port := Integer'Value(ACL.Argument(4));
		Almacenar(Neighbor_Host, Neighbor_Port);
	elsif ACL.Argument_Count = 6 then
		Neighbor_Host := ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(3)));
		Neighbor_Port := Integer'Value(ACL.Argument(4));
		Almacenar(Neighbor_Host, Neighbor_Port);
		Neighbor_Host := ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(5)));
		Neighbor_Port := Integer'Value(ACL.Argument(6));
		Almacenar(Neighbor_Host, Neighbor_Port);
	end if;
	
	LLU.Reset(Buffer);
	
	IP_Nodo := ASU.To_Unbounded_String(LLU.To_IP(LLU.Get_Host_Name)); 
	Port_Handler := Integer'Value(ACL.Argument(1)); 
	Nick_Nodo := ASU.To_Unbounded_String(ACL.Argument(2));
	
	EP_H := LLU.Build(ASU.To_String(IP_Nodo), Port_Handler);
	
	--En caso de que solo tenga dos argumentos esto no hace falta ejecutarse
	if ACL.Argument_Count /= 2 then
		LLU.Bind_Any(EP_R);
		CM.Crear_Message_Init(Buffer , EP_H, Seq_N, EP_H, EP_R, Nick_Nodo);
		Neighbors.Enviar_Message(Handlers.Lista_Neighbors, Buffer, EP_H);
		LLU.Reset(Buffer);
		LLU.Receive(EP_R, Buffer'Access, 2.0, Expired);
	else
		Expired := True;
	end if;
	
	if Expired then
		LLU.Bind(EP_H, Handlers.Cliente_Handler'Access);
		Ada.Text_IO.Put_Line("Peer-Chat v1.0");
		Ada.Text_IO.Put_Line("==============");
		Ada.Text_IO.Put_Line("Entramos en el chat con Nick: " & ASU.To_String(Nick_Nodo));
		if ACL.Argument_Count /= 2 then
			CM.Crear_Message_Confirm(Buffer, EP_H, Seq_N, EP_H, Nick_Nodo);
			Neighbors.Enviar_Message(Handlers.Lista_Neighbors, Buffer, EP_H);
		end if;
		--Entra en modo escritor una vez enviado el confirm
		loop
			LLU.Reset(Buffer);
			Comment := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
			exit when Salir_Chat(Comment);
			CM.Crear_Message_Writer (Buffer, EP_H, Seq_N, EP_H, Nick_Nodo, Comment);
			Neighbors.Enviar_Message(Handlers.Lista_Neighbors, Buffer, EP_H);
		end loop;
		CM.Crear_Message_Logout(Buffer, EP_H, Seq_N, EP_H, Nick_Nodo, True);
		Neighbors.Enviar_Message(Handlers.Lista_Neighbors, Buffer, EP_H);
		
	else
		Mess := CM.Message_Type'Input(Buffer'Access);
		if Mess /= CM.Reject then
			raise Message_Error;
		else
			Ada.Text_IO.Put_Line("En nick utilizado esta siendo ocupado por otro nodo");
			LLU.Reset(Buffer);
			CM.Crear_Message_Logout(Buffer,EP_H, Seq_N, EP_H, Nick_Nodo, False); 
			Neighbors.Enviar_Message(Handlers.Lista_Neighbors, Buffer, EP_H);
		end if;
	end if;
	
	LLU.Finalize;
	
exception
	when Usage_Error =>
		Ada.Text_IO.Put_Line("Uso: <port>  <nickname> [ [neighbor_host neighbor_port] [neighbor_host neighbor_port]]");
		Ada.Text_IO.Put_Line("Recuerda como maximo dos neighbor");
		LLU.Finalize;
	when Message_Error =>
		Ada.Text_IO.Put_Line("Alguien en el periodo de confirmacion te ha enviado un tipo de mensaje no valido");
		LLU.Finalize;
	when Except:others =>
		Ada.Text_IO.Put_Line("Excepcion imprevista " & Ada.Exceptions.Exception_Name(Except) & " en: " & Ada.Exceptions.Exception_Message(Except));
		LLU.Finalize;
end Peer_Chat;
