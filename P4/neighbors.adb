--Alumno: Daniel Juanes Quintana
--Curso: Programacion de sistemans telematicos

with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Unchecked_Deallocation;
with Ada.Text_IO;
with Chat_Messages;



package body Neighbors is

	use type LLU.End_Point_Type;
	use type CM.Message_Type;

	protected body List_Protected_Neighbors is
		
		procedure Almacenar_Neighbor (EP_Handler : in LLU. End_Point_Type) is
			P_Aux : Acceso_Neighbor;
		begin
			P_Aux := new Datos_Neighbor;
			P_Aux.EP_H_Nodo :=  EP_Handler;
			P_Aux.Next := The_List;
			The_List := P_Aux;
		end Almacenar_Neighbor;
		
		procedure Enviar_Message (Buf : in out LLU.Buffer_Type; EP_H_Rsnd: in LLU.End_Point_Type) is
			P_Aux : Acceso_Neighbor;
		begin
			P_Aux := The_List;
			while P_Aux /= null loop
				if P_Aux.EP_H_Nodo /= EP_H_Rsnd then
					LLU.Send(P_Aux.EP_H_Nodo, Buf'Access);
				end if;
				P_Aux := P_Aux.Next;
			end loop;
		end Enviar_Message;
	
		procedure Delete_Neighbor (EP_H_Creat: in LLU.End_Point_Type) is
			P_Aux : Acceso_Neighbor;
			P_Delete : Acceso_Neighbor;
		begin
			P_Aux := The_List;
			while P_Aux.EP_H_Nodo /= EP_H_Creat loop
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
		end Delete_Neighbor;
		
		--Comprueba el la EP_H que se le pasa, si el mensaje era repetido y por algun
		--motivo recibe el mensaje de otro nodo antes que del vecino
		procedure Comprobar_EP_Vecino (EP_H_Creat: in LLU.End_Point_Type; Mess : in CM.Message_Type) is
			P_Aux : Acceso_Neighbor;
			Encontrado : Boolean;
		begin
			P_Aux := The_List;
			Encontrado := False;
			while P_Aux /= null and not Encontrado loop
				if P_Aux.EP_H_Nodo = EP_H_Creat then
					Encontrado := True;
				end if;	
				P_Aux := P_Aux.Next;		
			end loop;
			if not Encontrado then
				if Mess = CM.Init then --Almacena el Vecino que en teoria tiene que estar almacenado
					Almacenar_Neighbor(EP_H_Creat);
				end if;
			else
				if Mess = CM.Logout then --Elimina el Vecino que en teoria tiene que estar eliminado
					Delete_Neighbor(EP_H_Creat);
				end if;
			end if;
		end Comprobar_EP_Vecino; 
		
	end List_Protected_Neighbors;
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	procedure Almacenar_Neighbor (Vecinos : in out List_Protected_Neighbors; EP_Handler : in LLU. End_Point_Type) is
	
	begin
		Vecinos.Almacenar_Neighbor(EP_Handler);
	end Almacenar_Neighbor;
	
	procedure Enviar_Message (Vecinos : in out List_Protected_Neighbors; Buf : in out LLU.Buffer_Type; EP_H_Rsnd: in LLU.End_Point_Type) is
	
	begin
		Vecinos.Enviar_Message(Buf, EP_H_Rsnd);
	end Enviar_Message;
	
	procedure Delete_Neighbor (Vecinos: in out List_Protected_Neighbors; EP_H_Creat: in LLU.End_Point_Type) is
	
	begin
		Vecinos.Delete_Neighbor(EP_H_Creat);
	end Delete_Neighbor;
	
	procedure Comprobar_EP_Vecino (Vecinos: in out List_Protected_Neighbors; EP_H_Creat: in LLU.End_Point_Type; Mess : in CM.Message_Type) is
	
	begin
		Vecinos.Comprobar_EP_Vecino(EP_H_Creat, Mess);
	end Comprobar_EP_Vecino;

end Neighbors;
