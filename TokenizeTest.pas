unit TokenizeTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTokenizeTest = class
  public
    [Test]
    procedure something;
  end;

implementation

{ TTokenizeTest }

procedure TTokenizeTest.something;
begin
//  Assert.AreEqual([], );
end;

initialization
  TDUnitX.RegisterTestFixture(TTokenizeTest);

end.
