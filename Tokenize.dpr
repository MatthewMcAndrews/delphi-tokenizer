program Tokenize;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Main in 'Main.pas',
  FundamentalSyntacticElements in 'FundamentalSyntacticElements.pas',
  Tokenizer in 'Tokenizer.pas';

begin
  try
    Run;
  except
    on E: Exception do begin
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;
end.
