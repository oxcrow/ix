%{
%}

%token <string> COMMENTVAL
%token <string> IDVAL
%token <int> INTVAL
%token <float> FLOATVAL

%token UNIT INT FLOAT

%token USE LET FN STRUCT ENUM MACRO
%token DOT NEWLINE SEMICOLON COLONCOLON COLON COMMA
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
  | s=statement_value; { s }
  | s=statement_assign; { s }
  | s=statement_return; { s }
  | s=statement_use; { s }
  | s=statement_comment; { s }
;

statement_function:
  | loc=locate_node(FN); i=id; LPAREN al=separated_list(COMMA, argument_definition); RPAREN t=option(types_definition); b=blocks; { Ixast.StatementFunction ({id=i; typex=t; arguments=al; body=b; location=snd loc}) }
;

statement_value:
  | loc=locate_node(LET); i=separated_list(COMMA,id); t=option(types_definition); EQ e=expressions; SEMICOLON? { Ixast.StatementValue ({id=i; typex=t; expression=e; location=snd loc}) }
;

statement_assign:
  | iloc=locate_node(id); EQ e=expressions; SEMICOLON? { Ixast.StatementAssign ({id=fst iloc; expression=e; location=snd iloc}) }
;

statement_return:
  | RETURN e=expressions; SEMICOLON? { Ixast.StatementReturn (e) }
;

statement_use:
  | USE ploc=locate_node(path); SEMICOLON? { Ixast.StatementUse ({path=fst ploc; location=snd ploc}) }
;

statement_comment:
  | cloc=locate_node(COMMENTVAL); { Ixast.StatementComment ({comment=Comment(fst cloc); location=snd cloc})}
;

expressions:
  | e=expression_function; { e }
  | e=expression_terminal; { e }
;

expression_function:
 | ploc=locate_node(path); LPAREN al=separated_list(COMMA,argument_invocation); RPAREN { Ixast.ExpressionFunction ({path=fst ploc;arguments=al; location=snd ploc}) }
;

expression_terminal:
  | loc=locate; x=terminals; { Ixast.ExpressionTerminal ({terminal=x; location=loc})}
;

blocks:
  | loc=locate; LBRACE sl=list(statements); RBRACE { Ixast.ExpressionBlock ({body=sl; location=loc}) }
;

path:
  | il=separated_nonempty_list(DOT, id); { il }
;

arguments:
  | a=argument_definition; { a }
  | a=argument_invocation; { a }
;

argument_definition:
  | loc=locate; il=separated_nonempty_list(COMMA,id); COLON? t=types; { Ixast.ArgumentDefinition ({typex=t; id=il; location=loc}) }
;

argument_invocation:
  | loc=locate; e=expressions; { Ixast.ArgumentInvocation ({expressions=e; location=loc}) }
;


terminals:
  | x=INTVAL; { Ixast.IntVal ({value=x})}
  | x=FLOATVAL; { Ixast.FloatVal ({value=x})}
  | x=id; { Ixast.IdVal ({value=x})}
;

types_definition:
  | COLON? t=types; { t }
;

types:
  | LPAREN RPAREN { Ixast.TypeUnit }
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
