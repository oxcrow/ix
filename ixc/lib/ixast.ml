type executable = Executable of statements list
[@@deriving show { with_path = false }]

and statements =
  | StatementModule of statements list * loc
  | StatementFunction of types * id * blocks * loc
  | StatementStruct
  | StatementEnum
  | StatmentValue of types * id * expressions * loc
  | StatementReturn of expressions
[@@deriving show { with_path = false }]

and expressions =
  | ExpressionOperation of expressions list * loc
  | ExpressionInvocation of id * arguments list * loc
  | ExpressionTerminal of terminals * loc
[@@deriving show { with_path = false }]

and blocks = BlockStatement of statements list * loc
[@@deriving show { with_path = false }]

and arguments =
  | ArgumentDefinition of types * id * loc
  | ArgumentInvocation of expressions list * loc
[@@deriving show { with_path = false }]

and terminals =
  | IntVal of int
  | FloatVal of float
  | IdVal of id
[@@deriving show { with_path = false }]

and types =
  | TypeVoid
  | TypeInt
  | TypeFloat
[@@deriving show { with_path = false }]

and id = Id of string * loc [@@deriving show { with_path = false }]
and loc = Loc of int * int [@@deriving show { with_path = false }]
