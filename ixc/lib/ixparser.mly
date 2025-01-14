%{
%}

%token <string> IDVAL
%token <int> I32VAL
%token <float> F64VAL

%token VOID I32 F64

%token SEMICOLON COLON COMMA EQUAL
%token LBRACE RBRACE LPAREN RPAREN LARROW RARROW
%token RETURN

%token EOF

%start executable
%type <Ixast.executable> executable

%%

executable:
  | EOF { Ixast.Executable [] }
;
