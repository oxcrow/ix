%{
%}

%token <string> IDVAL
%token <int> INTVAL
%token <float> FLOATVAL

%token VOID INT FLOAT

%token SEMICOLON COLON COMMA
%token LBRACE RBRACE LPAREN RPAREN LANGLE RANGLE LARROW RARROW
%token ADD SUB MUL DIV EXP
%token NOT OR AND EQ EQEQ NE LT GT LE GE EX
%token RETURN

%token EOF

%start executable
%type <Ixast.executable> executable

%%

executable:
  | EOF { Ixast.Executable [] }
  | sl=nonempty_list(statements); EOF { Ixast.Executable sl }
;

statements:
  | s=statement_function; { s }
  | s=statement_return; { s }
;

statement_function:
  | tloc=locate_node(types); i=id; LPAREN RPAREN b=blocks;
    { Ixast.StatementFunction ({typex=fst tloc; id=i; body=b; location=snd tloc}) }
;

statement_return:
  | RETURN e=expressions; SEMICOLON { Ixast.StatementReturn (e) }
;

expressions:
  | e=expression_terminal; { e }
;

expression_terminal:
  | loc=locate; x=terminals; { Ixast.ExpressionTerminal ({terminal=x; location=loc})}
;

blocks:
  | loc=locate; LBRACE sl=list(statements); RBRACE { Ixast.ExpressionBlock ({body=sl; location=loc}) }
;

arguments:
  | a=argument_definition; { a }
;

argument_definition:
  | loc=locate; t=types; i=id; { Ixast.ArgumentDefinition (t, i, loc) }
;

terminals:
  | x=INTVAL; { Ixast.IntVal ({value=x})}
  | x=FLOATVAL; { Ixast.FloatVal ({value=x})}
  | x=id; { Ixast.IdVal ({value=x})}
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
    let loc = Ixast.Location(lnum, cnum) in
    loc
}

let locate_node(node) == data=node; {
    let startpos: Lexing.position = $startpos in
    let lnum = startpos.pos_lnum in
    let cnum = startpos.pos_cnum in
    let loc = Ixast.Location(lnum, cnum) in
    (data, loc)
}

