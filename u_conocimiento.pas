unit u_conocimiento;
{Carga el archivo de texto}
interface

uses
  u_texto, u_levenshtein, SysUtils;  

const
  MAX_REGISTROS = 100;  {cantidad máxima de respuestas que se pueden leer del archivo de conocimiento.}
  MAX_KEYWORDS = 10;    {cantidad máxima de palabras clave por tema}

type
  TRegistro = record
    id: integer;
    tema: string[30];
    keywords: array[1..MAX_KEYWORDS] of string[20];
    cantKeywords: integer;
    respuesta: string[200];
  end;

  TBaseConocimiento = array[1..MAX_REGISTROS] of TRegistro;

  { simplificar el uso del tipo de u_texto }
  t_string_vector = u_texto.t_string_vector;

procedure CargarConocimiento(var base: TBaseConocimiento; var cant: integer);
function BuscarRespuesta(base: TBaseConocimiento; cant: integer; entrada: string;
                         stopwords: t_string_vector; cantStop: integer): string;

implementation
  { Este procedimiento lee cada línea del archivo conocimiento.txt y la convierte en un registro (TRegistro), que guarda:
un id ,un tema,una lista de palabras clave,una respuesta asociada}
procedure CargarConocimiento(var base: TBaseConocimiento; var cant: integer);
var                                       
  arch: Text;
  linea, campo, palabra: string;            {linea:almacena temporalmente una línea completa del archivo.}
  pos1, pos2: integer;          {posiciones del caracter separador}
begin
  Assign(arch, 'conocimiento.txt'); {asignamos arch con el archivo de texto}
  Reset(arch);      {abre en modo lectura}
  cant := 0;
  while not EOF(arch) do      {recorre hasta el final del archivo}
  begin
    ReadLn(arch, linea); {lee un renglon completo }
    cant := cant + 1;       {cantidad de registros leidos}
                                      
    pos1 := Pos('|', linea);          {lee id}      {busca la posición del primer |}
    base[cant].id := StrToInt(Trim(Copy(linea, 1, pos1 - 1)));      {extrae el texto antes del |} {trim: elimina espacios}
    Delete(linea, 1, pos1); {borra el id y continua con el renglon}

    pos1 := Pos('|', linea);   {se repite lo mismo para el tema }
    base[cant].tema := Trim(Copy(linea, 1, pos1 - 1));
    Delete(linea, 1, pos1);

    pos1 := Pos('|', linea);  {y por palabras clave }
    campo := Trim(Copy(linea, 1, pos1 - 1));
    Delete(linea, 1, pos1);

    base[cant].cantKeywords := 0;
    repeat                          {este bucle procesa las palabras clave}
      pos2 := Pos(',', campo);              {busca una coma , para separar cada palabra.}
      if pos2 = 0 then palabra := Trim(campo)   
      else palabra := Trim(Copy(campo, 1, pos2 - 1));       {Usa Copy para extraer la palabra hasta la coma.}
      if palabra <> '' then
      begin
        base[cant].cantKeywords := base[cant].cantKeywords + 1;   {incrementa la cantidad}
        base[cant].keywords[base[cant].cantKeywords] := Minusculas(palabra);    {La pasa a minusculas con Minusculas(palabra) y La guarda en el    arreglo keywords[].}
      end;
      if pos2 > 0 then Delete(campo, 1, pos2)  {borra la palabra ya procesada}
      else campo := '';
    until campo = '';

    base[cant].respuesta := Trim(linea);  {Despues de procesar los tres primeros campos (id, tema, keywords), lo que queda en linea es la respuesta completa.}
  end;
  Close(arch);
end;

function BuscarRespuesta(base: TBaseConocimiento; cant: integer; entrada: string; stopwords: t_string_vector; cantStop: integer): string;
var
  palabras: t_string_vector; //palabras limpias luego de ser procesada
  cantPal: integer;     
  i, j, k, coincidencias, mejor: integer;
  mejorRespuesta: string;
  dist: integer;
begin
  cantPal := 0;  
  entrada := Minusculas(LimpiarTexto(entrada));      {pasa a minusculas}
  SepararPalabras(entrada, palabras, cantPal);       {separa las palabras por arrays}
  EliminarStopWords(palabras, cantPal, stopwords, cantStop);    {elimina palabras que no aportan}

  mejor := 0;
  mejorRespuesta := '';

  for i := 1 to cant do
  begin
    coincidencias := 0;       {Recorre toda la base de conocimiento y compara cada palabra del usuario con todas las keywords de cada registro.}
    for j := 1 to cantPal do
      for k := 1 to base[i].cantKeywords do
      begin
        dist := Levenshtein(palabras[j], base[i].keywords[k]);    {calcula las palabras claves con las procesadas procesadas del texto cuántas letras hay que cambiar para que dos palabras sean iguales}
        if (dist <= 1) then
          coincidencias := coincidencias + 1;                         
      end;

    if coincidencias > mejor then           {Si el número de coincidencias con este registro es mayor que el máximo anterior almacena la respuesta}
    begin
      mejor := coincidencias;
      mejorRespuesta := base[i].respuesta;
    end;
  end;

  { Si no hay coincidencias, respuesta que no entendio }
  if mejor = 0 then
    BuscarRespuesta := 'No entendí tu pregunta, ¿podés reformularla?'
  else
    BuscarRespuesta := mejorRespuesta;
end;

end.
