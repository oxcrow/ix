%{
%}

%token <string> IDVAL
%token <int> INTVAL
%token <float> FLOATVAL

%token VOID INT FLOAT

%token SEMICOLON COLON COMMA EQUAL
%token LBRACE RBRACE LPAREN RPAREN LARROW RARROW
%token RETURN

%token EOF

%start executable
%type <Ixast.executable> executable

%%

executable:
  | EOF { Ixast.Executable [] }
  | sl=statements; { Ixast.Executable [sl] }
;

statements:
  | s=statement_function; { s }
  | s=statement_return; { s }
;

statement_function:
  | t_loc=locate_node(types); i=id; LPAREN RPAREN b=blocks; { Ixast.StatementFunction (fst t_loc, i, b, snd t_loc) }
;

statement_return:
  | RETURN e=expressions; SEMICOLON { Ixast.StatementReturn (e) }
;

expressions:
  | e=expression_terminal; { e }
;

expression_terminal:
  | loc=locate; x=terminals; { Ixast.ExpressionTerminal (x, loc)}
;

blocks:
  | loc=locate; LBRACE sl=list(statements); RBRACE { Ixast.BlockStatement (sl, loc) }
;

arguments:
  | a=argument_definition; { a }
;

argument_definition:
  | loc=locate; t=types; i=id; { Ixast.ArgumentDefinition (t, i, loc) }
;

terminals:
  | x=INTVAL; { Ixast.IntVal (x)}
  | x=FLOATVAL; { Ixast.FloatVal (x)}
  | x=id; { Ixast.IdVal (x)}
;

types:
  | VOID { Ixast.TypeVoid }
  | INT { Ixast.TypeInt }
  | FLOAT { Ixast.TypeFloat }
;

id:
 | loc=locate; i=IDVAL; { Ixast.Id (i, loc) }

let locate == {
    let startpos: Lexing.position = $startpos in
    let lnum = startpos.pos_lnum in
    let cnum = startpos.pos_cnum in
    let loc = Ixast.Loc(lnum, cnum) in
    loc
}

let locate_node(node) == data=node; {
    let startpos: Lexing.position = $startpos in
    let lnum = startpos.pos_lnum in
    let cnum = startpos.pos_cnum in
    let loc = Ixast.Loc(lnum, cnum) in
    (data, loc)
}

