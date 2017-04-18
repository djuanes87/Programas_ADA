--Alumno: Daniel Juanes Quintana
--Clase: Programacion de Sistemas Telematicos
--Users_Array

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Calendar;

package body Users is

	use type LLU.End_Point_Type;
	use type Ada.Calendar.Time;
	
-- Almacena el nuevo usuario en el array
	procedure Almacenar (Usuarios: in out Lista_Clients; CH: in LLU.End_Point_Type; Nick: ASU.Unbounded_String; Cont_Users: in out Integer) is
	
	begin
	
		Usuarios(Cont_Users).Client_EP_Handler := CH;
		Usuarios(Cont_Users).NickName := Nick;
		Usuarios(Cont_Users).Time_Ultimo_Mensaje := Ada.Calendar.Clock;
		
	end Almacenar;
	
--Expulsa al usuario que lleva mas tiempo sin escribir
	procedure Expulsar_User (Usuarios: in out Lista_Clients; Max_Users: in Integer; EEP: out LLU.End_Point_Type; Nick: out ASU.Unbounded_String) is
		Expulsado: Integer;
		Time: Ada.Calendar.Time;
	begin
		Time := Ada.Calendar.Clock;
		--Busca en el array el usuario que lleva mas tiempo sin escribir
		for K in 1..Max_Users loop
			if Usuarios(K).Time_Ultimo_Mensaje <= Time then
				Time := Usuarios(K).Time_Ultimo_Mensaje;
				Nick := Usuarios(K).NickName;
				EEP:= Usuarios(K).Client_EP_Handler;
				Expulsado := K;
			end if;
		end loop;
		-- Elimina el usuario encontrado
		if Expulsado /= Max_Users then
			for K in Expulsado .. (Max_Users - 1) loop
				Usuarios(K).Client_EP_Handler := Usuarios(K+1).Client_EP_Handler;
				Usuarios(K).NickName := Usuarios(K+1).NickName;
				Usuarios(K).Time_Ultimo_Mensaje := Usuarios(K+1).Time_Ultimo_Mensaje;
			end loop;
		end if;
		Usuarios(Max_Users).Client_EP_Handler := LLU.Build("0.0.0.0", 0);
		Usuarios(Max_Users).NickName := ASU.To_Unbounded_String("");
	end Expulsar_User;

--Consigue el Handler para saber a quien se va enviar	
	procedure Conseguir_Handler(Usuarios: in Lista_Clients; K: in Integer; Client_Handler: out LLU.End_Point_Type) is
	
	begin
		Client_Handler := Usuarios(K).Client_EP_Handler;
	end;

--Comprueba que el usuario esta en el array y delvuele un Boolean el nick del del cliente que envia el mensaje y actualiza su hora
	procedure Comprobar_User(Usuarios: in out Lista_Clients; CEPH: in LLU.End_Point_Type; Nick: in out ASU.Unbounded_String; Cont_Users: in Integer; Existe: out Boolean) is
		
		Cont : Integer;
	begin
		Cont := 1;
		Existe := False;
		while Cont <= Cont_Users and not  Existe loop
			If Usuarios(Cont).Client_EP_Handler = CEPH then
				Nick := Usuarios(Cont).NickName;
				Usuarios(Cont).Time_Ultimo_Mensaje := Ada.Calendar.Clock;
				Existe := True;
			end if;
			cont := cont + 1;
		end loop;
	end;

-- Elemina un cliente de la lista 
	procedure Borrar_Cliente(Usuarios: in out Lista_Clients; Client_EP_Handler: in LLU.End_Point_Type; Cont_Users: in Integer) is
		Cont : Integer;
		Borrado : Boolean;
	begin
		Borrado := False;
		cont := 1;
		while Cont <= Cont_Users and not Borrado  loop
			if Usuarios(Cont).Client_EP_Handler = Client_EP_Handler then
				Borrado := True;
			else
				Cont := Cont + 1;
			end if;
		end loop;
		if Cont /= Cont_Users then
			for K in Cont .. (Cont_Users - 1) loop
				Usuarios(K).Client_EP_Handler := Usuarios(K+1).Client_EP_Handler;
				Usuarios(K).NickName := Usuarios(K+1).NickName;
				Usuarios(K).Time_Ultimo_Mensaje := Usuarios(K+1).Time_Ultimo_Mensaje;
			end loop;
		end if;
		Usuarios(Cont_Users).Client_EP_Handler := LLU.Build("0.0.0.0", 0);
		Usuarios(Cont_Users).NickName := ASU.To_Unbounded_String("");
	end Borrar_Cliente;
	
-- Comprueba si el nick esta ocupado y devuelve un Boolean 
	function Comprobar_Nick (Usuarios: Lista_Clients; Nick: ASU.Unbounded_String; Cont_Client: Integer) return Boolean is
	
		Acogido : Boolean;	
		Cont : Integer;
	begin
		Cont := 1;
		Acogido := True;
		while Cont <= Cont_Client and Acogido loop
			If ASU.To_String(Usuarios(Cont).NickName) = ASU.To_String(Nick) then
				Acogido := False;
			end if;
			Cont := Cont + 1;
		end loop;		
		return Acogido;
	end Comprobar_Nick;
	
end Users;
