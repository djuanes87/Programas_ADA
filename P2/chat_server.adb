-- Alumno: Daniel Juanes Quintana
--Clase: Programacion de sistemas telematicos

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Exceptions;
with Chat_Messages;

procedure Chat_Server is
	
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package MS renames Chat_Messages;
	
	Usage_Error : exception;
	User_Exceed: exception;
	
	use type LLU.End_Point_Type;
	use type MS.Message_Type;
	
	type Data_Client is record
		Client_EP : LLU.End_Point_Type;
		Nick: ASU.Unbounded_String;
	end record;
	
	type List_Client is array (1..50) of Data_Client;
	
	Server_EP : LLU.End_Point_Type;
	Client_EP : LLU.End_Point_Type;
	Buffer: aliased LLU.Buffer_Type(1024);
	IP_Server : ASU.Unbounded_String;
	Resquest : ASU.Unbounded_String;
	Clientes: List_Client;
	Expired: Boolean;
	Cont_Client: Integer;
	Cont : Integer;
	Mess : MS.Message_Type;
	Mess_Init : MS.Message_Type;
	Mess_Writer : MS.Message_Type;
	Nick :  ASU.Unbounded_String;
	Encontrado: Boolean;
	
begin
	Mess_Init := MS.Init;
	Mess_Writer := MS.Writer;

	if Ada.Command_Line.Argument_Count /= 1 then
		raise Usage_Error;
	end if;

	Cont_Client := 0;
	
	--Encuentra la ip del equipo en el que se ejecuta el servidor
	IP_Server := ASU.To_Unbounded_String(LLU.Get_Host_Name);
	IP_Server := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(IP_Server)));
	Server_EP := LLU.Build(ASU.To_String(IP_Server), integer'value(Ada.Command_Line.Argument(1)));
	LLU.Bind(Server_EP);
	
	loop
		Cont := 1;
		Encontrado := False;
		LLU.Reset(Buffer);
		LLU.Receive(Server_EP, Buffer'Access, 1000.0, Expired);
		if Expired then
			Ada.Text_IO.Put_Line("Plazo expirado, vuelvo a intentarlo");
		else
			Mess := MS.Message_Type'Input(Buffer'Access);
		--Comprueba el tipo de mensaje recibido
			--Si es Init muestra el mensaje inicial y mete al nuevo cliente en la lista
			if Mess = Mess_Init then
				Cont_Client := Cont_Client + 1;
				if Cont_Client > 50 then
					raise User_Exceed;
				end if;
				Clientes(Cont_Client).Client_EP := LLU.End_Point_Type'Input(Buffer'Access);
				Clientes(Cont_Client).Nick := ASU.Unbounded_String'Input(Buffer'Access);
				if ASU.To_String(Clientes(Cont_Client).Nick) /= "lector" then
					Ada.Text_IO.Put("recibido mensaje inicial de ");
					Ada.Text_IO.Put(ASU.To_String(Clientes(Cont_Client).Nick));
					Ada.Text_IO.New_Line;
				end if;
			--Si es Writer  descompone el mensaje recibido y se lo envia a los lectores
			elsif Mess = Mess_Writer then
				Client_EP := LLU.End_Point_Type'Input(Buffer'Access);
				Resquest := ASU.Unbounded_String'Input(Buffer'Access);
				--Busca el nick del Cliente que ha enviado en mensaje par poder enviarselo a los lectores
				while not Encontrado loop
					if Client_EP = Clientes(Cont).Client_EP then
						Encontrado := True;
						Nick := Clientes(Cont).Nick;
					end if;
					cont := cont + 1;
				end loop;
				
				--Muestra en el servidor lo que se ha recibido.
				Ada.Text_IO.Put("recibido mensaje de ");
				Ada.Text_IO.Put(ASU.To_String(Nick));
				Ada.Text_IO.Put(":");
				Ada.Text_IO.Put(ASU.To_String(Resquest));
				Ada.Text_IO.New_Line;
				
				LLU.Reset(Buffer);
				MS.Crear_Buffer_Server(Buffer, Nick, Resquest);
				
				--Busca los lectores y les envia el contenido del buffer
				for K in 1 .. Cont_Client loop
					if ASU.To_String(Clientes(K).Nick) = "lector" then
						LLU.Send(Clientes(K).Client_EP, Buffer'Access);
					end if;
				end loop;
			end if;
		end if;

	end loop;
	
	LLU.Finalize;
	exception
		when Usage_Error =>
			Ada.Text_IO.Put_Line ("Es necesario solo introducir el puerto");
			LLU.Finalize;
		when User_Exceed =>
			Ada.Text_IO.Put_Line("Numero de usuarios excedido");
			LLU.Finalize;
		when Ex: others =>
			Ada.Text_IO.Put_Line ("Excepcion imprevista: " & Ada.Exceptions.Exception_Name(Ex) & " en:" & Ada.Exceptions.Exception_Message(Ex));
			LLU.Finalize;
end Chat_Server;
