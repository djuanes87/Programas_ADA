--Alumno: Daniel Juanes Quintana
--Curso: Programacion de sistemans telematicos

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Handlers;
with Ada.Text_IO;
with Latest_Msgs;
with Types;

package body Chat_Messages is

	use type Types.Seq_N_T;


	procedure Crear_Message_Init(Buf : in out LLU.Buffer_Type; EP_H_Creat: in LLU.End_Point_Type; Seq_N : in out Types.Seq_N_T; EP_H_Rsnd: in LLU.End_Point_Type; EP_R_Creat: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String) is
		S : Types.Seq_N_T := 1;
	begin
		LLU.Reset(Buf);
		Message_Type'Output(Buf'Access, Init);
		LLU.End_Point_Type'Output(Buf'Access, EP_H_Creat);
		if Seq_N = 0 then
			Latest_Msgs.Obtener_Seq_N(Handlers.Lista_Msgs, EP_H_Creat, S);
			Types.Seq_N_T'Output(Buf'Access , S);
			Seq_N := S;
		else
			Types.Seq_N_T'Output(Buf'Access, Seq_N);
		end if;
		LLU.End_Point_Type'Output(Buf'Access, EP_H_Rsnd);
		LLU.End_Point_Type'Output(Buf'Access, EP_R_Creat);
		ASU.Unbounded_String'Output(Buf'Access, Nick);
	end Crear_Message_Init;
	
	procedure Crear_Message_Reject(Buf : in out LLU.Buffer_Type; EP_H_Creat: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String) is
	begin
		LLU.Reset(Buf);
		Message_Type'Output(Buf'Access, Reject);
		LLU.End_Point_Type'Output(Buf'Access, EP_H_Creat);
		ASU.Unbounded_String'Output(Buf'Access, Nick);
	end Crear_Message_Reject;
	
	procedure Crear_Message_Confirm(Buf : in out LLU.Buffer_Type; EP_H_Creat: in LLU.End_Point_Type; Seq_N : in out Types.Seq_N_T; EP_H_Rsnd: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String) is
		S: Types.Seq_N_T := 1;
	begin
		LLU.Reset(Buf);
		Message_Type'Output(Buf'Access, Confirm);
		LLU.End_Point_Type'Output(Buf'Access, EP_H_Creat);
		if Seq_N = 0 then
			Latest_Msgs.Obtener_Seq_N(Handlers.Lista_Msgs, EP_H_Creat ,S);
			Types.Seq_N_T'Output(Buf'Access , S);
			Seq_N := S;			
		else
			Types.Seq_N_T'Output(Buf'Access, Seq_N);
		end if;
		LLU.End_Point_Type'Output(Buf'Access, EP_H_Rsnd);
		ASU.Unbounded_String'Output(Buf'Access, Nick);
	end Crear_Message_Confirm;
	
	procedure Crear_Message_Writer (Buf : in out LLU.Buffer_Type; EP_H_Creat: in LLU.End_Point_Type; Seq_N : in out Types.Seq_N_T; EP_H_Rsnd: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String; Comment: in ASU.Unbounded_String) is
		S: Types.Seq_N_T := 1;
	begin
		LLU.Reset(Buf);
		Message_Type'Output(Buf'Access, Writer);
		LLU.End_Point_Type'Output(Buf'Access, EP_H_Creat);
		if Seq_N = 0 then
			Latest_Msgs.Obtener_Seq_N(Handlers.Lista_Msgs, EP_H_Creat ,S);
			Types.Seq_N_T'Output(Buf'Access , S);
			Seq_N := S;
		else
			Types.Seq_N_T'Output(Buf'Access, Seq_N);
		end if;
		LLU.End_Point_Type'Output(Buf'Access, EP_H_Rsnd);
		ASU.Unbounded_String'Output(Buf'Access, Nick);
		ASU.Unbounded_String'Output(Buf'Access, Comment);
	end Crear_Message_Writer;
	
	procedure Crear_Message_Logout (Buf: in out LLU.Buffer_Type; EP_H_Creat: in LLU.End_Point_Type; Seq_N : in out Types.Seq_N_T; EP_H_Rsnd: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String; Confirm_Sent: in Boolean ) is
		S : Types.Seq_N_T := 1;
	begin
		LLU.Reset(Buf);
		Message_Type'Output(Buf'Access, Logout);
		LLU.End_Point_Type'Output(Buf'Access, EP_H_Creat);
		if Seq_N = 0 then
			Latest_Msgs.Obtener_Seq_N(Handlers.Lista_Msgs, EP_H_Creat ,S);
			Types.Seq_N_T'Output(Buf'Access , S);
			Seq_N := S;
		else
			Types.Seq_N_T'Output(Buf'Access, Seq_N);
		end if;
		LLU.End_Point_Type'Output(Buf'Access, EP_H_Rsnd);
		ASU.Unbounded_String'Output(Buf'Access, Nick);
		Boolean'Output(Buf'Access, Confirm_Sent);	
	end Crear_Message_Logout;
	
		procedure Crear_Message_Ack (Buf: in out LLU.Buffer_Type; EP_H_ACKer: in LLU.End_Point_Type; EP_H_Creat: in LLU.End_Point_Type; Seq_N : in Types.Seq_N_T) is
		
	begin
		LLU.Reset(Buf);
		Message_Type'Output(Buf'Access, Ack);
		LLU.End_Point_Type'Output(Buf'Access, EP_H_ACKer);
		LLU.End_Point_Type'Output(Buf'Access, EP_H_Creat);
		Types.Seq_N_T'Output(Buf'Access, Seq_N);	
	end Crear_Message_Ack;
	
	procedure Enviar_Message_Reject (Buf: in out LLU.Buffer_Type; EP_R : in LLU.End_Point_Type) is
	
	begin
		LLU.Send(EP_R, Buf'Access);
	end Enviar_Message_Reject;

end Chat_Messages;
