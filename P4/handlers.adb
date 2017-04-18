--Alumno: Daniel Juanes Quintana
--Curso: Programacion de sistemans telematicos

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Lower_Layer_UDP;
with Chat_Messages;
with Neighbors;
with Latest_Msgs;
with Ada.Exceptions;

package body Handlers is 


	package CM renames Chat_Messages;
	
	use type CM.Message_Type;
	use type LLU.End_Point_Type;
	
	function Comprobar_Nick (Nick : ASU.Unbounded_String) return Boolean is
	
	begin
		return ASU.To_String(Nick) = Ada.Command_Line.Argument(2);
	end Comprobar_Nick;
	
	procedure Cliente_Handler (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
		
		--Contenido de los mensajes
		Buffer : aliased LLU.Buffer_Type(1024);
		Mess: CM.Message_Type;
		EP_H_Creat : LLU.End_Point_Type;
		EP_R_Creat : LLU.End_Point_Type;
		EP_H_Rsnd : LLU.End_Point_Type;
		Nick : ASU.Unbounded_String;
		Request : ASU.Unbounded_String;
		Seq_N : CM.Seq_N_T;
		Confirm_Sent: Boolean;
		
		--Variables
		Repetido : Boolean;
		Ocupado : Boolean;
		
	begin
		Repetido := False;
		Ocupado := False; 
		Mess := CM.Message_Type'Input(P_Buffer);
		if Mess = CM.Reject then
			Ada.Text_IO.Put_Line("Se ha recibido un mensaje Reject no valido");
			Repetido := True;
		else
			EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer);
			Seq_N := CM.Seq_N_T'Input(P_Buffer);
			Latest_Msgs.Comprobar_Message_Repetido (Lista_Msgs, EP_H_Creat, Seq_N, Mess,Repetido);
		end if;
		if not Repetido then
			EP_H_Rsnd :=  LLU.End_Point_Type'Input(P_Buffer);
			case Mess is
				when CM.Init =>
					EP_R_Creat := LLU.End_Point_Type'Input(P_Buffer);
					Nick := ASU.Unbounded_String'Input (P_Buffer);
					Ocupado := Comprobar_Nick (Nick);
					if EP_H_Creat = EP_H_Rsnd then
						Neighbors.Almacenar_Neighbor(Lista_Neighbors, EP_H_Creat);
					end if;
					if Ocupado then
						CM.Crear_Message_Reject(Buffer, To, Nick);
					else
						CM.Crear_Message_Init(Buffer, EP_H_Creat, Seq_N, To, EP_R_Creat, Nick);
					end if;
				when CM.Confirm =>
					Nick := ASU.Unbounded_String'Input(P_Buffer);
					Ada.Text_IO.Put_Line("Nuevo Usuario: " & ASU.To_String(Nick));
					CM.Crear_Message_Confirm(Buffer, EP_H_Creat, Seq_N, To, Nick);				
				when CM.Writer =>
					Nick := ASU.Unbounded_String'Input(P_Buffer);
					Request := ASU.Unbounded_String'Input(P_Buffer);
					Ada.Text_IO.Put_Line(ASU.To_String(Nick) & ": " & ASU.To_String(Request));
					CM.Crear_Message_Writer(Buffer, EP_H_Creat, Seq_N, To, Nick, Request);
				when CM.Logout =>
					Nick := ASU.Unbounded_String'Input(P_Buffer);
					Confirm_Sent := Boolean'Input(P_Buffer);
					if Confirm_Sent then
						Ada.Text_IO.Put_Line(ASU.To_String(Nick) & " ha salido del chat");
					end if;
					if EP_H_Creat = EP_H_Rsnd then
						Neighbors.Delete_Neighbor(Lista_Neighbors, EP_H_Rsnd); 
					end if;
					Latest_Msgs.Delete_Latest_Msg(Lista_Msgs, EP_H_Creat);
					CM.Crear_Message_Logout(Buffer, EP_H_Creat, Seq_N, To, Nick, Confirm_Sent);
				when others =>	
					Ada.Text_IO.Put_Line("Alguien ha enviado un mensaje no valido");	
			end case;
			if Ocupado then
				CM.Enviar_Message_Reject(Buffer, EP_R_Creat);
			else
				Neighbors.Enviar_Message(Lista_Neighbors, Buffer, EP_H_Rsnd);
			end if;
		else
		--Comprueba que si el mensaje es Init se ha añadido como vecino y si es Logout comprueba que se ha eliminado
		--Todo esto es caso de recibir un mensaje que toma como repetido
			EP_H_Rsnd :=  LLU.End_Point_Type'Input(P_Buffer);
			if (Mess = CM.Init or Mess = CM.Logout) and EP_H_Creat = EP_H_Rsnd then
				Neighbors.Comprobar_EP_Vecino(Lista_Neighbors, EP_H_Creat, Mess);
			end if;			
		end if;
	exception
	when Except:others =>
		Ada.Text_IO.Put_Line("Excepcion imprevista " & Ada.Exceptions.Exception_Name(Except) & " en: " & Ada.Exceptions.Exception_Message(Except));
		LLU.Finalize;			
	end Cliente_Handler;
	
	
end Handlers;
