-- Alumno: Daniel Juanes Quintana
--Clase: Programacion de sistemas telematicos

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;

package Chat_Messages is

	type Message_Type is (Init, Writer, Server);
	
	procedure Crear_Buffer_Server (buf : in out Lower_layer_UDP.Buffer_Type ; N: in Ada.Strings.Unbounded.Unbounded_String; C: in Ada.Strings.Unbounded.Unbounded_String);
	procedure Crear_Buffer_Client (buf : in out Lower_layer_UDP.Buffer_Type ;M: in Message_Type; Client: in Lower_layer_UDP.End_Point_Type; C: in Ada.Strings.Unbounded.Unbounded_String);

end Chat_Messages;