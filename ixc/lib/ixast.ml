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
      { body : statements list
      ; location : location
      }
  | StatementFunction of
      { id : id
      ; typex : types option
      ; arguments : arguments list
      ; body : expressions
      ; location : location
      }
  | StatementStruct
  | StatementEnum
  | StatementValue of
      { id : id list
      ; typex : types option
      ; expression : expressions
      ; location : location
      }
  | StatementAssign of
      { id : id
      ; expression : expressions
      ; location : location
      }
  | StatementReturn of expressions
  | StatementUse of
      { path : id list
      ; location : location
      }
  | StatementComment of
      { comment : comment
      ; location : location
      }
  | StatementNone

and expressions =
  | ExpressionOperation of
      { expressions : expressions list
      ; location : location
      }
  | ExpressionFunction of
      { path : id list
      ; arguments : arguments list
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
      ; typex : types
      ; location : location
      }
  | ArgumentInvocation of
      { expressions : expressions
      ; location : location
      }

and terminals =
  | IntVal of { value : int }
  | FloatVal of { value : float }
  | IdVal of { value : id }

and types =
  | TypeUnit
  | TypeInt
  | TypeFloat
