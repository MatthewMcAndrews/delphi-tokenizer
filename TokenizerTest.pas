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
    [TestCase('alpha', 'a,a,0')]
    [TestCase('alphanumeric', 'a1,a1,0')]
    [TestCase('underscore', '_,_,0')]
    [TestCase('underscore alphanumeric', '_a1,_a1,0')]
    [TestCase('middle underscore', 'a_a,a_a,0')]
    procedure identifiers(const Text: string; const Token: string; const Index: Integer);
  private
    procedure Test(const Text: string; const Token: string; const Index: Integer);
  end;

implementation

uses
  Tokenizer;

{ TTokenizerTest }

procedure TTokenizerTest.identifiers(const Text: string; const Token: string; const Index: Integer);
begin
  Test(Text, Token, Index);
end;

procedure TTokenizerTest.numbers(const Text: string; const Token: string; const Index: Integer);
begin
  Test(Text, Token, Index);
end;

procedure TTokenizerTest.Test(const Text: string; const Token: string; const Index: Integer);
begin
  var Tokens := TokenizeText(Text);
  var Actual := Tokens[Index];
  var Expected := Token;
  Assert.AreEqual(Expected, Actual);
end;

initialization
  TDUnitX.RegisterTestFixture(TTokenizerTest);

end.
