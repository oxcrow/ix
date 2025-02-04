let unit = ()
let write line = print_endline line
let unwrap_result result = Error.unwrap_result result

(** Choose the node to return based on the given accessor test *)
let access_ast_node accessor node other = if accessor node then node else other

let get_statement_use node =
  match node with
  | Ixast.StatementUse _ -> true
  | _ -> false
;;

let rec walk_ixast_nodes accessor ast =
  let result =
    match ast with
    | Ixast.Executable statements -> List.map (walk_statement_nodes accessor) statements
  in
  let result = result |> List.filter accessor in
  result

and walk_statement_nodes accessor node =
  let none = Ixast.StatementNone in
  let result =
    match node with
    | Ixast.StatementFunction _ -> walk_statement_function_nodes accessor node
    | Ixast.StatementUse _ -> walk_statement_use_nodes accessor node
    | _ -> none
  in
  result

and walk_statement_function_nodes accessor node =
  ignore accessor;
  node

and walk_statement_use_nodes accessor node =
  ignore accessor;
  node
;;
