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
    [TestCase('new line', '#10,#10,0')]
    procedure control_string(const Text: string; const Token: string; const Index: Integer);
    [TestCase('plain', '''a'',''a'',0')]
    [TestCase('contains slash comment', '''a // b'',''a // b'',0')]
    [TestCase('contains brace comment', '''a {b}'',''a {b}'',0')]
    [TestCase('contains paren comment', '''a (*b*)'',''a (*b*)'',0')]
    procedure quoted_string(const Text: string; const Token: string; const Index: Integer);
    [TestCase('space', ' , ,0')]
    [TestCase('newline', #10#13','#10#13',0')]
    [TestCase('mixed', #10#13' ,'#10#13' ,0')]
    procedure blank(const Text: string; const Token: string; const Index: Integer);
    [TestCase('slash', '//a,//a,0')]
    [TestCase('slash', '//a'#10#13',//a,0')]
    [TestCase('brace', '{a},{a},0')]
    [TestCase('paren', '(*a*),(*a*),0')]
    [TestCase('nested', '(*{a}*),(*{a}*),0')]
    [TestCase('contains string', '(*''a''*),(*''a''*),0')]
    procedure comment(const Text: string; const Token: string; const Index: Integer);
    [TestCase('not equal', '<>,<>,0')]
    [TestCase('dot', '.,.,0')]
    procedure special_characters(const Text: string; const Token: string; const Index: Integer);
    [TestCase('plain', '{$M+},{$M+},0')]
    [TestCase('with arg', '{$IFDEF TRUE},{$IFDEF TRUE},0')]
    procedure compiler_directive(const Text: string; const Token: string; const Index: Integer);
  private
    procedure Test(const Text: string; const Token: string; const Index: Integer);
  end;

implementation

uses
  Tokenizer;

{ TTokenizerTest }

procedure TTokenizerTest.blank(const Text: string; const Token: string; const Index: Integer);
begin
  Test(Text, Token, Index);
end;

procedure TTokenizerTest.comment(const Text: string; const Token: string; const Index: Integer);
begin
  Test(Text, Token, Index);
end;

procedure TTokenizerTest.compiler_directive(const Text: string; const Token: string; const Index: Integer);
begin
  Test(Text, Token, Index);
end;

procedure TTokenizerTest.control_string(const Text: string; const Token: string; const Index: Integer);
begin
  Test(Text, Token, Index);
end;

procedure TTokenizerTest.identifiers(const Text: string; const Token: string; const Index: Integer);
begin
  Test(Text, Token, Index);
end;

procedure TTokenizerTest.numbers(const Text: string; const Token: string; const Index: Integer);
begin
  Test(Text, Token, Index);
end;

procedure TTokenizerTest.quoted_string(const Text: string; const Token: string; const Index: Integer);
begin
  Test(Text, Token, Index);
end;

procedure TTokenizerTest.special_characters(const Text: string; const Token: string; const Index: Integer);
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
