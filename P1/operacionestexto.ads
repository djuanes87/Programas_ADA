-- Alumno: Daniel Juanes Quintana
-- Clase: Programacion de Sistemas de Telecomunicaciones
with Ada.Text_IO;
with Ada.Strings.Unbounded;

package OperacionesTexto is
	
	procedure SeparadorPalabras (F: in out Ada.Strings.Unbounded.Unbounded_String; Palabra : out Ada.Strings.Unbounded.Unbounded_String; Pos: Out Integer; End_Text: out Boolean);

end OperacionesTexto;