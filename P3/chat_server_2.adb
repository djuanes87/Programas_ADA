--Alumno: Daniel Juanes Quintana
--Clase: Programacion de Sistemas Telematicos

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Command_Line;
with Users;
with Chat_Messages;
with Ada.Exceptions;

procedure Chat_Server_2 is
	
	Usage_Error: exception;
	Num_Users_Error: exception;

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	
	use type LLU.End_Point_Type;
	use type CM.Message_Type;
	
	procedure Enviar_Message_Acogido (Buf: in out LLU.Buffer_Type; CR: in LLU.End_Point_Type; A: in Boolean) is
	
	begin
		CM.Message_Type'Output(Buf'Access, CM.Welcome);
		Boolean'Output(Buf'Access, A);
		LLU.Send(CR, Buf'Access);
	end Enviar_Message_Acogido;
	
	procedure Enviar_Mensaje_Nuevo_Usuario(Buf: in out LLU.Buffer_Type; Usuarios: in out Users.Lista_Clients; Cont_Users: in Integer; nickname: in ASU.Unbounded_String) is
		Client_Handler : LLU.End_Point_Type;
	begin
		for K in 1.. (Cont_Users) loop
			LLU.Reset(Buf);
			Users.Conseguir_Handler(Usuarios, K, Client_Handler);
			CM.Message_Type'Output(Buf'Access , CM.Server);
			ASU.Unbounded_String'Output(Buf'Access , ASU.To_Unbounded_String("Servidor"));
			ASU.Unbounded_String'Output(Buf'Access, (ASU.To_Unbounded_String(ASU.To_String(nickname) & (" ha entrado en el chat"))));
			LLU.Send(Client_Handler, Buf'Access);
		end loop;
	end Enviar_Mensaje_Nuevo_Usuario;
	
	procedure Reenviar_Mensaje(Buf: in out LLU.Buffer_Type; Usuarios: in Users.Lista_Clients; CEPH: in LLU.End_Point_Type; Cont_Users: in Integer) is
		Handler_Enviar: LLU.End_Point_Type;
	begin
		for K in 1..Cont_Users loop
			Users.Conseguir_Handler(Usuarios, K, Handler_Enviar);
			if CEPH /=  Handler_Enviar then
				LLU.Send(Handler_Enviar, Buf'Access);
			end if;
		end loop;	
	end Reenviar_Mensaje;
	
	procedure Enviar_Mensaje_Salida_User(Buf: in out LLU.Buffer_Type; Usuarios: in Users.Lista_Clients; Cont_Users: in Integer) is
		Client_Handler : LLU.End_Point_Type;
	begin
		for K in 1..Cont_Users loop
			Users.Conseguir_Handler(Usuarios, K, Client_Handler);
			LLU.Send(Client_Handler, Buf'Access);
		end loop;
	end Enviar_Mensaje_Salida_User;

	Server_EP: LLU.End_Point_Type;
	Client_EP_Receive: LLU.End_Point_Type;
	Client_EP_Handler: LLU.End_Point_Type;
	Buffer : aliased LLU.Buffer_Type(1024);
	Nick_Client: ASU.Unbounded_String;
	IP_Server : ASU.Unbounded_String;
	Max_Users: Integer;
	Cont_Users: Integer;
	Expired: Boolean;
	Mess : CM.Message_Type;
	Acogido: Boolean;
	Lista_Users: Users.Lista_Clients;
	Existe: Boolean;
	Expulsado_EP: LLU.End_Point_Type;
	Nick_Expulsado: ASU.Unbounded_String;

begin
	
	Cont_Users := 0;
	
	if Ada.Command_Line.Argument_Count /= 2 then
		raise Usage_Error;
	end if;
	
	if Integer'Value(Ada.Command_Line.Argument(2)) < 2 or  Integer'Value(Ada.Command_Line.Argument(2)) > 50 then
		raise Num_Users_Error;
	end if;
	
	IP_Server := ASU.To_Unbounded_String(LLU.Get_Host_Name);
	IP_Server := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(IP_Server)));
	Server_EP := LLU.Build(ASU.To_String(IP_Server), integer'value(Ada.Command_Line.Argument(1)));
	Max_Users := Integer'Value(Ada.Command_Line.Argument(2));
	LLU.Bind(Server_EP);
	
	loop
		
		LLU.Reset(Buffer);
		
		LLU.Receive (Server_EP, Buffer'Access, 1000.0, Expired);
		
		if Expired then
			Ada.Text_IO.Put_Line("Plazo expirado, vuelvo a intentarlo");
		else
			Mess := CM.Message_Type'Input(Buffer'Access);
			
			case Mess is
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				when CM.Init =>
				
					Client_EP_Receive := LLU.End_Point_Type'Input(Buffer'Access);
					Client_EP_Handler := LLU.End_Point_Type'Input(Buffer'Access);
					Nick_Client := ASU.Unbounded_String'Input(Buffer'Access);
					
					if Cont_Users > 0 then
						Acogido := Users.Comprobar_Nick(Lista_Users, Nick_Client, Cont_Users);
					else
						Acogido := True;
					end if;
					
					if Acogido then
						if Cont_Users >= Max_Users then
							Users.Expulsar_User(Lista_Users, Max_Users, Expulsado_EP, Nick_Expulsado);
							Ada.Text_IO.Put_Line("Ha sido expulsado  " & ASU.To_String(Nick_Expulsado));
							Cont_Users := Cont_Users - 1;
							CM.Crear_Message_Expulsado(Buffer, Nick_Expulsado);
							LLU.Send(Expulsado_EP, Buffer'Access);
							Reenviar_Mensaje(Buffer, Lista_Users, Expulsado_EP, Cont_Users);
						end if;
						LLU.Reset(Buffer);
						Enviar_Mensaje_Nuevo_Usuario( Buffer, Lista_Users, Cont_Users, Nick_Client);
						Cont_Users := Cont_Users + 1;
						Users.Almacenar( Lista_Users, Client_EP_Handler, Nick_Client, Cont_Users); 
						Ada.Text_IO.Put_Line("recibido mensaje inicial de " & ASU.To_String(Nick_Client) & ": Aceptado");
					else
						Ada.Text_IO.Put_Line("recibido mensaje inicial de " & ASU.To_String(Nick_Client) & ": Rechazado");
					end if;
					
					LLU.Reset(Buffer);
					Enviar_Message_Acogido(Buffer, Client_EP_Receive, Acogido);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------					
				when CM.Writer =>
					Client_EP_Handler := LLU.End_Point_Type'Input (Buffer'Access);
					Users.Comprobar_User(Lista_Users, Client_EP_Handler, Nick_Client, Cont_Users, Existe);
					If Existe then
						CM.Crear_Message_Writer_Server (Buffer, Nick_Client);
						Reenviar_Mensaje(Buffer, Lista_Users, Client_EP_Handler, Cont_Users);
					end if;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------					
				when CM.Logout =>
					Client_EP_Handler := LLU.End_Point_Type'Input(Buffer'Access); 
					Users.Comprobar_User(Lista_Users, Client_EP_Handler, Nick_Client, Cont_Users, Existe);
					if Existe then
						Users.Borrar_Cliente(Lista_Users, Client_EP_Handler, Cont_Users);
						Ada.Text_IO.Put_Line("recibido mensaje de salida de " & ASU.To_String(Nick_Client));
						Cont_Users := Cont_Users - 1;
						LLU.Reset(Buffer);
						CM.Crear_Message_Salida_Server(Buffer, Nick_Client);
						Enviar_Mensaje_Salida_User(Buffer, Lista_Users, Cont_Users);
					end if;	
				when others =>
					Ada.Text_IO.Put_Line("Se ha recibido un mensaje no valido");
					
			end case;
			
		end if;
		
	end loop;

	exception
		when Usage_Error =>
			Ada.Text_IO.Put_Line("Commandos mal introducidos, se deben meter: <Puerto> <nºclientes>");
			LLU.Finalize;
		when Num_Users_Error =>
			Ada.Text_IO.Put_Line("El numero de clientes a de ser entre 2 y 50 ambos inclusibe");
			LLU.Finalize;
		when Except:others =>
			Ada.Text_IO.Put_Line("Excepcion Imprevista " & Ada.Exceptions.Exception_Name(Except) & " en: " & Ada.Exceptions.Exception_Message(Except));
			LLU.Finalize;
	
end Chat_Server_2;
