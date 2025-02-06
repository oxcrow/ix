let unit = ()
let nil = []

(* reserved keywords and tokens to help emit code *)
let semicolon = ";"
let space = " "
let tab = "    "
let return = "return"

let string_of_types types =
  match types with
  | Ixast.TypeVoid -> "void"
  | Ixast.TypeInt -> "int"
  | Ixast.TypeFloat -> "float"
;;

let string_of_id id =
  match id with
  | Ixast.Id (id, _) -> id
;;

let emit_return node =
  ignore node;
  nil
;;

let emit_function node =
  let emit type' id return_code =
    let code =
      [ type' ^ space ^ id ^ "()" ^ space ^ "{"
      ; tab ^ return ^ space ^ return_code ^ semicolon
      ; "}"
      ]
    in
    code
  in
  let code =
    match node with
    | Ixast.StatementFunction x ->
      let xtypes = string_of_types x.typex in
      let xid = string_of_id x.id in
      let code = emit xtypes xid "0" in
      code
    | _ -> nil
  in
  code
;;

let emit_statement node =
  let code =
    match node with
    | Ixast.StatementFunction _ -> emit_function node
    | _ -> nil
  in
  code
;;

let emit ast =
  let code =
    match ast with
    | Ixast.Executable statements -> List.map emit_statement statements
  in
  Ok code
;;
