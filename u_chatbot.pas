unit u_chatbot;

interface

uses u_conocimiento, u_texto;

procedure Conversar;

implementation

var
  conocimiento: TBaseConocimiento;
  cantRegistros: integer;
  stopwords: TStringArray;
  cantStop: integer;
  entrada, respuesta: string;

procedure Conversar;
begin
  CargarStopWords(stopwords, cantStop);
  CargarConocimiento(conocimiento, cantRegistros);
  WriteLn('Chatbot Informático: ¡Hola! Soy tu asistente de informática para principiantes.');
  WriteLn('Escribí "salir" o "chau" para terminar.');
  WriteLn;
  repeat
    Write('>: ');
    ReadLn(entrada);
    entrada := Minusculas(entrada);
    if (Pos('salir', entrada) = 0) and (Pos('chau', entrada) = 0) and (Pos('adiós', entrada) = 0) then
    begin
      respuesta := BuscarRespuesta(conocimiento, cantRegistros, entrada, stopwords, cantStop);
      WriteLn('>: ', respuesta);
    end;
  until (Pos('salir', entrada) > 0) or (Pos('chau', entrada) > 0) or (Pos('adiós', entrada) > 0);
  WriteLn('> : ¡Hasta luego! Fue un gusto charlar contigo :).');
end;

end.
