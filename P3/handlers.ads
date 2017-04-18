--Alumno: Daniel Juanes Quintana
--Clase: Programacion de Sistemas Telematicos

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Chat_Messages;

package Handlers is

	type Message_Type is (Init, Welcome,Writer, Server, Logout);
	
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	
	procedure Client_Handler (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type);
	
end Handlers;
