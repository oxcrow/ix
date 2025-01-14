type loc = Loc of int * int

(* Silence annoying Location output when printing AST. *)
let show_loc _ = ""
let pp_loc _ _ = ()

type id = Id of string * loc [@@deriving show { with_path = false }]

type executable = Executable of statements list
[@@deriving show { with_path = false }]

and statements =
  | StatementModule of statements list * loc
  | StatementFunction of types * id * blocks * loc
  | StatementStruct
  | StatementEnum
  | StatmentValue of types * id * expressions * loc
  | StatementReturn of expressions

and expressions =
  | ExpressionOperation of expressions list * loc
  | ExpressionInvocation of id * arguments list * loc
  | ExpressionTerminal of terminals * loc

and blocks = BlockStatement of statements list * loc

and arguments =
  | ArgumentDefinition of types * id * loc
  | ArgumentInvocation of expressions list * loc

and terminals =
  | IntVal of int
  | FloatVal of float
  | IdVal of id

and types =
  | TypeVoid
  | TypeInt
  | TypeFloat
