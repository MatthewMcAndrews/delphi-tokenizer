unit FundamentalSyntacticElements;

interface

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
  { ends with a semicolon }
  TDeclaration = (
    dHintDirecticve, { e.g. deprecated; experimental; }
    dVariable,
    dConstant,
    dType,
    dField,
    dProperty,
    dProcedure,
    dFunction,
    dProgram,
    dUnit,
    dLibrary,
    dPackage
  );
  TStatement = (
    sAssignment, { variable := expression }
    sProcedureCall, { name; name(arg); name(arg1,...); }
    sFunctionCall,
    sGotoJump { goto label, label: statement, label label1, label2; }
  );
  TVariable = (
    vVariableTypecast,
    vDereferencedPointer,
    vStructuredVariableComponent
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
function IsTwoCharacterSpecialSymbol(const s : string): Boolean;

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

implementation

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

end.
