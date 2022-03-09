unit TokenizerTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTokenizerTest = class
  public
    [TestCase('integer', '0,0,0')]
    [TestCase('negative integer', '-12,-12,0')]
    [TestCase('real', '1.2,1.2,0')]
    [TestCase('negative real', '-1.2,-1.2,0')]
    [TestCase('scientific notation', '1e2,1e2,0')]
    [TestCase('negative scientific notation', '-3e4,-3e4,0')]
    [TestCase('hexadecimal', '$0aF,$0aF,0')]
    [TestCase('negative hexadecimal', '-$0aF,-$0aF,0')]
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
