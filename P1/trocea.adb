-- Alumno: Daniel Juanes Quintana
--Clase: Programacion de sistemas telematicos

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with OperacionesTexto;

procedure trocea is

	package ASU renames Ada.Strings.Unbounded;
	
	procedure Palabras (F : in ASU.Unbounded_String) is
	
	Posicion : Integer;
	Num_Spacios : Integer;
	Num_Palabra : Integer;
	Palabra : ASU.Unbounded_String;
	Resto_Frase : ASU.Unbounded_String;
	Salir : Boolean;
	
	begin
	
		Posicion := 0;
		Num_Spacios := 0;
		Num_Palabra := 0;
		Resto_Frase := F;
		Salir := False;
		while not Salir loop
			OperacionesTexto.SeparadorPalabras(Resto_Frase, Palabra, Posicion, Salir);
			if ASU.Length(Palabra) /= 0 then
				Num_Palabra := Num_Palabra + 1;
				Ada.Text_IO.Put("Palabra " & Integer'Image(Num_Palabra) &": |" & ASU.To_String(Palabra) & "|");
				Ada.Text_IO.New_Line;
			end if;
			Num_Spacios:= Num_Spacios + 1;			
		end loop;
		Ada.Text_IO.Put("Total: " & Integer'Image(Num_Palabra)& " palabras y "& Integer'image(Num_Spacios - 1) & " espacios");
	end;
	
	Frase : ASU.Unbounded_String;
begin
	
	Ada.Text_IO.Put("Introduce una cadena:  ");
	Frase := ASU.To_Unbounded_String (Ada.Text_IO.Get_Line);
	Palabras(Frase);

end;