type location = Location of int * int [@@deriving show { with_path = false }]
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

type executable = Executable of statements list
[@@deriving show { with_path = false }]

and statements =
  | StatementModule of
      { body : statements list
      ; location : location
      }
  | StatementFunction of
      { typex : types
      ; id : id
      ; body : expressions
      ; location : location
      }
  | StatementStruct
  | StatementEnum
  | StatmentValue of
      { typex : types
      ; id : id
      ; expression : expressions
      ; location : location
      }
  | StatementReturn of expressions

and expressions =
  | ExpressionOperation of
      { expressions : expressions list
      ; location : location
      }
  | ExpressionInvocation of
      { id : id
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
  | ArgumentDefinition of types * id * location
  | ArgumentInvocation of expressions list * location

and terminals =
  | IntVal of { value : int }
  | FloatVal of { value : float }
  | IdVal of { value : id }

and types =
  | TypeVoid
  | TypeInt
  | TypeFloat
