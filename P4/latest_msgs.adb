--Alumno: Daniel Juanes Quintana
--Curso: Programacion de sistemans telematicos

with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Unchecked_Deallocation;
with Ada.Text_IO;

package body Latest_Msgs is

	use type LLU.End_Point_Type;
	use type CM.Message_Type;
	use type CM.Seq_N_T;


	protected body List_Protected_Msgs is
	
		--Este se ejecuta al crear un mensaje el programa principal y tener asi un Seq_N nuevo
		procedure Obtener_Seq_N (EP_H_Creat : in LLU. End_Point_Type; S : in out CM.Seq_N_T) is
			P_Aux : Acceso_Latest_Msgs;
		begin
			P_Aux := The_List;
			while  P_Aux /= null and then P_Aux.EP_H /= EP_H_Creat loop
				P_Aux := P_Aux.Next;
			end loop;
			if P_Aux = null then
				P_Aux := new Datos_Latest_Msgs;
				P_Aux.EP_H :=  EP_H_Creat;
				P_Aux.Seq_N := S;
				P_Aux.Next := The_List;
				The_List := P_Aux;
				S := P_Aux.Seq_N;
			elsif P_Aux.EP_H = EP_H_Creat then
				P_Aux.Seq_N := P_Aux.Seq_N +1;
				S := P_Aux.Seq_N;
			end if;
		end Obtener_Seq_N;
		
		
		procedure Comprobar_Message_Repetido(EP_H_Creat: in LLU.End_Point_Type; S: in out CM.Seq_N_T; Mess : in CM.Message_Type; Repetido: in out Boolean) is
			P_Aux : Acceso_Latest_Msgs;
		begin
			P_Aux := The_List;
			while P_Aux /= null and then P_Aux.EP_H /= EP_H_Creat loop
				P_Aux := P_Aux.Next;
			end loop;
			if Mess = CM.Logout then
				if P_Aux = null then
					Repetido := True;
				end if;
			else
				if P_Aux = null then
					Obtener_Seq_N(EP_H_Creat, S);
				elsif P_Aux.EP_H = EP_H_Creat and P_Aux.Seq_N >= S then
					Repetido := True;
				else
					P_Aux.Seq_N := S;
				end if;
			end if;
			
		end Comprobar_Message_Repetido;
	
		procedure Delete_Latest_Msg (EP_H_Creat: in LLU.End_Point_Type) is
			P_Aux : Acceso_Latest_Msgs;
			P_Delete : Acceso_Latest_Msgs;
		begin
			P_Aux := The_List;
			while P_Aux.EP_H /= EP_H_Creat loop
				P_Aux := P_Aux.Next;
			end loop;
			P_Delete := P_Aux;
			P_Aux := The_List;
			if P_Aux = P_Delete then
				The_List := P_Aux.Next;
			else
				while P_Delete /= P_Aux.Next loop
					P_Aux := P_Aux.Next;
				end loop;
				P_Aux.Next := P_Delete.Next;
			end if;
			Free(P_Delete);
		end Delete_Latest_Msg;
		
	end List_Protected_Msgs;
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	procedure Obtener_Seq_N (List : in out List_Protected_Msgs; EP_H_Creat : in LLU. End_Point_Type; S : in out CM.Seq_N_T) is
		
	begin
		List.Obtener_Seq_N(EP_H_Creat, S);
	end Obtener_Seq_N ;
		
		
	procedure Comprobar_Message_Repetido(List: in out List_Protected_Msgs; EP_H_Creat: in LLU.End_Point_Type; S: in out CM.Seq_N_T ; Mess : in CM.Message_Type; Repetido	: in out Boolean) is
		
	begin
		List.Comprobar_Message_Repetido(EP_H_Creat, S, Mess, Repetido);
	end Comprobar_Message_Repetido;
	
	procedure Delete_Latest_Msg (List: in out List_Protected_Msgs; EP_H_Creat: in LLU.End_Point_Type) is
	begin
		List.Delete_Latest_Msg(EP_H_Creat);
	end Delete_Latest_Msg;
		
end Latest_Msgs;
