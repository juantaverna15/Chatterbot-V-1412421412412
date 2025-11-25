unit u_conocimiento;

interface

uses
  u_texto, u_levenshtein, SysUtils;  

const
  MAX_REGISTROS = 100;
  MAX_KEYWORDS = 10;

type
  TRegistro = record
    id: integer;
    tema: string[30];
    keywords: array[1..MAX_KEYWORDS] of string[20];
    cantKeywords: integer;
    respuesta: string[200];
  end;

  TBaseConocimiento = array[1..MAX_REGISTROS] of TRegistro;

  { Alias para simplificar el uso del tipo de u_texto }
  TStringArray = u_texto.TStringArray;

procedure CargarConocimiento(var base: TBaseConocimiento; var cant: integer);
function BuscarRespuesta(base: TBaseConocimiento; cant: integer; entrada: string;
                         stopwords: TStringArray; cantStop: integer): string;

implementation

procedure CargarConocimiento(var base: TBaseConocimiento; var cant: integer);
var
  arch: Text;
  linea, campo, palabra: string;
  pos1, pos2: integer;
begin
  Assign(arch, 'conocimiento.txt');
  Reset(arch);
  cant := 0;
  while not EOF(arch) do
  begin
    ReadLn(arch, linea);
    cant := cant + 1;

    pos1 := Pos('|', linea);
    base[cant].id := StrToInt(Trim(Copy(linea, 1, pos1 - 1)));
    Delete(linea, 1, pos1);

    pos1 := Pos('|', linea);
    base[cant].tema := Trim(Copy(linea, 1, pos1 - 1));
    Delete(linea, 1, pos1);

    pos1 := Pos('|', linea);
    campo := Trim(Copy(linea, 1, pos1 - 1));
    Delete(linea, 1, pos1);

    base[cant].cantKeywords := 0;
    repeat
      pos2 := Pos(',', campo);
      if pos2 = 0 then palabra := Trim(campo)
      else palabra := Trim(Copy(campo, 1, pos2 - 1));
      if palabra <> '' then
      begin
        base[cant].cantKeywords := base[cant].cantKeywords + 1;
        base[cant].keywords[base[cant].cantKeywords] := Minusculas(palabra);
      end;
      if pos2 > 0 then Delete(campo, 1, pos2)
      else campo := '';
    until campo = '';

    base[cant].respuesta := Trim(linea);
  end;
  Close(arch);
end;

function BuscarRespuesta(base: TBaseConocimiento; cant: integer; entrada: string;
                         stopwords: TStringArray; cantStop: integer): string;
var
  palabras: TStringArray;
  cantPal: integer;
  i, j, k, coincidencias, mejor: integer;
  mejorRespuesta: string;
  dist: integer;
begin
  cantPal := 0;
  entrada := Minusculas(LimpiarTexto(entrada));
  SepararPalabras(entrada, palabras, cantPal);
  EliminarStopWords(palabras, cantPal, stopwords, cantStop);

  mejor := 0;
  mejorRespuesta := '';

  for i := 1 to cant do
  begin
    coincidencias := 0;
    for j := 1 to cantPal do
      for k := 1 to base[i].cantKeywords do
      begin
        dist := Levenshtein(palabras[j], base[i].keywords[k]);
        if (dist <= 1) then
          coincidencias := coincidencias + 1;
      end;

    if coincidencias > mejor then
    begin
      mejor := coincidencias;
      mejorRespuesta := base[i].respuesta;
    end;
  end;

  { Si no hay coincidencias, respuesta genérica }
  if mejor = 0 then
    BuscarRespuesta := 'No entendí tu pregunta, ¿podés reformularla?'
  else
    BuscarRespuesta := mejorRespuesta;
end;

end.
