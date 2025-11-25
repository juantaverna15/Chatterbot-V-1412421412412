unit u_levenshtein;

interface

function Levenshtein(s, t: string): integer;

implementation

function Min(a, b, c: integer): integer;
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
  for i := 0 to Length(s) do d[i,0] := i;
  for j := 0 to Length(t) do d[0,j] := j;
  for i := 1 to Length(s) do
    for j := 1 to Length(t) do
    begin
      if s[i] = t[j] then cost := 0 else cost := 1;
      d[i,j] := Min(d[i-1,j] + 1, d[i,j-1] + 1, d[i-1,j-1] + cost);
    end;
  Levenshtein := d[Length(s), Length(t)];
end;

end.
