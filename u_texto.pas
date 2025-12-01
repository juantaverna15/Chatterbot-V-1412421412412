unit u_texto;
{esta unit esta dedicada a limpiar el texto, es decir, pasar mayusculas a minusculas,  }
interface

const
  MAX_PALABRAS = 50;
  MAX_STOPWORDS = 20;

type
  t_string_vector = array[1..MAX_PALABRAS] of string[30];  {vector con las palabras del usuario}

procedure CargarStopWords(var sw: t_string_vector; var cant: integer);
function Minusculas(s: string): string;
function LimpiarTexto(s: string): string;
procedure SepararPalabras(s: string; var palabras: t_string_vector; var cant: integer);
procedure EliminarStopWords(var palabras: t_string_vector; var cant: integer; sw: t_string_vector; cantSW: integer);

implementation

uses SysUtils;

function Minusculas(s: string): string;
var i: integer;
begin
  for i := 1 to Length(s) do
    if (s[i] in ['A'..'Z']) then
      s[i] := Chr(Ord(s[i]) + 32);
  Minusculas := s;
end;

function LimpiarTexto(s: string): string;     
{	Si es mayuscula la funcion ord pasa el caracter a valor ASCII y le suma 32 ya que las letras minusculas estan 32 posiciones mas adelante ejemplo 'A'=65 , 'a'=97
	Luego a ese valor calculado se utiliza Chr pasa el codigo ASCII a caracter }
var
  i: integer;             
  c: char;
  r: string;  
begin
  r := '';
  for i := 1 to Length(s) do
  begin
    c := s[i];
    if (c in ['a'..'z']) or (c in ['A'..'Z']) or (c in ['0'..'9']) or (c = ' ') then
      r := r + c;
  end;
  LimpiarTexto := r;
end;
{Recibe texto original ,Recorre cada carácter,Solo conserva letras, números y espacios,Devuelve la cadena limpia, sin signos ni símbolos}
procedure SepararPalabras(s: string; var palabras: t_string_vector; var cant: integer);
var p, pos_espacio: integer; palabra: string;
begin
  cant := 0;
  while Length(s) > 0 do
  begin
    pos_espacio := Pos(' ', s);                     {Busca la posición del primer espacio en s. }
    if pos_espacio = 0 then palabra := s           { Si no hay más espacios (pos_espacio = 0), la última palabra es toda la cadena restante.}
    else palabra := Copy(s, 1, pos_espacio - 1);   {Si hay espacio, se copia la porción desde el inicio hasta antes del espacio}
    if palabra <> '' then
    begin
      cant := cant + 1;
      palabras[cant] := palabra;
    end;
    if pos_espacio = 0 then s := ''               {Si la palabra no está vacía:Se incrementa el contador.Se guarda la palabra en el arreglo.}
    else Delete(s, 1, pos_espacio);             {Esto recorta la cadena original, eliminando la palabra recién procesada y el espacio.}
  end;
end;
{convierte una frase completa en un arreglo de palabras individuales.}
procedure CargarStopWords(var sw: t_string_vector; var cant: integer);      
begin
  cant := 10;            {define las palabras irrelevantes  que el programa debe ignorar cuando analiza lo que escribe el usuario}                                               
  sw[1] := 'el'; sw[2] := 'la'; sw[3] := 'los'; sw[4] := 'las';
  sw[5] := 'que'; sw[6] := 'para'; sw[7] := 'de'; sw[8] := 'un';
  sw[9] := 'una'; sw[10] := 'es';
end;

procedure EliminarStopWords(var palabras: t_string_vector; var cant: integer; sw: t_string_vector; cantSW: integer);
var i, j, k: integer; es_stop: boolean;
{elimina palabras irrelevantes = stopwords/ i:recorre las palabras ingresadas, j:las stopword , k: para mover palabras al eliminar }
begin
  i := 1;
  while i <= cant do    
  begin
    es_stop := false;
    for j := 1 to cantSW do                 {Verifica si la palabra está en la lista de stop words}
      if palabras[i] = sw[j] then
        es_stop := true;
    if es_stop then
    begin                               {si es stopword la elimina y cada elemento se copia una posicion atras}
      for k := i to cant - 1 do
        palabras[k] := palabras[k + 1];
      cant := cant - 1;
    end
    else
      i := i + 1;         {si no es sw pasa a la siguiente}
  end;
end;

end.