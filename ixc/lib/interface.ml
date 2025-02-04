let unit = ()
let write line = print_endline line
let print_string_list = Lexer.print_string_list
let unwrap_result result = Error.unwrap_result result
let print_ast_node_list nodes string_of_node = nodes |> List.map string_of_node |> print_string_list
let print_statement_node_list nodes = print_ast_node_list nodes Ixast.show_statements

type interfaces =
  | InterfaceModule of
      { uses : interfaces list
      ; functions : interfaces list
      ; structs : interfaces list
      ; enums : interfaces list
      }
  | InterfaceFunction of { path : string list }
  | InterfaceUse of { path : string list }
  | None

let create_statement_use_interface ast =
  let accessor = Walker.get_statement_use in
  let uses = Walker.walk_ixast_nodes accessor ast in
  ignore uses;
  Ok []
;;

let create_module_interface ast =
  let ui = create_statement_use_interface ast |> unwrap_result in
  let mi = InterfaceModule { uses = ui; functions = []; structs = []; enums = [] } in
  Ok mi
;;
