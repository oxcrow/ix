let whitespace = [' ''\t']
let newline = ['\n']
let digit = ['0'-'9']['0'-'9']*
let integer = ['-''+']? digit
let float = ['-''+']? digit ['.'] digit
let id = ['a'-'z''A'-'Z''_']['a'-'z''A'-'Z''0'-'9']*
let comment = "//"[^'\n']*newline

rule token = parse
  (* Simple symbols *)
  | comment { Lexing.new_line lexbuf; token lexbuf }
  | newline { Lexing.new_line lexbuf; token lexbuf }
  | whitespace { token lexbuf }

  (* Terminals *)
  | integer as lexeme { Ixparser.INTVAL(int_of_string lexeme) }
  | float as lexeme { Ixparser.FLOATVAL(float_of_string lexeme) }

  | "void" { Ixparser.VOID }
  | "int" { Ixparser.INT }
  | "float" { Ixparser.FLOAT }

  | ";" { Ixparser.SEMICOLON}
  | ":" { Ixparser.COLON}
  | "," { Ixparser.COMMA }
  | "=" { Ixparser.EQUAL }
  | "{" { Ixparser.LBRACE }
  | "}" { Ixparser.RBRACE }
  | "(" { Ixparser.LPAREN }
  | ")" { Ixparser.RPAREN }
  | "<<" {Ixparser.LARROW }
  | ">>" {Ixparser.RARROW }

  | "return" { Ixparser.RETURN}

  (* Identifiers *)
  | id as lexeme { Ixparser.IDVAL(lexeme) }

  | _ { raise (Failure ("Unknown character: " ^ Lexing.lexeme lexbuf)) }
