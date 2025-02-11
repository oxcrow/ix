let whitespace = [' ''\t']
let newline = ['\r''\n'] | "\r\n"
let digit = ['0'-'9']['0'-'9']*
let integer = ['-''+']? digit
let float = ['-''+']? digit ['.'] digit
let string = ['\"'][^'\"']*['\"']
let id = ['a'-'z''A'-'Z''_']['a'-'z''A'-'Z''0'-'9''_']*['\'']*
let comment = "//"[^'\n']*newline

rule token = parse
  (* Simple symbols *)
  | comment as lexeme { Lexing.new_line lexbuf; Ixparser.COMMENTVAL (lexeme) }
  | newline { Lexing.new_line lexbuf; token lexbuf }
  | whitespace { token lexbuf }

  (* Terminals *)
  | integer as lexeme { Ixparser.USIZEVAL(int_of_string lexeme) }
  | float as lexeme { Ixparser.FLOATVAL(float_of_string lexeme) }
  | string as string { Ixparser.STRINGVAL(string) }

  | "usize" { Ixparser.USIZE }
  | "float" { Ixparser.FLOAT }
  | "string" { Ixparser.STRING }

  | "module" { Ixparser.MODULE }
  | "struct" { Ixparser.STRUCT }
  | "enum" { Ixparser.ENUM }
  | "fn" { Ixparser.FN }

  | "interface" { Ixparser.INTERFACE }
  | "macro" { Ixparser.MACRO }

  | "use" { Ixparser.USE }
  | "let" { Ixparser.LET }
  | "return" { Ixparser.RETURN}
  | "implement" { Ixparser.IMPLEMENT }
  | "instantiate" { Ixparser.INSTANTIATE }
  | "external" { Ixparser.EXTERNAL }
  | "internal" { Ixparser.INTERNAL }

  | "." { Ixparser.DOT }
  | ";" { Ixparser.SEMICOLON}
  | "::" { Ixparser.COLONCOLON }
  | ":" { Ixparser.COLON}
  | "," { Ixparser.COMMA }
  | "{" { Ixparser.LBRACE }
  | "}" { Ixparser.RBRACE }
  | "(" { Ixparser.LPAREN }
  | ")" { Ixparser.RPAREN }
  | "[" { Ixparser.LBRACK }
  | "]" { Ixparser.RBRACK }
  | "<" { Ixparser.LANGLE }
  | ">" { Ixparser.RANGLE }
  | "<-" { Ixparser.LARROW }
  | "->" { Ixparser.RARROW }

  | "+" { Ixparser.PLUS }
  | "-" { Ixparser.MINUS }
  | "*" { Ixparser.STAR }
  | "/" { Ixparser.SLASH }
  | "**" { Ixparser.STARSTAR }

  | ".+." { Ixparser.OVERLOADPLUS }
  | ".-." { Ixparser.OVERLOADMINUS }
  | ".*." { Ixparser.OVERLOADSTAR }
  | "./." { Ixparser.OVERLOADSLASH }
  | ".**." { Ixparser.OVERLOADSTARSTAR }

  | "!" { Ixparser.NOT }
  | "||" { Ixparser.OR }
  | "&&" { Ixparser.AND }
  | "=" { Ixparser.EQ }
  | "==" { Ixparser.EQEQ }
  | "!=" { Ixparser.NE }
  | "+<" { Ixparser.LT }
  | "+>" { Ixparser.GT }
  | "+<=" { Ixparser.LE }
  | "+>=" { Ixparser.GE }


  (* Identifiers *)
  | id as lexeme { Ixparser.IDVAL(lexeme) }

  (* Catch'em all! *)
  | eof { Ixparser.EOF }
  | _ { raise (Failure ("Unknown character: " ^ Lexing.lexeme lexbuf)) }
