--Alumno: Daniel Juanes Quintana
--Curso: Programacion de sistemans telematicos

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Neighbors;
with Latest_Msgs;
with Sender_Buffering;
with Ada.Calendar;

package Handlers is 

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	
	Lista_Neighbors : Neighbors.List_Protected_Neighbors;
	Lista_Msgs : Latest_Msgs.List_Protected_Msgs;
	Lista_ACKs : Sender_Buffering.Map;
	Max_Delay : Integer;
	Min_Delay : Integer;
	Fault_Pct : Integer;
	
	function Comprobar_Nick (Nick : ASU.Unbounded_String) return Boolean;
	--Temporiza el mensaje para enviar
	procedure Send_Message_Temp (T: in Ada.Calendar.Time);
	--Comprueba que el arbol esta vacio
	procedure Wait_End_List (T: in Ada.Calendar.Time);
	procedure Cliente_Handler (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type);
	
end Handlers;
