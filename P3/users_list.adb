--Alumno: Daniel Juanes Quintana
--Clase: Programacion de Sistemas Telematicos
--Users_List

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Calendar;
with Ada.Unchecked_Deallocation;

package body Users is

	use type LLU.End_Point_Type;
	use type Ada.Calendar.Time;
	
	procedure Delete is new Ada.Unchecked_Deallocation(Datos_Client, Lista_Clients);
	
-- Almacena el nuevo usuario en el array
	procedure Almacenar (Usuarios: in out Lista_Clients; CH: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String; Cont_Users: in out Integer) is
	
		aux: Lista_Clients;
	
	begin
		if Cont_Users = 1 then
			Usuarios := null;
		end if;
		aux := New Datos_Client;
		aux.Client_EP_Handler := CH;
		aux.NickName := Nick;
		aux.Time_Ultimo_Mensaje := Ada.Calendar.Clock;
		aux.Next_Client := Usuarios;
		Usuarios := aux;
	end Almacenar;
	
--Expulsa al usuario que lleva mas tiempo sin escribir
	procedure Expulsar_User (Usuarios: in out Lista_Clients; Max_Users: in Integer; EEP: out LLU.End_Point_Type; Nick: out ASU.Unbounded_String) is
		Time: Ada.Calendar.Time;
		Aux : Lista_Clients;
		P_Eliminado : Lista_Clients;
	begin
		Aux := Usuarios;
		P_Eliminado := Null;
		Time := Ada.Calendar.Clock;
		--Busca en el array el usuario que lleva mas tiempo sin escribir
		for K in 1..Max_Users loop
			if Aux.Time_Ultimo_Mensaje <= Time then
				Time := Aux.Time_Ultimo_Mensaje;
				Nick := Aux.NickName;
				EEP:= Aux.Client_EP_Handler;
				P_Eliminado := Aux;
			end if;
			Aux := Aux.Next_Client;
		end loop;
		-- Elimina el usuario encontrado
		Aux := Usuarios;
		if Aux = P_Eliminado then
			Usuarios := Aux.Next_Client;
		else
			while Aux.Next_Client /= P_Eliminado loop
				Aux := Aux.Next_Client;
			end loop;
			Aux.Next_Client := P_Eliminado.Next_Client;
		end if;
		Delete(P_Eliminado);
	end Expulsar_User;

--Consigue el Handler para saber a quien se va enviar	
	procedure Conseguir_Handler(Usuarios: in Lista_Clients; K: in Integer; Client_Handler: out LLU.End_Point_Type) is
		Aux : Lista_Clients;
		Cont : Integer;
	begin
		Aux := Usuarios;
		Cont := 1;
		while Cont < K loop
				Aux := Aux.Next_Client;
				Cont := Cont + 1;
		end loop;
		if Aux /= null then
			Client_Handler := Aux.Client_EP_Handler;
		end if;
	end;

--Comprueba que el usuario esta en el array y delvuele un Boolean el nick del del cliente que envia el mensaje y actualiza su hora
	procedure Comprobar_User(Usuarios: in out Lista_Clients; CEPH: in LLU.End_Point_Type; Nick: in out ASU.Unbounded_String; Cont_Users: in Integer; Existe: out Boolean) is
		Aux : Lista_Clients;
		Cont : Integer;
	begin
		Cont := 1;
		Existe := False;
		Aux := Usuarios;
		while Cont <= Cont_Users and not  Existe loop
			if aux /= null then
				If Aux.Client_EP_Handler = CEPH then
					Nick := Aux.NickName;
					Aux.Time_Ultimo_Mensaje := Ada.Calendar.Clock;
					Existe := True;
				end if;
				Aux := Aux.Next_Client;
			end if;
			Cont := Cont + 1;
		end loop;
	end;

-- Elemina un cliente de la lista 
	procedure Borrar_Cliente(Usuarios: in out Lista_Clients; Client_EP_Handler: in LLU.End_Point_Type; Cont_Users: in Integer) is
		Cont : Integer;
		Borrado : Boolean;
		Aux: Lista_Clients;
		P_Borrado: Lista_Clients;
	begin
		Aux := Usuarios;
		Borrado := False;
		cont := 1;
		while Cont <= Cont_Users and not Borrado  loop
			if Aux.Client_EP_Handler = Client_EP_Handler then
				P_Borrado := Aux;
				Borrado := True;
			else
				Cont := Cont + 1;
				Aux := Aux.Next_Client;
			end if;
		end loop;
		Aux := Usuarios;
		if Aux = P_Borrado then
			Usuarios := Aux.Next_Client;
		else
			while Aux.Next_Client /= P_Borrado loop
				Aux := Aux.Next_Client;
			end loop;
			Aux.Next_Client := P_Borrado.Next_Client;
		end if;
		Delete(P_Borrado);
	end Borrar_Cliente;
	
-- Comprueba si el nick esta ocupado y devuelve un Boolean 
	function Comprobar_Nick (Usuarios: Lista_Clients; Nick: ASU.Unbounded_String; Cont_Client: Integer) return Boolean is
	
		Acogido : Boolean;	
		Cont : Integer;
		Aux : Lista_Clients;
	begin
		Aux := Usuarios;
		Cont := 1;
		Acogido := True;
		while Cont < Cont_Client and Acogido loop
			If ASU.To_String(Aux.NickName) = ASU.To_String(Nick) then
				Acogido := False;
			end if;
			Aux := Aux.Next_Client;
			Cont := Cont + 1;
		end loop;		
		return Acogido;
	end Comprobar_Nick;
	
end Users;
