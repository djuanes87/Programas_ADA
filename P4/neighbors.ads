--Alumno: Daniel Juanes Quintana
--Curso: Programacion de sistemans telematicos

with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Unchecked_Deallocation;
with Chat_Messages;

package Neighbors is

	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;
	
	type List_Protected_Neighbors is limited private;
	
	procedure Almacenar_Neighbor (Vecinos : in out List_Protected_Neighbors; EP_Handler : in LLU. End_Point_Type);
	procedure Enviar_Message (Vecinos: in out List_Protected_Neighbors; Buf : in out LLU.Buffer_Type; EP_H_Rsnd: in LLU.End_Point_Type);
	procedure Delete_Neighbor (Vecinos: in out List_Protected_Neighbors; EP_H_Creat: in LLU.End_Point_Type);
	procedure Comprobar_EP_Vecino (Vecinos: in out List_Protected_Neighbors; EP_H_Creat: in LLU.End_Point_Type; Mess : in CM.Message_Type);
	
private

	type Datos_Neighbor;
	
	type Acceso_Neighbor is access Datos_Neighbor;
		
	type Datos_Neighbor is record
		EP_H_Nodo : LLU.End_Point_Type;
		Next: Acceso_Neighbor;
	end record;
	
	procedure Free is new Ada.Unchecked_Deallocation (Datos_Neighbor, Acceso_Neighbor);
	
	protected type List_Protected_Neighbors is
	
		procedure Almacenar_Neighbor (EP_Handler : in  LLU.End_Point_Type);
		procedure Enviar_Message (Buf : in out LLU.Buffer_Type; EP_H_Rsnd: in LLU.End_Point_Type);
		procedure Delete_Neighbor (EP_H_Creat: in LLU.End_Point_Type);
		procedure Comprobar_EP_Vecino (EP_H_Creat: in LLU.End_Point_Type; Mess : in CM.Message_Type);
		
	private
		The_List  : Acceso_Neighbor := null;
	end List_Protected_Neighbors;

end Neighbors;
