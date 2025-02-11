%{
%}

%token <string> COMMENTVAL
%token <string> IDVAL
%token <int> USIZEVAL
%token <float> FLOATVAL
%token <string> STRINGVAL

%token UNIT USIZE FLOAT STRING

%token MODULE STRUCT ENUM FN
%token INTERFACE MACRO
%token USE LET RETURN IMPLEMENT INSTANTIATE EXTERNAL INTERNAL
%token DOT NEWLINE SEMICOLON COLONCOLON COLON COMMA
%token LBRACE RBRACE LPAREN RPAREN LBRACK RBRACK LANGLE RANGLE LARROW RARROW
%token PLUS MINUS STAR SLASH STARSTAR
%token OVERLOADPLUS OVERLOADMINUS OVERLOADSTAR OVERLOADSLASH OVERLOADSTARSTAR
%token NOT OR AND EQ EQEQ NE LT GT LE GE

%token EOF

(* Operator precedence *)
(*
** Defining this is little bit tricky so be careful.
** We define the operators with the lowest precedence + - first.
** Then we define the operators of the higher precedence ** * /.
** Our intention is to have a valid grammar that works everywhere.
*)
%left PLUS MINUS            /* lowest precedence */
%left STARSTAR STAR SLASH   /* medium precedence */
/*%nonassoc UMINUS             highest precedence */

%start executable
%type <Ixast.executable> executable

%%

(* A file can either be empty or be comprised of statements *)
executable:
  | EOF { Ixast.Executable [] }
  | sl=nonempty_list(statements); EOF { Ixast.Executable sl }
;

(* Statements which denote either a structure or operation *)
statements:
  | s=statement_module; { s }
  | s=statement_function; { s }
  | s=statement_struct; { s }
  | s=statement_value; { s }
  | s=statement_alone; { s }
  | s=statement_assign; { s }
  | s=statement_return; { s }
  | s=statement_use; { s }
  | s=statement_comment; { s }
;

statement_module:
  | loc=locate_node_raw(MODULE); s=scope; i=id;  b=blocks; { Ixast.StatementModule ({id=i; scope=s; body=b; location=loc;}) }
;

statement_function:
  | loc=locate_node_raw(FN); s=scope; i=id; g=option(generics); LPAREN a=separated_list(COMMA,argument_definition); RPAREN t=function_types_definition; b=blocks; { Ixast.StatementFunction ({id=i; type'=t; scope=s; generics=g; arguments=a; body=b; location=loc}) }
;

statement_struct:
  | loc=locate_node_raw(STRUCT); s=scope; i=id; LBRACE m=list(members); RBRACE { Ixast.StatementStruct ({id=i; scope=s; members=m; location=loc; }) }
;

statement_value:
  | loc=locate_node_raw(LET); i=separated_nonempty_list(COMMA,id); t=option(types_definition); EQ e=expressions; SEMICOLON? { Ixast.StatementValue ({ids=i; type'=t; expression=e; location=loc}) }
;
statement_alone:
  | e=expressions; { Ixast.StatementAlone (e)  }
;

statement_assign:
  | iloc=locate_node(id); EQ e=expressions; SEMICOLON? { Ixast.StatementAssign ({id=fst iloc; expression=e; location=snd iloc}) }
;

statement_return:
  | RETURN e=expressions; SEMICOLON? { Ixast.StatementReturn (e) }
;

statement_use:
  | loc=locate_node_raw(USE) p=path; SEMICOLON? { Ixast.StatementUse ({path=p; location=loc}) }
;

statement_comment:
  | cloc=locate_node(COMMENTVAL); { Ixast.StatementComment ({comment=Comment(fst cloc); location=snd cloc})}
;

expressions:
  | e=expression_function; { e }
  | e=expression_terminal; { e }
;

expression_function:
 | ploc=locate_node(path); LPAREN a=separated_list(COMMA,argument_invocation); RPAREN t=option(trailing_expression_function); { Ixast.ExpressionFunction ({path=fst ploc; arguments=a; trailing=t; location=snd ploc}) }
;

trailing_expression_function:
  | DOT t=expression_function; { t::[] }
;

expression_terminal:
  | loc=locate; x=terminals; { Ixast.ExpressionTerminal ({terminal=x; location=loc})}
;

blocks:
  | loc=locate; LBRACE s=list(statements); RBRACE { Ixast.ExpressionBlock ({body=s; location=loc}) }
;

path:
  | p =id; {  Ixast.Path (p :: []) }
  | p=path_module; { Ixast.PathModule (p) }
  | p=path_object; { Ixast.PathObject (p) }
;

path_module:
  | p1=id; COLONCOLON p2=separated_nonempty_list(COLONCOLON, id); { p1 :: p2 }
;

path_object:
  | p1=id; DOT p2=separated_nonempty_list(DOT, id); { p1 :: p2 }
;

arguments:
  | a=argument_definition; { a }
  | a=argument_invocation; { a }
;

argument_definition:
  | loc=locate; i=separated_nonempty_list(COMMA,id); COLON? t=types; { Ixast.ArgumentDefinition ({type'=t; id=i; location=loc}) }
;

argument_invocation:
  | loc=locate; e=expressions; { Ixast.ArgumentInvocation ({expressions=e; location=loc}) }
;

members:
  | doc=list(statement_comment); i=separated_nonempty_list(COMMA,id); s=scope; COLON? t=types; COMMA? { Ixast.MemberData ({doc=doc; ids=i; type'=t; scope=s;}) }
;

terminals:
  | x=USIZEVAL; { Ixast.UsizeVal ({value=x})}
  | x=FLOATVAL; { Ixast.FloatVal ({value=x})}
  | x=STRINGVAL; { Ixast.StringVal ({value=x})}
  | x=id; { Ixast.IdVal ({value=x})}
;

function_types_definition:
  | { Ixast.TypeUnit }
  | COLON? t=types; { t }
;

types_definition:
  | COLON? t=types; { t }
;

generics:
  | LANGLE g=separated_list(COMMA,generic_type) RANGLE { g }
;

generic_type:
  | i=separated_nonempty_list(COMMA, id); COLON? ix=separated_nonempty_list(PLUS, id); { Ixast.TypeGeneric ({ids=i; interfaces=ix}) }
;

types:
  | LPAREN RPAREN { Ixast.TypeUnit }
  | USIZE { Ixast.TypeUsize }
  | FLOAT { Ixast.TypeFloat }
  | LPAREN tl=separated_nonempty_list(COMMA, types); RPAREN { Ixast.TypeTuple ({types=tl})}
  | LBRACK t=types; SEMICOLON x=terminals; RBRACK { Ixast.TypeArray ({type'=t; n=x}) }
  | i=id; { Ixast.TypeDerived ({type'=i}) }
;

idscope:
  | i=id; s=scope; { (i,s) }
;

scope:
  | { Ixast.ExportStatic }
  | PLUS { Ixast.ExportLocal }
  | STAR { Ixast.ExportGlobal }
;

id:
 | loc=locate; i=IDVAL; { Ixast.Id (i, loc) }
;

let locate == {
    let startpos: Lexing.position = $startpos in
    let lnum = startpos.pos_lnum in
    let cnum = startpos.pos_cnum in
    let loc = Ixast.Location(lnum, cnum) in
    loc
}

let locate_node_raw(node) == _data=node; {
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
