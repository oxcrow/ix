let unit = ()
let space = " "
let tab = "    "

let convert_types types =
  match types with
  | Ixast.TypeVoid -> "void"
  | Ixast.TypeInt -> "i32"
  | Ixast.TypeFloat -> "f64"
;;

let convert_id id =
  match id with
  | Ixast.Id (id, _) -> "@" ^ id
;;

let rec emit ast =
  match ast with
  | Ixast.Executable statements -> List.map emit_statement statements

and emit_statement node =
  let code =
    match node with
    | Ixast.StatementFunction _ -> emit_function node
    | _ -> unit
  in
  ignore node;
  code

and emit_function node =
  let emit types id return_code =
    let code =
      [ "define" ^ space ^ types ^ space ^ id ^ "()" ^ space ^ "{"
      ; tab ^ ";; code here ..."
      ; tab ^ "ret" ^ space ^ types ^ space ^ return_code
      ; "}"
      ]
    in
    let _ = List.iter print_endline code in
    unit
  in

  let _code =
    match node with
    | Ixast.StatementFunction x ->
      let xtypes = convert_types x.typex in
      let xid = convert_id x.id in
      let _ = emit xtypes xid "0" in
      unit
    | _ -> unit
  in
  ignore node;
  unit

and emit_return node =
  ignore node;
  unit
;;
