-- Alumno: Daniel Juanes Quintana
--Clase: Programacion de sistemas telematicos

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;

package Chat_Messages is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;

	type Message_Type is (Init, Welcome,Writer, Server, Logout);
	--Crear los buffer que va a mandar el servidor
	procedure Crear_Message_Writer_Server(Buf: in out LLU.Buffer_Type; Nick: in ASU.Unbounded_String);
	procedure Crear_Message_Salida_Server (Buf: in out LLU.Buffer_Type; nickname: in ASU.Unbounded_String);
	procedure Crear_Message_Expulsado(Buf: in out LLU.Buffer_Type; Nick: in ASU.Unbounded_String);
	
	--Crear los buffer que va a mandar el cliente
	procedure Crear_Message_Init (Buf: in out LLU.Buffer_Type; CR: in LLU.End_Point_Type; CH: in LLU.End_Point_Type; N: ASU.Unbounded_String);
	procedure Crear_Message_Writer_Client(Buf: in out LLU.Buffer_Type; CH: in LLU.End_Point_Type; Coment: in ASU.Unbounded_String);
	procedure Crear_Message_Initialization( Buf: in out LLU.Buffer_Type; Acogido:  in out Boolean );
	procedure Crear_Message_Salida_Client (Buf: in out LLU.Buffer_Type; CH: in LLU.End_Point_Type);
	
end Chat_Messages;
