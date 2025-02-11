let unit = ()
let write line = print_endline line
let unwrap result = Error.unwrap_result result

(* Pretty printers *)
let print_string_list = Lexer.print_string_list
let print_ast_node_list nodes string_of_node = nodes |> List.map string_of_node |> print_string_list
let print_statement_node_list nodes = print_ast_node_list nodes Ixast.show_statements

(** Data stored within interface of each module or file.

  We want to store this data to ensure that our incremental
  compilation system can access the data easily and use it to
  accelerate and parallelise our compilation.

  The idea is to simplify our work later on. */)
type interfaces =
  | InterfaceModule of
      { uses : interfaces list
      ; functions : interfaces list
      ; structs : interfaces list
      ; enums : interfaces list
      }
  | InterfaceFunction of { path : string list }
  | InterfaceUse of { path : string list list }
  | None
[@@deriving show]

let create_statement_use_interface ast =
  let accessor = Walker.get_statement_use in
  let nodes = Walker.walk_ixast_nodes accessor ast in

  let extract_id_path node =
    match node with
    | Ixast.Id (path, _) -> path
  in

  let extract_use_path node =
    match node with
    | Ixast.StatementUse x ->
      let paths = x.path in
      let paths = paths |> List.map extract_id_path in
      paths
    | _ -> failwith "Failed to extract StatementUse interfaces."
  in

  let extract use_nodes =
    let data = use_nodes |> List.map extract_use_path in
    data
  in

  let paths = extract nodes in
  let uses = InterfaceUse { path = paths } in
  Ok [ uses ]
;;

let create_module_interface ast =
  let ui = create_statement_use_interface ast |> unwrap in
  let mi = InterfaceModule { uses = ui; functions = []; structs = []; enums = [] } in
  Ok mi
;;
*)
