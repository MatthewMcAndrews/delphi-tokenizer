unit TokenizerTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTokenizerTest = class
  public
    [TestCase('integer', '0,0,0')]
    [TestCase('scientific notation', '1e2,1e2,0')]
    procedure numbers(const Text: string; const Token: string; const Index: Integer);
  end;

implementation

uses
  Tokenizer;

{ TTokenizerTest }

procedure TTokenizerTest.numbers(const Text: string; const Token: string; const Index: Integer);
begin
  var Tokens := TokenizeText(Text);
  var Actual := Tokens[Index];
  var Expected := Token;
  Assert.AreEqual(Expected, Actual);
end;

initialization
  TDUnitX.RegisterTestFixture(TTokenizerTest);

end.
