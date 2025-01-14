type executable = Executable of statements list
[@@deriving show { with_path = false }]

and statements =
  | StatementModule of statements list * loc
  | StatementFunction of types * id * arguments list * blocks * loc
  | StatementStruct
  | StatementEnum
  | StatmentValue of types * id * expressions * loc
[@@deriving show { with_path = false }]

and expressions =
  | ExpressionOperation of expressions list * loc
  | ExpressionInvocation of id * arguments list * loc
  | ExperssionTerminal of terminals * loc
[@@deriving show { with_path = false }]

and blocks = BlockStatement of statements list * loc
[@@deriving show { with_path = false }]

and arguments =
  | ArgumentDefinition of types * id * loc
  | ArgumentInvocation of expressions list * loc
[@@deriving show { with_path = false }]

and terminals =
  | TerminalInt of int * loc
  | TerminalFloat of float * loc
  | TerminalId of id * loc
[@@deriving show { with_path = false }]

and types =
  | Void
  | Int
  | Float
[@@deriving show { with_path = false }]

and id = Id of string [@@deriving show { with_path = false }]
and loc = Loc of int * int [@@deriving show { with_path = false }]
