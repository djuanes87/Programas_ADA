--Alumno: Daniel Juanes Quintana
--Curso: Programacion de sistemans telematicos

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Types;

package Chat_Messages is
	
	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;

	type Message_Type is (Init, Reject, Confirm, Writer, Logout, Ack);
	
	
	procedure Crear_Message_Init(Buf : in out LLU.Buffer_Type; EP_H_Creat: in LLU.End_Point_Type; Seq_N : in out Types.Seq_N_T; EP_H_Rsnd: in LLU.End_Point_Type; EP_R_Creat: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String);
	procedure Crear_Message_Reject(Buf : in out LLU.Buffer_Type; EP_H_Creat: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String);
	procedure Crear_Message_Confirm(Buf : in out LLU.Buffer_Type; EP_H_Creat: in LLU.End_Point_Type; Seq_N : in out Types.Seq_N_T; EP_H_Rsnd: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String);
	procedure Crear_Message_Writer (Buf : in out LLU.Buffer_Type; EP_H_Creat: in LLU.End_Point_Type; Seq_N : in out Types.Seq_N_T; EP_H_Rsnd: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String; Comment: in ASU.Unbounded_String);
	procedure Crear_Message_Logout (Buf: in out LLU.Buffer_Type; EP_H_Creat: in LLU.End_Point_Type; Seq_N : in out Types.Seq_N_T; EP_H_Rsnd: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String; Confirm_Sent: in Boolean );
	procedure Crear_Message_Ack (Buf: in out LLU.Buffer_Type; EP_H_ACKer: in LLU.End_Point_Type; EP_H_Creat: in LLU.End_Point_Type; Seq_N : in Types.Seq_N_T);

	procedure Enviar_Message_Reject (Buf: in out LLU.Buffer_Type; EP_R : in LLU.End_Point_Type);

end Chat_Messages;
