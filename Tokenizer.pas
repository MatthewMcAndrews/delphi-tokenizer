unit Tokenizer;

interface

function TokenizeFile(const FileName: string): TArray<string>;
function TokenizeText(const Text: string): TArray<string>;

implementation

uses
  FundamentalSyntacticElements,
  System.Character,
  System.IOUtils,
  System.StrUtils,
  System.SysUtils;

type
  TParseState = (
    sNowhere,
    sQuotedString,
    sControlString,
    sBlank,
    sNumeral,
    sIdentifier,
    sComment_Slash,
    sComment_Brace,
    sComment_Paren,
    sSpecialSymbol_OneChar,
    sSpecialSymbol_TwoChar,
    sCompilerDirective
  );

function TokenizeFile(const FileName: string): TArray<string>;
begin
  var Text := TFile.ReadAllText(FileName);
  Result := TokenizeText(Text);
end;

function TokenizeText(const Text: string): TArray<string>;
begin
  Result := [];
  var Token: string;
  var State := TParseState.sNowhere;
  for var i := 1 to Text.Length do begin
    var c0 := Text[i];
    var c1 := #0;
    if i < Text.Length then begin
      c1 := Text[i+1];
    end;
    var thing := c0 + c1;
    { state entry conditions }
    const HexaDecimalCharacters: TSysCharSet = ['$', 'a'..'f', 'A'..'F'];
    if State = TParseState.sNowhere then begin
      if c0 = '''' then begin
        State := TParseState.sQuotedString;
      end else if c0 = '#' then begin
        State := TParseState.sControlString;
      end else if c0.IsWhiteSpace then begin
        State := TParseState.sBlank;
      end else if c0.IsDigit or (CharInSet(c0, ['+', '-', '$'])
      and ((c1.IsDigit) or CharInSet(c1, HexaDecimalCharacters))) then begin
        State := TParseState.sNumeral;
      end else if c0.IsLetter or (c0 = '_') then begin
        State := TParseState.sIdentifier;
      end else if thing = '//' then begin
        State := TParseState.sComment_Slash;
      end else if thing = '{$' then begin
        State := TParseState.sCompilerDirective;
      end else if c0 = '{' then begin
        State := TParseState.sComment_Brace;
      end else if thing = '(*' then begin
        State := TParseState.sComment_Paren;
      end else if IsTwoCharacterSpecialSymbol(thing) then begin
        State := TParseState.sSpecialSymbol_TwoChar;
      end else if IsOneCharacterSpecialSymbol(c0) then begin
        State := TParseState.sSpecialSymbol_OneChar;
      end else begin
        raise Exception.Create('Unable to determine new ParseState for:' + thing);
      end;
    end;
    { state exit conditions }
    case State of
      TParseState.sNowhere: begin
        raise Exception.Create('Unsupported Parse State: Nowhere!');
      end;
      TParseState.sQuotedString: begin
        { end quote, not escaping single quote }
        if (Token.Length <> 0) and (c0 = '''') and (c1 <> '''') then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sControlString: begin
        if not c1.IsDigit then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sBlank: begin
        if not c1.IsWhiteSpace then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sNumeral: begin
        if not c1.IsDigit
        and not (c1 = '.')
        and not CharInSet(c1, ['e', 'E'])
        and not CharInSet(c1, HexaDecimalCharacters) then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sIdentifier: begin
        if not c1.IsLetterOrDigit and not (c1 = '_') then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sComment_Slash: begin
        if CharInSet(c1, [#10, #13]) then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sCompilerDirective: begin
        if c0 = '}' then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sComment_Brace: begin
        if c0 = '}' then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sComment_Paren: begin
        if Token.EndsWith('*') and (c0 = ')') then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sSpecialSymbol_OneChar: begin
        if Token.Length = 0 { about to be one } then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sSpecialSymbol_TwoChar: begin
        if Token.Length = 1 { about to be two } then begin
          State := TParseState.sNowhere;
        end;
      end;
    else
      raise Exception.Create('Unsupported ParseState: ' + Ord(State).ToString);
    end;
    Token := Token + c0;
    if State = TParseState.sNowhere then begin
      Result := Result + [Token];
      Token := '';
    end;
  end;
  if Token.Length <> 0 then begin
    Result := Result + [Token];
    Token := '';
  end;
end;

end.
