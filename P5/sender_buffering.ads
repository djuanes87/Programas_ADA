--------------------------------------------------------------------------------
--
-- Este paquete implementa un TAD tabla de símbolos para almacenar los
--  mensajes pendientes de ser asentidos del programa Peer-Chat v2.0
--  que hay que realizar en la práctica P5 de las asignaturas
--  Programación de Sistemas de Telecomunicación e Informática II de
--  los grados de la ETSIT de la Rey Juan Carlos, curso 2011/2012
--
-- La tabla de símbolos está implementada como un árbol de búsqueda binaria
--
--------------------------------------------------------------------------------
with Types;
with Ada.Unchecked_Deallocation;
with Lower_Layer_UDP;
with Ada.Calendar;
with Neighbors;

package Sender_Buffering is
   package LLU renames Lower_Layer_UDP;

   type Destination_T is record
      Ep      : Llu.End_Point_Type := null;
      Retries : Natural := 0;
   end record;
   type Destinations_T is array (1..10) of Destination_T;

   type Buffer_A_T is access all LLU.Buffer_Type;
   procedure Free is new
     Ada.Unchecked_Deallocation (LLU.Buffer_Type, Buffer_A_T);


   type Value_T is record
      Ep           : LLU.End_Point_Type;
      Seq_N        : Types.Seq_N_T;
      Destinations : Destinations_T;
      P_Buffer     : access LLU.Buffer_Type;
   end record;

   Null_Value : constant Value_T :=
     (null,
      Types.Seq_N_T'First,
      Destinations => (others => (null, 0)),
      P_Buffer => Null);

   
   
   type Map is limited private;
   
   -----------------------------------------------------------------------------
   --
   -- Si Key está presente en la tabla de símbolos, devuelve True en
   --  el parámetro Success, y el valor asociado a Key se devuelve en
   --  Value.
   --
   -- Si Key no está presente devuelve False en el parámetro
   --  Success.
   --
   procedure Get (M       : in out Map;
		  Key     : in     Ada.Calendar.Time;
                  Value   : out    Value_T;
                  Success : out    Boolean);

   -----------------------------------------------------------------------------
   --
   -- Si hay un elemento de la tabla de símbolos cuyos campos Value.Ep
   --  y Value.Seq_N son iguales a Ep y Seq_N respectivamente,
   --  Success es True y en Key y Value se devuelven los contenidos
   --  del elemento
   -- Si no existe dicho elemento se devuelve False en Success
   --
   procedure Get (M       : in out Map;
		  EP      : in     Llu.End_Point_Type;
                  Seq_N   : in     Types.Seq_N_T;
                  Key     : out    Ada.Calendar.Time;
                  Value   : out    Value_T;
                  Success : out    Boolean);

   -----------------------------------------------------------------------------
   --
   -- Introduce un nuevo elemento (Key, Value) en la tabla de símbolos
   --  si no existe ya uno con la misma clave.  Si existe un elemento
   --  con la clave Key, se substituye su valor asociado por Value
   --
   -- Al almacenar Value se hace una copia de Value.P_Buffer en memoria dinámica
   --
   Procedure Put (M     : in out Map;
		  Key   : in     Ada.Calendar.Time;
                  Value : in     Value_T);

   -----------------------------------------------------------------------------
   --
   -- Elimina el elemento con clave Key de la tabla de símbolos
   --
   procedure Delete (M   : in out Map;
		     Key : in     Ada.Calendar.Time);


   -----------------------------------------------------------------------------
   --
   -- Devuelve la clave más pequeña de las almacenadas en la tabla de símbolos
   --
   function Min (M : in Map) return Ada.Calendar.Time;


   -----------------------------------------------------------------------------
   --
   -- Deveulve True si la tabla de símbolos está vacía y False en caso contrario
   --
   function Is_Empty (M: in Map) return Boolean;

   -----------------------------------------------------------------------------
   --
   -- Devuelve el número de elementos de la tabla de símbolos
   --
   function Size (M: in Map) return Natural;

   -----------------------------------------------------------------------------
   --
   -- Muestra en la salida estándar algunos campos de cada elemento almacenado
   -- en la tabla de símbolos
   --
   procedure Print (M : in out Map);
   
   procedure Comprobar_Ack_Receive (M: in out Map; EP_Creat: in LLU.End_Point_Type; Seq_N: in Types.Seq_N_T; EP_ACKer: in LLU.End_Point_Type);
   
   procedure Introducir_Ack_Arbol (M: in out Map; LN: in out Neighbors.List_Protected_Neighbors; Time: in Ada.Calendar.Time; EP: in LLU.End_Point_Type; Seq_N: in Types.Seq_N_T;  EP_Rsnd: in LLU.End_Point_Type; P_Buffer: in out LLU.Buffer_Type);
   
    procedure Send_Message (M: in out Map; T: in Ada.Calendar.Time; TF: in Ada.Calendar.Time; Success: in out Boolean);
    
     procedure Comprobar_Temp (M: in out Map; T: out Ada.Calendar.Time);


private

   use type Ada.Calendar.Time;
   use type Types.Seq_N_T;
   use type Llu.End_Point_Type;



   type Tree;
   type Tree_A is access Tree;
   type Tree is record
      Key   : Ada.Calendar.Time;
      Value : Value_T;
      Left  : Tree_A;
      Right : Tree_A;
   end record;

   protected type Map is
      function Tree_Size return Natural;

      procedure Delete (Key : Ada.Calendar.Time);

      function Min return Ada.Calendar.Time;

      function Is_Empty return Boolean;

      procedure Get (Key     : Ada.Calendar.Time;
                     Value   : out Value_T;
                     Success : out Boolean);

      procedure Get (Ep      : LLU.End_Point_Type;
                     Seq_N  : Types.Seq_N_T;
                     Key     : out Ada.Calendar.Time;
                     Value   : out Value_T;
                     Success : out Boolean);

      procedure Put (Key    : Ada.Calendar.Time;
                     Value  : Value_T);

      function Delete (P_Tree : Tree_A;
                       Key    : Ada.Calendar.Time)
                      return Tree_A;

      procedure Print_Tree;
      
      procedure Comprobar_Ack_Receive (EP_Creat: in LLU.End_Point_Type; Seq_N: in Types.Seq_N_T; EP_ACKer: in LLU.End_Point_Type);
      
      procedure Introducir_Ack_Arbol (LN: in out Neighbors.List_Protected_Neighbors; Time: in Ada.Calendar.Time; EP: in LLU.End_Point_Type; Seq_N: in Types.Seq_N_T;  EP_Rsnd: in LLU.End_Point_Type; P_Buffer: in out LLU.Buffer_Type);
      
       procedure Send_Message (T: in Ada.Calendar.Time; TF: in Ada.Calendar.Time; Success: in out Boolean);
       
        procedure Comprobar_Temp (T: out Ada.Calendar.Time);

   private

      The_Tree : Tree_A;

   end Map;


end Sender_Buffering;
