-- Alumno: Daniel Juanes Quintana
--Clase: Programacion de sistemas telematicos
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
	
package body Chat_Messages is
	
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;

	-- Se encarga de crear los buffer que se enviaran desde el servidor a los equipos con nick lector
	procedure Crear_Buffer_Server (buf : in out LLU.Buffer_Type ; N: in ASU.Unbounded_String; C: in ASU.Unbounded_String) is
		
	begin
		Message_Type'Output(Buf'Access, Server);
		ASU.Unbounded_String'Output(Buf'Access, N);
		ASU.Unbounded_String'Output(Buf'Access, C);
	end;
	
	-- Se encarga de crear los buffer que se enviaran desde los clientes al servidor
	procedure Crear_Buffer_Client (buf : in out LLU.Buffer_Type ;M: in Message_Type; Client: in LLU.End_Point_Type; C: in ASU.Unbounded_String) is

	begin
		Message_Type'Output(Buf'Access, M);
		LLU.End_Point_Type'Output(Buf'Access, Client);
		ASU.Unbounded_String'Output(Buf'Access, C);
	end;
	
end Chat_Messages;
