-- Alumno: Daniel Juanes Quintana
-- Clase: Programacion de Sistemas de Telecomunicaciones

with Ada.Strings.Unbounded;
with Ada.Text_IO;

package body OperacionesTexto is

	package ASU renames Ada.Strings.Unbounded;
	
	procedure SeparadorPalabras (F: in out ASU.Unbounded_String; Palabra : out ASU.Unbounded_String; Pos: Out Integer; End_Text: out Boolean ) is
		
	begin
		Pos := 0;
		Pos := ASU.Index(F, " ");
		if pos /= 0 then
			Palabra := ASU.Head(F, Pos-1);
			ASU.Tail(F, ASU.Length(F)-Pos);
		else
			Palabra := F;
			Pos := ASU.Length(Palabra);
			End_Text := True;
		end if;
	end SeparadorPalabras;
		
end OperacionesTexto;