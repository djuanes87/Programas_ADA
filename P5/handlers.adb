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
with Ada.Calendar;

with Sender_Buffering;
with Timed_Handlers;
with Types;

package body Handlers is 


	package CM renames Chat_Messages;
	package LM renames Latest_Msgs;
	package SB renames Sender_Buffering;
	
	use type CM.Message_Type;
	use type LLU.End_Point_Type;
	use type LM.Status_Time_Type;
	
	function Comprobar_Nick (Nick : ASU.Unbounded_String) return Boolean is
	
	begin
		return ASU.To_String(Nick) = Ada.Command_Line.Argument(2);
	end Comprobar_Nick;
	
	procedure Send_Message_Temp (T: in Ada.Calendar.Time) is
		Future_Time: Ada.Calendar.Time;
		Success : Boolean;
	begin
		Success := False;
		if Max_Delay /= 0 then
			Future_Time := Ada.Calendar."+"(2*Duration(Max_Delay)/1000, T);
		else
			Future_Time := Ada.Calendar."+"(2*Duration(1.0)/1000, T);
		end if;
		SB.Send_Message(Lista_Acks, T, Future_Time, Success);
		if Success then
			Timed_Handlers.Set_Timed_Handler(Future_Time, Send_Message_Temp'Access);
		end if;		
	end Send_Message_Temp;
	
	procedure Wait_End_List (T: in Ada.Calendar.Time) is
		Temp : Ada.Calendar.Time;
	begin
		while not SB.Is_Empty(Lista_Acks) loop
			SB.Comprobar_Temp(Lista_Acks, Temp);
			Timed_Handlers.Set_Timed_Handler(Temp, Wait_End_List'Access);
		end loop;
	end Wait_End_List;
	
	procedure Cliente_Handler (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
		
		--Contenido de los mensajes
		Buffer : aliased LLU.Buffer_Type(1024);
		Mess: CM.Message_Type;
		EP_H_Creat : LLU.End_Point_Type;
		EP_R_Creat : LLU.End_Point_Type;
		EP_H_Rsnd : LLU.End_Point_Type;
		Nick : ASU.Unbounded_String;
		Request : ASU.Unbounded_String;
		Seq_N : Types.Seq_N_T;
		Confirm_Sent: Boolean;
		
		--Datos Acks
		Buffer_Ack : aliased LLU.Buffer_Type(1024);
		EP_H_ACKer: LLU.End_Point_Type;
		EP_H_Creat_ACKer : LLU.End_Point_Type;
		Seq_N_ACKer : Types.Seq_N_T;
		
		--Variables
		Estado : LM.Status_Time_Type;
		Ocupado : Boolean;
		
		
		Future_Time: Ada.Calendar.Time;
		
	begin
		Estado := LM.Present;
		Ocupado := False; 
		Mess := CM.Message_Type'Input(P_Buffer);
		if Mess = CM.Reject then
			Ada.Text_IO.Put_Line("Se ha recibido un mensaje Reject no valido");
			Estado := LM.Back;
		elsif Mess /= CM.Reject and Mess /= CM.Ack then
			EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer);
			Seq_N := Types.Seq_N_T'Input(P_Buffer);
			EP_H_Rsnd :=  LLU.End_Point_Type'Input(P_Buffer);
			CM.Crear_Message_Ack(Buffer_Ack, To, EP_H_Creat, Seq_N);
			Latest_Msgs.Comprobar_Message_Repetido (Lista_Msgs, EP_H_Creat, Seq_N, Mess, Estado);
			if Estado /= LM.Future then
				LLU.Send(EP_H_Rsnd, Buffer_Ack'Access);
			end if;
		end if;
		if Estado /= LM.Back then
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
					if Estado = LM.Present then
						Ada.Text_IO.Put_Line("Nuevo Usuario: " & ASU.To_String(Nick));
					end if;
					CM.Crear_Message_Confirm(Buffer, EP_H_Creat, Seq_N, To, Nick);				
				when CM.Writer =>
					Nick := ASU.Unbounded_String'Input(P_Buffer);
					Request := ASU.Unbounded_String'Input(P_Buffer);
					if Estado = LM.Present then
						Ada.Text_IO.Put_Line(ASU.To_String(Nick) & ": " & ASU.To_String(Request));
					end if;
					CM.Crear_Message_Writer(Buffer, EP_H_Creat, Seq_N, To, Nick, Request);
				when CM.Logout =>
					Nick := ASU.Unbounded_String'Input(P_Buffer);
					Confirm_Sent := Boolean'Input(P_Buffer);
					if Estado = LM.Present then
						if Confirm_Sent then
							Ada.Text_IO.Put_Line(ASU.To_String(Nick) & " ha salido del chat");
						end if;
						if EP_H_Creat = EP_H_Rsnd then
							Neighbors.Delete_Neighbor(Lista_Neighbors, EP_H_Rsnd); 
						end if;
						Latest_Msgs.Delete_Latest_Msg(Lista_Msgs, EP_H_Creat);
					end if;
					CM.Crear_Message_Logout(Buffer, EP_H_Creat, Seq_N, To, Nick, Confirm_Sent);
				when CM.Ack =>	
					EP_H_ACKer := LLU.End_Point_Type'Input(P_Buffer);
					EP_H_Creat_ACKer := LLU.End_Point_Type'Input(P_Buffer);
					Seq_N_ACKer := Types.Seq_N_T'Input(P_Buffer);
					SB.Comprobar_Ack_Receive(Lista_Acks, EP_H_Creat_ACKer, Seq_N_ACKer, EP_H_ACKer);
				when others =>	
					Ada.Text_IO.Put_Line("Alguien ha enviado un mensaje no valido");
			end case;
			if Ocupado then
				CM.Enviar_Message_Reject(Buffer, EP_R_Creat);
			elsif not Ocupado and Mess /= CM.Ack then
				Future_Time := Ada.Calendar.Clock;
				SB.Introducir_Ack_Arbol(Lista_Acks, Lista_Neighbors, Future_Time, EP_H_Creat, Seq_N, EP_H_Rsnd, Buffer);
				Send_Message_Temp(Future_Time);
			end if;
		else
			if (Mess = CM.Init or Mess = CM.Logout) and EP_H_Creat = EP_H_Rsnd then
				Neighbors.Comprobar_EP_Vecino(Lista_Neighbors, EP_H_Creat, Mess);
			end if;			
		end if;
	exception
	when Except:others =>
		Ada.Text_IO.Put_Line("Excepcion imprevista " & Ada.Exceptions.Exception_Name(Except) & " en: " & Ada.Exceptions.Exception_Message(Except));
		LLU.Finalize;
		Timed_Handlers.Finalize;			
	end Cliente_Handler;
	
	
end Handlers;
