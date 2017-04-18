-- Alumno: Daniel Juanes Quintana
--Clase: Programacion de sistemas telematicos

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Exceptions;
with Chat_Messages;

procedure Chat_Client is
	
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package MS renames Chat_Messages;
	
	Usage_Error : exception;
	
	--Para compara tipo Message_Type
	use type MS.Message_Type;
	
	Server_EP: LLU.End_Point_Type;
	Client_EP: LLU.End_Point_Type;
	Buffer: aliased LLU.Buffer_Type(1024);
	Nick: ASU.Unbounded_String;
	Resquest: ASU.Unbounded_String;
	Reply: ASU.Unbounded_String;
	Expired: Boolean;
	Mess: MS.Message_Type;
	Mess_Reiceive: MS.Message_Type;
	Nick_Reiceive: ASU.Unbounded_String;
	Dir_IP: ASU.Unbounded_String;
	
begin
	if Ada.Command_Line.Argument_Count /= 3 then
		raise Usage_Error;
	end if;
	
	Mess := MS.Init;
	Dir_IP := ASU.To_Unbounded_String(LLU.To_IP(Ada.Command_Line.Argument(1)));
	Server_EP := LLU.Build(ASU.To_String(Dir_IP), integer'value(Ada.Command_Line.Argument(2)));
	Nick := ASU.To_Unbounded_String(Ada.Command_Line.Argument(3));
	LLU.Bind_Any(Client_EP);
	LLU.Reset(Buffer);
	
	--Crea el buffer
	MS.Crear_Buffer_Client(Buffer, Mess, Client_EP, Nick);
	
	LLU.Send(Server_EP, Buffer'Access);
	
	--Detecta si es escritor o no
	if ASU.To_String(Nick) /= "lector" then
		Mess := MS.Writer;
	end if;
	
	loop
		LLU.Reset(Buffer);
		--Entra en modo lector
		if Mess = MS.Init then
			LLU.Receive(Client_EP, Buffer'Access, 20.0, Expired);
			if Expired then
				Ada.Text_IO.Put_Line("Plazo expirado");
			else
				--Descompone y muestra el mensaje recibido
				Mess_Reiceive := MS.Message_Type'Input(Buffer'Access);
				Nick_Reiceive := ASU.Unbounded_String'Input(Buffer'Access);
				Reply := ASU.Unbounded_String'Input(Buffer'Access);
				Ada.Text_IO.Put(ASU.To_String(Nick_Reiceive) & ": ");
				Ada.Text_IO.Put(ASU.To_String(Reply));
				Ada.Text_IO.New_Line;
			end if;
		-- Enrta en modo Writer
		else
			-- Permite escribir y enviar el mensaje
			Ada.Text_IO.Put("Mensaje: ");
			Resquest := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
			--Analiza el texto antes de meterlo en el buffer por si es el comando para salir y asi no enviarlo
			exit when ASU.To_String(Resquest) = ".salir";
			MS.Crear_Buffer_Client(Buffer, Mess, Client_EP, Resquest);
			LLU.Send(Server_EP, Buffer'Access);
		end if;
	end loop;

	LLU.Finalize;
	exception
		when Usage_Error =>
			Ada.Text_IO.Put_Line ("Argumentos introducidos no validos, debe ser asi: <servidor> <nºpuerto> <nick>");
			LLU.Finalize;
		when Ex: others =>
			Ada.Text_IO.Put_Line ("Excepcion imprevista: " & Ada.Exceptions.Exception_Name(Ex) & " en:" & Ada.Exceptions.Exception_Message(Ex));
			LLU.Finalize;
end Chat_Client;
