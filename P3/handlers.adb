--Alumno: Daniel Juanes Quintana
--Clase: Programacion de Sistemas Telematicos

with Ada.Text_IO;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Chat_Messages;

package body Handlers is

	
	procedure Client_Handler (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
	
		Mess : CM.Message_Type;
		Nick : ASU.Unbounded_String;
		Request : ASU.Unbounded_String;
		
		begin
		
			Mess := CM.Message_Type'Input(P_Buffer);
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Request := ASU.Unbounded_String'Input(P_Buffer);
			LLU.Reset(P_Buffer.all);
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line(ASU.To_String(Nick) & ": " & ASU.To_String(Request));
			Ada.Text_IO.Put(">>");
		
		end Client_Handler;
		
end Handlers;
		
