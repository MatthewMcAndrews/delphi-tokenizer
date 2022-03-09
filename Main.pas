unit Main;

interface

procedure Run;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  Tokenizer;

procedure Run;
begin
  var InFile: string;
  FindCmdLineSwitch('InFile', InFile);
  var OutFile: string;
  FindCmdLineSwitch('OutFile', OutFile);
  var Tokens := TokenizeFile(InFile);
  var Contents := string.Join(' ', Tokens);
  TFile.WriteAllText(OutFile, Contents);
end;

end.
