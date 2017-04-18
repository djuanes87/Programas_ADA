--Alumno: Daniel Juanes Quintana
--Curso: Programacion de sistemans telematicos

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Neighbors;
with Latest_Msgs;

package Handlers is 

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	
	Lista_Neighbors : Neighbors.List_Protected_Neighbors;
	Lista_Msgs : Latest_Msgs.List_Protected_Msgs;
	
	function Comprobar_Nick (Nick : ASU.Unbounded_String) return Boolean;
	procedure Cliente_Handler (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type);
	
end Handlers;
