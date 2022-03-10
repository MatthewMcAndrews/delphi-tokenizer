unit TokenizerTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTokenizerTest = class
  public
    [TestCase('numbers integer', '0,0,0')]
    [TestCase('numbers negative integer', '-12,-12,0')]
    [TestCase('numbers real', '1.2,1.2,0')]
    [TestCase('numbers negative real', '-1.2,-1.2,0')]
    [TestCase('numbers scientific notation', '1e2,1e2,0')]
    [TestCase('numbers negative scientific notation', '-3e4,-3e4,0')]
    [TestCase('numbers hexadecimal', '$0aF,$0aF,0')]
    [TestCase('numbers negative hexadecimal', '-$0aF,-$0aF,0')]
    [TestCase('identifiers alpha', 'a,a,0')]
    [TestCase('identifiers alphanumeric', 'a1,a1,0')]
    [TestCase('identifiers underscore', '_,_,0')]
    [TestCase('identifiers underscore alphanumeric', '_a1,_a1,0')]
    [TestCase('identifiers middle underscore', 'a_a,a_a,0')]
    [TestCase('control_string new line', '#10,#10,0')]
    [TestCase('quoted_string plain', '''a'',''a'',0')]
    [TestCase('quoted_string contains slash comment', '''a // b'',''a // b'',0')]
    [TestCase('quoted_string contains brace comment', '''a {b}'',''a {b}'',0')]
    [TestCase('quoted_string contains paren comment', '''a (*b*)'',''a (*b*)'',0')]
    [TestCase('blank space', ' , ,0')]
    [TestCase('blank newline', #10#13','#10#13',0')]
    [TestCase('blank mixed', #10#13' ,'#10#13' ,0')]
    [TestCase('comment slash', '//a,//a,0')]
    [TestCase('comment slash end', '//a'#10#13',//a,0')]
    [TestCase('comment brace', '{a},{a},0')]
    [TestCase('comment paren', '(*a*),(*a*),0')]
    [TestCase('comment nested', '(*{a}*),(*{a}*),0')]
    [TestCase('comment contains string', '(*''a''*),(*''a''*),0')]
    [TestCase('special_characters not equal', '<>,<>,0')]
    [TestCase('special_characters dot', '.,.,0')]
    [TestCase('compiler_directive plain', '{$M+},{$M+},0')]
    [TestCase('compiler_directive with arg', '{$IFDEF TRUE},{$IFDEF TRUE},0')]
    procedure SingleToken(const Text: string; const Token: string; const Index: Integer);
  end;

implementation

uses
  Tokenizer;

{ TTokenizerTest }

procedure TTokenizerTest.SingleToken(const Text: string; const Token: string; const Index: Integer);
begin
  var Tokens := TokenizeText(Text);
  var Actual := Tokens[Index];
  var Expected := Token;
  Assert.AreEqual(Expected, Actual);
end;

initialization
  TDUnitX.RegisterTestFixture(TTokenizerTest);

end.
