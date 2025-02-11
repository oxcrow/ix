type location = Location of int * int [@@deriving show { with_path = false }]
type comment = Comment of string [@@deriving show { with_path = false }]
type id = Id of string * location [@@deriving show { with_path = false }]

type unop =
  | Not (* ! *)
  | Pos (* + *)
  | Neg (* - *)
[@@deriving show { with_path = false }]

type binop =
  | Or (* || *)
  | And (* && *)
  | Eq (* = *)
  | EqEq (* == *)
  | Ne (* != *)
  | Lt (* +< *)
  | Gt (* +> *)
  | Le (* +<= *)
  | Ge (* +>= *)
  | Add (* + *)
  | Sub (* - *)
  | Mul (* * *)
  | Div (* / *)
  | Exp (* ** *)
[@@deriving show { with_path = false }]

type executable = Executable of statements list [@@deriving show { with_path = false }]

and statements =
  | StatementModule of
      { id : id
      ; scope : scope
      ; body : expressions
      ; location : location
      }
  | StatementFunction of
      { id : id
      ; type' : types
      ; scope : scope
      ; generics : generics list option
      ; arguments : arguments list
      ; body : expressions
      ; location : location
      }
  | StatementStruct of
      { id : id
      ; scope : scope
      ; members : members list
      ; location : location
      }
  | StatementEnum
  | StatementValue of
      { ids : id list
      ; type' : types option
      ; expression : expressions
      ; location : location
      }
  | StatementAlone of expressions
  | StatementAssign of
      { id : id
      ; expression : expressions
      ; location : location
      }
  | StatementReturn of expressions
  | StatementUse of
      { path : paths
      ; location : location
      }
  | StatementComment of
      { comment : comment
      ; location : location
      }
  | StatementNone

and expressions =
  | ExpressionOperation of { expressions : expressions list }
  | ExpressionBinaryOperation of
      { left : expressions
      ; operation : operations
      ; right : expressions
      }
  | ExpressionFunction of
      { path : paths
      ; arguments : arguments list
      ; trailing : expressions list option
      ; location : location
      }
  | ExpressionTerminal of
      { terminal : terminals
      ; location : location
      }
  | ExpressionBlock of
      { body : statements list
      ; location : location
      }

and arguments =
  | ArgumentDefinition of
      { id : id list
      ; type' : types
      ; location : location
      }
  | ArgumentInvocation of
      { expressions : expressions
      ; location : location
      }

and members =
  | MemberData of
      { doc : statements list
      ; ids : id list
      ; type' : types
      ; scope : scope
      }

and paths =
  | Path of id list
  | PathModule of id list
  | PathObject of id list

and scope =
  | ExportStatic
  | ExportLocal
  | ExportGlobal

and operations =
  | BinaryPlus
  | BinaryMinus
  | BinaryStar
  | BinarySlash
  | BinaryStarStar

and terminals =
  | UsizeVal of { value : int }
  | FloatVal of { value : float }
  | StringVal of { value : string }
  | IdVal of { value : id }

and generics =
  | TypeGeneric of
      { ids : id list
      ; interfaces : id list
      }

and types =
  | TypeUnit
  | TypeUsize
  | TypeFloat
  | TypeTuple of { types : types list }
  | TypeArray of
      { type' : types
      ; n : terminals
      }
  | TypeDerived of { type' : id }
