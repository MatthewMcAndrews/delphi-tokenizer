unit TokenizerTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTokenizerTest = class
  public
    [Test]
    procedure something;
  end;

implementation

{ TTokenizerTest }

procedure TTokenizerTest.something;
begin
//  Assert.AreEqual([], );
end;

initialization
  TDUnitX.RegisterTestFixture(TTokenizerTest);

end.
