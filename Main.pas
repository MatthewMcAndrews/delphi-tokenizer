unit Main;

interface

procedure Run;

implementation

uses
  System.Character,
  System.IOUtils,
  System.StrUtils,
  System.SysUtils;

{ a program is a sequence of tokens delimited by separators }
{ case insensitive }

type
  {$SCOPEDENUMS ON}
  { Tokens and Separators combine to make these }
  TThing = (
    tExpression, { syntactic units that occur within statements and denote values }
    tDeclaration, { definitions of identifiers that can be used in expressions and statements }
    tStatement { algorithmic actions that can be executed within a program }
  );
  TState = (
    sToken,
    sSeparator
  );
  TToken = (
    tSpecialSymbol,
    tIdentifier,
    tReservedWord,
    tDirective,
    tNumeral, { integers, reals, +/-, exp, $hex }
    tLabel, { identifier or uint32 }
    tString { can contain separators }
  );
  TString = (
    sQuoted, { '', can contain separators, '' = ' }
    sControl { #utf-16 }
  );
  TSeparator = (
    sBlank,
    sComment {} (**) // alike comments cannot be nested
  );
  { only the first 255 characters of an identifier are significant }
  { must begin with an alphanumeric or underscore
    may not contain spaces
    after the first character, may include digits
    may not be reserved words }
  { reserved words can be used if calls are prefixed by &- }
  { may be qualified by a namespace }
  TIdentifier = (
    iConstant,
    iVariable,
    iField,
    iType,
    iProperty,
    iProcedure,
    iFunction,
    iProgram,
    iUnit,
    iLibrary,
    iPackage
  );
  TDirective = (
    dContextSensitive, { can be used as identifiers }
    dCompilerDirective { surrounded by braces and starts with $ }
  );
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

const TokensRequiringSeparatorsBetweenThem = [
  TToken.tIdentifier,
  TToken.tReservedWord,
  TToken.tNumeral,
  TToken.tLabel];

const OneCharacterSpecialSymbols: array[0..22] of string = (
  '#', '$', '&', '''', '(', ')', '*', '+', ',', '-', '.', '/', ':', ';', '<',
  '=', '>', '@', '[', ']', '^', '{', '}');
const TwoCharacterSpecialSymbols: array[0..9] of string = (
  '(*', '(.', '*)', '.)', '..', '//', ':=', '<=', '>=', '<>');

function IsOneCharacterSpecialSymbol(const c: Char): Boolean;
begin
  for var SpecialSymbol in OneCharacterSpecialSymbols do begin
    if c = SpecialSymbol then begin
      Exit(True);
    end;
  end;
  Result := False;
end;

function IsTwoCharacterSpecialSymbol(const s : string): Boolean;
begin
  for var SpecialSymbol in TwoCharacterSpecialSymbols do begin
    if s = SpecialSymbol then begin
      Exit(True);
    end;
  end;
  Result := False;
end;

const ReservedWords: array[0..63] of string = (
  'and', 'end', 'interface', 'record', 'var', 'array', 'except', 'is', 'repeat',
  'while', 'as', 'exports', 'label', 'resourcestring', 'with', 'asm', 'file',
  'library', 'set', 'xor', 'begin', 'finalization', 'mod', 'shl', 'case',
  'finally', 'nil', 'shr', 'class', 'for', 'not', 'string', 'const', 'function',
  'object', 'then', 'constructor', 'goto', 'of', 'threadvar', 'destructor',
  'if', 'or', 'to', 'dispinterface', 'implementation', 'packed', 'try', 'div',
  'in', 'procedure', 'type', 'do', 'inherited', 'program', 'unit', 'downto',
  'initialization', 'property', 'until', 'else', 'inline', 'raise', 'uses');

const Directives: array[0..56] of string = (
  'absolute', 'export', 'name', 'public', 'stdcall', 'abstract', 'external',
  'near', 'published', 'strict', 'assembler', 'far', 'nodefault', 'read',
  'stored', 'automated', 'final', 'operator', 'readonly', 'unsafe', 'cdecl',
  'forward', 'out', 'reference', 'varargs', 'contains', 'helper', 'overload',
  'register', 'virtual', 'default', 'implements', 'override', 'reintroduce',
  'winapi', 'delayed', 'index', 'package', 'requires', 'write', 'deprecated',
  'inline', 'pascal', 'resident', 'writeonly', 'dispid', 'library', 'platform',
  'safecall', 'dynamic', 'local', 'private', 'sealed', 'experimental',
  'message', 'protected', 'static');

function TokenizeFile(const FileName: string): TArray<string>;
begin
  Result := [];
  var Text := TFile.ReadAllText(FileName);
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
    if State = TParseState.sNowhere then begin
      if c0 = '''' then begin
        State := TParseState.sQuotedString;
      end else if c0 = '#' then begin
        State := TParseState.sControlString;
      end else if c0.IsWhiteSpace then begin
        State := TParseState.sBlank;
      end else if c0.IsDigit
      or (CharInSet(c0, ['+', '-']) and c1.IsDigit) then begin
        State := TParseState.sNumeral;
      end else if c0.IsLetter or (c0 = '_') then begin
        State := TParseState.sIdentifier;
      end else if thing = '\\' then begin
        State := TParseState.sComment_Slash;
      end else if thing = '{$' then begin
        State := TParseState.sCompilerDirective;
      end else if thing = '{' then begin
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
        if not c1.IsDigit or not CharInSet(c1, ['e', 'E']) then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sIdentifier: begin
        if not c1.IsLetterOrDigit and not (c1 = '_') then begin
          State := TParseState.sNowhere;
        end;
      end;
      TParseState.sComment_Slash: begin
        if thing = #10#13 then begin
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
        if thing = '*)' then begin
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
end;

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
