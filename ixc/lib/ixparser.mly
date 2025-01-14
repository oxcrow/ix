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
;
