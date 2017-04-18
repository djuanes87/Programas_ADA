--Alumnos: Daniel Juanes Quintana
--Programacion de Sistemas Telematicos

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Ada.IO_Exceptions;
with OperacionesTexto;
with List;

procedure Cuenta is

	package ASU renames Ada.Strings.Unbounded;

	-- Contara todo menos en numero de lineas
	procedure Contador (Line: in ASU.Unbounded_String; Cont_Pal: in out Integer; Cont_Car: in out Integer; P_Lista_Palabras: in out List.Cell_A) is
	
	Palabra : ASU.Unbounded_String;
	Resto_Linea : ASU.Unbounded_String;
	Posicion: Integer;
	Size_Line : Integer;
	Fin_Linea : Boolean;
	
	begin
		
		Size_Line := 0;
		Posicion := 0;
		Resto_Linea := Line;
		Fin_Linea := False;
		while not Fin_Linea loop
			OperacionesTexto.SeparadorPalabras(Resto_Linea, Palabra, Posicion, Fin_Linea);
			Size_Line := Size_Line + Posicion;
			if ASU.Length(Palabra) /= 0 then
				Cont_Pal := Cont_Pal + 1;
				List.AlmacenarPalabras( Palabra, P_Lista_Palabras);
			end if;
		end loop;
		Cont_Car := Cont_Car + Size_Line;
	end Contador;
	
	Usage_Error: exception;
	
	Fich: Ada.Text_IO.File_Type;
	Linea: ASU.Unbounded_String;
	Cont_Palabras : Integer;
	Cont_Caracteres : Integer;
	Cont_Lineas : Integer;	
	P_Lista_Palabras : List.Cell_A;
	VisualizarPalabras : Boolean;
begin
	
	Cont_Lineas := 0;
	Cont_Caracteres := 0;
	Cont_Palabras := 0;
	P_Lista_Palabras := null;
	VisualizarPalabras := False;
	
	
	--Detectar los comados introducidos y los posibles errores que se pueden dar.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	if Ada.Command_Line.Argument_Count < 2 or Ada.Command_Line.Argument_Count > 3 then
		raise Usage_Error;
	end if;
	if Ada.Command_Line.Argument_Count = 2 then
		if Ada.Command_Line.Argument(1) = "-f" then
			Ada.Text_IO.Open(Fich, Ada.Text_IO.In_File, Ada.Command_Line.Argument(2));
		else
			raise Usage_Error;
		end if;
	else
		if Ada.Command_Line.Argument(1) = "-f" then
			Ada.Text_IO.Open(Fich, Ada.Text_IO.In_File, Ada.Command_Line.Argument(2));
		elsif Ada.Command_Line.Argument(2) = "-f" then
			Ada.Text_IO.Open(Fich, Ada.Text_IO.In_File, Ada.Command_Line.Argument(3));
		else 
			raise Usage_Error;
		end if;
		
		if Ada.Command_Line.Argument(1)  /= "-t" and Ada.Command_Line.Argument(3)  /= "-t" then
			raise Usage_Error;
		else 
			Visualizarpalabras := True;
		end if;
	end if;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	while not Ada.Text_IO.End_Of_File(Fich) loop
		Linea := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line(Fich));
		Contador(Linea, Cont_Palabras, Cont_Caracteres, P_Lista_palabras);		
		-- Esto hara que cuando la linea esta vacia detectarla y sumarla al contador
		if Ada.Text_IO.End_Of_Line(Fich) then
			Cont_Lineas := Cont_Lineas + 1;
		else
			Cont_Lineas := Cont_Lineas + 1;
		end if;
	end loop;

	Cont_Caracteres := Cont_Caracteres + Cont_Lineas;
	Ada.Text_IO.Put(Integer'Image(Cont_Lineas) & " Lineas y " & Integer'Image(Cont_Palabras) & " Palabras y "&Integer'Image(Cont_Caracteres) & " Caracteres");
	Ada.Text_IO.New_Line;
	Ada.Text_IO.Close(Fich);
	
	-- Visualizara la lista en caso de que se introduzca -t
	if visualizarpalabras then
		List.MostrarLista(P_Lista_Palabras);
	end if;
	
	
		--Mesajes de las excepciones que se puedan dar
	exception
		when Usage_Error =>
			Ada.Text_IO.Put_Line("Los argumentos introducidos no son validos, las diferentes posibilidades son:");
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line(" cuenta -f <fichero>");
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line(" cuenta -t -f <fichero>");
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line(" cuenta -f <fichero> -t");
		when Ada.IO_Exceptions.Name_Error =>
			Ada.Text_IO.Put_Line("El fichero que intentas entrar no existe");
		when Except:others =>
			Ada.Text_IO.Put_Line("Error al ejecutar el programa");			
			
end Cuenta;
