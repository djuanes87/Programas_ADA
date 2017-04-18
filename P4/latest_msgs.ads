--Alumno: Daniel Juanes Quintana
--Curso: Programacion de sistemans telematicos

with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Unchecked_Deallocation;
with Chat_Messages;

package Latest_Msgs is

	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;
	
	type List_Protected_Msgs is limited private;
	
	procedure Obtener_Seq_N (List : in out List_Protected_Msgs; EP_H_Creat : in LLU. End_Point_Type; S : in out CM.Seq_N_T);		
	procedure Comprobar_Message_Repetido(List: in out List_Protected_Msgs; EP_H_Creat: in LLU.End_Point_Type; S: in out CM.Seq_N_T ; Mess : in CM.Message_Type; Repetido: in out Boolean);
	procedure Delete_Latest_Msg (List: in out List_Protected_Msgs; EP_H_Creat: in LLU.End_Point_Type);
	
private

	type Datos_Latest_Msgs;
	
	type Acceso_Latest_Msgs is access Datos_Latest_Msgs;
		
	type Datos_Latest_Msgs is record
		EP_H : LLU.End_Point_Type;
		Seq_N : CM.Seq_N_T;
		Next: Acceso_Latest_Msgs;
	end record;
	
	procedure Free is new Ada.Unchecked_Deallocation (Datos_Latest_Msgs, Acceso_Latest_Msgs);
	
	protected type List_Protected_Msgs is
	
		procedure Obtener_Seq_N (EP_H_Creat : in LLU. End_Point_Type; S :in  out CM.Seq_N_T);
		procedure Comprobar_Message_Repetido(EP_H_Creat: in LLU.End_Point_Type; S: in out CM.Seq_N_T ; Mess : in CM.Message_Type; Repetido: in out Boolean);
		procedure Delete_Latest_Msg (EP_H_Creat: in LLU.End_Point_Type);

	private
		The_List  : Acceso_Latest_Msgs := null;
	end List_Protected_Msgs;

end Latest_Msgs;
