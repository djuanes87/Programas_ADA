--Alumno: Daniel Juanes Quintana
--Programacion de Sistemas telematicos

with Ada.Strings.Unbounded;

package List is

	package ASU renames Ada.Strings.Unbounded;

	type Cell;
	type Cell_A is access Cell;

	type Cell is record
		Name: ASU.Unbounded_String;
		Count: Natural := 0;
		Next: Cell_A;
	end record;

	procedure AlmacenarPalabras (Palabra: in Ada.Strings.Unbounded.Unbounded_String; P_Lista: in out Cell_A);
	procedure MostrarLista(P_Lista : in Cell_A);

end List;
