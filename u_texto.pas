unit u_texto;

interface

const
  MAX_PALABRAS = 50;
  MAX_STOPWORDS = 20;

type
  TStringArray = array[1..MAX_PALABRAS] of string[30];

procedure CargarStopWords(var sw: TStringArray; var cant: integer);
function Minusculas(s: string): string;
function LimpiarTexto(s: string): string;
procedure SepararPalabras(s: string; var palabras: TStringArray; var cant: integer);
procedure EliminarStopWords(var palabras: TStringArray; var cant: integer; sw: TStringArray; cantSW: integer);

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

procedure SepararPalabras(s: string; var palabras: TStringArray; var cant: integer);
var p, posEsp: integer; palabra: string;
begin
  cant := 0;
  while Length(s) > 0 do
  begin
    posEsp := Pos(' ', s);
    if posEsp = 0 then palabra := s
    else palabra := Copy(s, 1, posEsp - 1);
    if palabra <> '' then
    begin
      cant := cant + 1;
      palabras[cant] := palabra;
    end;
    if posEsp = 0 then s := ''
    else Delete(s, 1, posEsp);
  end;
end;

procedure CargarStopWords(var sw: TStringArray; var cant: integer);
begin
  cant := 10;
  sw[1] := 'el'; sw[2] := 'la'; sw[3] := 'los'; sw[4] := 'las';
  sw[5] := 'que'; sw[6] := 'para'; sw[7] := 'de'; sw[8] := 'un';
  sw[9] := 'una'; sw[10] := 'es';
end;

procedure EliminarStopWords(var palabras: TStringArray; var cant: integer; sw: TStringArray; cantSW: integer);
var i, j, k: integer; esStop: boolean;
begin
  i := 1;
  while i <= cant do
  begin
    esStop := false;
    for j := 1 to cantSW do
      if palabras[i] = sw[j] then
        esStop := true;
    if esStop then
    begin
      for k := i to cant - 1 do
        palabras[k] := palabras[k + 1];
      cant := cant - 1;
    end
    else
      i := i + 1;
  end;
end;

end.