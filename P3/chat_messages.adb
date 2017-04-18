-- Alumno: Daniel Juanes Quintana
--Clase: Programacion de sistemas telematicos
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
	
package body Chat_Messages is

	procedure Crear_Message_Writer_Server(Buf: in out LLU.Buffer_Type; Nick: in ASU.Unbounded_String) is
		Coment : ASU.Unbounded_String;
	begin
		Coment := ASU.Unbounded_String'Input(Buf'Access);
		Ada.Text_IO.Put_Line("recibido mensaje de " & ASU.To_String(Nick) & ": " & ASU.To_String(Coment));
		LLU.Reset(Buf);
		Message_Type'Output (Buf'Access, Server);
		ASU.Unbounded_String'Output(Buf'Access, Nick);
		ASU.Unbounded_String'Output(Buf'Access, Coment);		
	end Crear_Message_Writer_Server;
	
	procedure Crear_Message_Salida_Server (Buf: in out LLU.Buffer_Type; nickname: in ASU.Unbounded_String) is
	
	begin
		Message_Type'Output (Buf'Access, Server);
		ASU.Unbounded_String'Output(Buf'Access, ASU.To_Unbounded_String("Servidor"));
		ASU.Unbounded_String'Output(Buf'Access, (ASU.To_Unbounded_String(ASU.To_String(nickname) & (" ha salido del chat"))));
	end Crear_Message_Salida_Server;
	
	procedure Crear_Message_Expulsado(Buf: in out LLU.Buffer_Type; Nick: in ASU.Unbounded_String) is
	
	begin
		LLU.Reset(Buf);
		Message_Type'Output(Buf'Access, Server);
		ASU.Unbounded_String'Output(Buf'Access, ASU.To_Unbounded_String("Servidor"));
		ASU.Unbounded_String'Output(Buf'Access, ASU.To_Unbounded_String(ASU.To_String(Nick) & " ha sido expulsado del chat"));
	end Crear_Message_Expulsado;
	
	procedure Crear_Message_Init (Buf: in out LLU.Buffer_Type; CR: in LLU.End_Point_Type; CH: in LLU.End_Point_Type; N: ASU.Unbounded_String) is
	
	begin
		Message_Type'Output(Buf'Access, Init);
		LLU.End_Point_Type'Output(Buf'Access, CR);
		LLU.End_Point_Type'Output(Buf'Access, CH);
		ASU.Unbounded_String'Output(Buf'Access, N);	
	end Crear_Message_Init;
	
	procedure Crear_Message_Writer_Client(Buf: in out LLU.Buffer_Type; CH: in LLU.End_Point_Type; Coment: in ASU.Unbounded_String) is
	
	begin
		Message_Type'Output(Buf'Access, Writer);
		LLU.End_Point_Type'Output(Buf'Access, CH);
		ASU.Unbounded_String'Output(Buf'Access, Coment);	
	end Crear_Message_Writer_Client;
	
	procedure Crear_Message_Initialization( Buf: in out LLU.Buffer_Type; Acogido:  in out Boolean ) is
		
		MS: Message_Type;
		
	begin
		MS := Message_Type'Input(Buf'Access);
		Acogido := Boolean'Input(Buf'Access);
	end Crear_Message_Initialization;
	
	procedure Crear_Message_Salida_Client (Buf: in out LLU.Buffer_Type; CH: in LLU.End_Point_Type) is
	
	begin
		Message_Type'Output(Buf'Access, Logout);
		LLU.End_Point_Type'Output(Buf'Access, CH);
	end Crear_Message_Salida_Client;	
	
end Chat_Messages;
