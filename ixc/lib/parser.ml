let unit = ()
let write line = print_endline line

(** Parse Ix code and create AST *)
let parse (code : string) =
  let error : bool ref = { contents = false } in
  let lexer_buffer = Lexing.from_string code in
  let empty = Ixast.Executable [] in
  let ast =
    try Ixparser.executable Ixlexer.token lexer_buffer with
    | Ixparser.Error ->
      error := true;
      empty
  in
  if !error then Error ast else Ok ast
;;
