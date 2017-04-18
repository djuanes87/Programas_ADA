--Alumno: Daniel Juanes Quintana
--Programacion de Sistemas Telematicos

with Ada.Strings.Unbounded;
with Ada. Text_IO;

package body List is
	procedure AlmacenarPalabras (Palabra: in Ada.Strings.Unbounded.Unbounded_String; P_Lista: in out Cell_A) is
		
		P_Alm_List : Cell_A;
		P_Aux : Cell_A;
		Encontrada : Boolean;
		P_Palabra_Lista : Ada.Strings.Unbounded.Unbounded_String;
		Cont : Integer;
	begin
		Encontrada := False;
		P_Alm_List := P_Lista;
		Cont := 0;
		while P_Alm_List /= null and not Encontrada loop
			P_Palabra_Lista := P_Alm_List.all.Name;
			if Ada.Strings.Unbounded.To_String(P_Palabra_Lista) = Ada.Strings.Unbounded.To_String(Palabra) then
				P_Alm_List.all.Count := P_Alm_List.all.Count + 1;
				Encontrada := True;
			else	
				P_Aux := P_Alm_List;
				P_Alm_List := P_Alm_List.Next;
			end if;	
			Cont := Cont + 1;		
		end loop;
		if not Encontrada then
			P_Alm_List := New Cell;
			P_Alm_List.all.Name := Palabra;
			P_Alm_List.all.Count := 1;
			P_Alm_List.Next := Null;
			if Cont = 0 then
				P_Lista := P_Alm_List;
			else
				P_Aux.Next := P_Alm_List;
			end if;
		end if;
	end;
	
	procedure MostrarLista(P_Lista : in Cell_A) is
	
	P_Alm_List : Cell_A;
	begin
		P_Alm_List := P_Lista;
		while P_Alm_List /= Null loop
			Ada.Text_IO.Put(Ada.Strings.Unbounded.To_String(P_Alm_List.all.Name));
			Ada.Text_IO.Put(": ");
			Ada.Text_IO.Put(Integer'Image(P_Alm_List.all.Count));
			Ada.Text_IO.New_Line;
			P_Alm_List := P_Alm_List.all.Next;
		end loop;
	end;
end List;
