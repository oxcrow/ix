let whitespace = [' ''\t']
let newline = ['\r''\n'] | "\r\n"
let digit = ['0'-'9']['0'-'9']*
let integer = ['-''+']? digit
let float = ['-''+']? digit ['.'] digit
let id = ['a'-'z''A'-'Z''_']['a'-'z''A'-'Z''0'-'9''_']*
let comment = "//"[^'\n']*newline

rule token = parse
  (* Simple symbols *)
  | comment as lexeme { Ixparser.COMMENTVAL (lexeme)}
  | newline { Lexing.new_line lexbuf; token lexbuf }
  | whitespace { token lexbuf }

  (* Terminals *)
  | integer as lexeme { Ixparser.INTVAL(int_of_string lexeme) }
  | float as lexeme { Ixparser.FLOATVAL(float_of_string lexeme) }

  | "void" { Ixparser.VOID }
  | "int" { Ixparser.INT }
  | "float" { Ixparser.FLOAT }

  | "." { Ixparser.DOT }
  | ";" { Ixparser.SEMICOLON}
  | "::" { Ixparser.COLONCOLON }
  | ":" { Ixparser.COLON}
  | "," { Ixparser.COMMA }
  | "{" { Ixparser.LBRACE }
  | "}" { Ixparser.RBRACE }
  | "(" { Ixparser.LPAREN }
  | ")" { Ixparser.RPAREN }
  | "<" { Ixparser.LANGLE }
  | ">" { Ixparser.RANGLE }
  | "<-" { Ixparser.LARROW }
  | "->" { Ixparser.RARROW }

  | "+" { Ixparser.ADD }
  | "-" { Ixparser.SUB }
  | "*" { Ixparser.MUL }
  | "/" { Ixparser.DIV }
  | "**" { Ixparser.EXP }

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

  | "use" { Ixparser.USE }
  | "return" { Ixparser.RETURN}

  (* Identifiers *)
  | id as lexeme { Ixparser.IDVAL(lexeme) }

  (* Catch'em all! *)
  | eof { Ixparser.EOF }
  | _ { raise (Failure ("Unknown character: " ^ Lexing.lexeme lexbuf)) }
