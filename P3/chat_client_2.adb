--Alumno: Daniel Juanes Quintana
--Clase: Programacion de Sistemas Telematicos

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Command_Line;
with Ada.Exceptions;
with Chat_Messages;
with Handlers;

procedure Chat_Client_2 is

	type Message_Type is (Init, Welcome,Writer, Server, Logout);
	
	Usage_Error: exception;
	Nickname_Error: exception;

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	
	procedure Modo_Writer (buf: in out LLU.Buffer_Type; Server: in LLU.End_Point_Type; CH: in LLU.End_Point_Type) is
	
		coment : ASU.Unbounded_String;
		
	begin
		loop
			LLU.Reset(Buf);
			Ada.Text_IO.Put(">>");
			coment := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
			if ASU.To_String(Coment) = ".salir" then
				CM.Crear_Message_Salida_Client(Buf, CH);
				LLU.Send(Server, Buf'Access);
			end if;
			exit when ASU.To_String(Coment) = ".salir";
			CM.Crear_Message_Writer_Client(buf,CH, Coment);
			LLU.Send(Server, Buf'Access);
		end loop;
		LLU.Reset(Buf);
	end Modo_Writer;
	
	
	
	Client_EP_Receive: LLU.End_Point_Type;
	Client_EP_Handler: LLU.End_Point_Type;
	Server_EP: LLU.End_Point_Type;
	Buffer: aliased LLU.Buffer_Type(1024);
	Nick_Client: ASU.Unbounded_String;
	Expired: Boolean;
	Acogido: Boolean;
	Dir_IP: ASU.Unbounded_String;
	
begin
	Acogido := False;

	if Ada.Command_Line.Argument_Count /= 3 then
		raise Usage_Error;
	end if;
	
	if Ada.Command_Line.Argument(3) = "servidor" then
		raise Nickname_Error;
	end if;
	
	

	LLU.Reset(Buffer);
	Nick_Client := ASU.To_Unbounded_String(Ada.Command_Line.Argument(3));
	Dir_IP := ASU.To_Unbounded_String(LLU.To_IP(Ada.Command_Line.Argument(1)));
	Server_EP := LLU.Build(ASU.To_String(Dir_IP), integer'value(Ada.Command_Line.Argument(2)));
	LLU.Bind_Any(Client_EP_Receive);
	LLU.Bind_Any(Client_EP_Handler, Handlers.Client_Handler'Access);
	--Crea el buffer para establecer conexion con el servidor y lo envia
	CM.Crear_Message_Init(Buffer, Client_EP_Receive, Client_EP_Handler, Nick_Client);
	LLU.Send(Server_EP, Buffer'Access);
	LLU.Reset(Buffer);
	
	LLU.Receive(Client_EP_Receive, Buffer'Access, 10.0, Expired);
	
	If not Expired then
		CM.Crear_Message_Initialization(Buffer, Acogido);
		LLU.Reset(Buffer);		
		if  Acogido then
			Ada.Text_IO.Put_Line("Mini-Chat v2.0: Bienvenido " & ASU.To_String(Nick_Client));
			Modo_Writer(Buffer, Server_EP, Client_EP_Handler);
		else
			Ada.Text_IO.Put_Line("Mini-Chat v2.0: Cliente rechazado porque el nickname " & ASU.To_String(Nick_Client) & " ya existe en este servidor.");
		end if;
		
	else
		Ada.Text_IO.Put_Line("No es posible comunicarse con el servidor");
	end if;
	
	LLU.Finalize;
	
	exception
		when Usage_Error =>
			Ada.Text_IO.Put_Line("Commandos mal introducidos, se deben meter: <Nombre o IP del servidor> <Puerto> <Nickname>");
			LLU.Finalize;
		when Nickname_Error =>
			Ada.Text_IO.Put_Line("El nickname de servidor no es valido, esta ocupado por el propio servidor");
			LLU.Finalize;
		when Except:others =>
			Ada.Text_IO.Put_Line("Excepcion Imprevista " & Ada.Exceptions.Exception_Name(Except) & " en: " & Ada.Exceptions.Exception_Message(Except));
			LLU.Finalize;
	
end Chat_Client_2;
