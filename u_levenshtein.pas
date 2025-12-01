unit u_levenshtein;

interface

{distancia de Levenshtein: Es el número mínimo de operaciones necesarias para transformar una palabra en otra.Insertar un carácter,Eliminar un carácter
O Reemplazar un carácter}

function Levenshtein(s, t: string): integer;

implementation

function Min(a, b, c: integer): integer;      {Se usa para decidir cuál de las tres operaciones (insertar, eliminar o reemplazar) tiene el menor costo.}
begin
  if (a <= b) and (a <= c) then Min := a
  else if (b <= a) and (b <= c) then Min := b
  else Min := c;
end;

function Levenshtein(s, t: string): integer;
var
  d: array[0..30,0..30] of integer;
  i, j, cost: integer;
begin
  for i := 0 to Length(s) do d[i,0] := i;   {inicializa la matriz}
  for j := 0 to Length(t) do d[0,j] := j;
  for i := 1 to Length(s) do        {Recorre toda la matriz d, comparando cada letra de s con cada letra de t.}
    for j := 1 to Length(t) do
    begin
      if s[i] = t[j] then cost := 0 else cost := 1;
      d[i,j] := Min(d[i-1,j] + 1, d[i,j-1] + 1, d[i-1,j-1] + cost);   {Calcula el mínimo entre tres posibles operaciones:}
    end;
  Levenshtein := d[Length(s), Length(t)]; {guarda la distancia , a menor distancia mayor similitud, si es 0 son iguales y si es mayor a 2 son diferentes}
end;

end.
