with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Calendar;

package Users is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;

	type  Lista_Clients is private;

	procedure Almacenar (Usuarios: in out Lista_Clients; CH: in LLU.End_Point_Type; Nick: ASU.Unbounded_String; Cont_Users: in out Integer);
	procedure Expulsar_User (Usuarios: in out Lista_Clients; Max_Users: in Integer; EEP: out LLU.End_Point_Type; Nick: out ASU.Unbounded_String);
	procedure Conseguir_Handler(Usuarios: in Lista_Clients; K: in Integer; Client_Handler: out LLU.End_Point_Type);
	procedure Comprobar_User(Usuarios: in out Lista_Clients; CEPH: in LLU.End_Point_Type; Nick: in out ASU.Unbounded_String; Cont_Users: in Integer; Existe: out Boolean);
	procedure Borrar_Cliente(Usuarios: in out Lista_Clients; Client_EP_Handler: in LLU.End_Point_Type; Cont_Users: in Integer);
	function Comprobar_Nick (Usuarios: Lista_Clients; Nick: ASU.Unbounded_String; Cont_Client: Integer) return Boolean;

	
	
private

	type Datos_Client;
	
	type Lista_Clients is access Datos_Client;
	
	type Datos_Client is record
		Client_EP_Handler: LLU.End_Point_Type;
		NickName: ASU.Unbounded_String;
		Time_Ultimo_Mensaje: Ada.Calendar.Time;
		Next_Client :  Lista_Clients;
	end record;
	
	


	
end Users;
