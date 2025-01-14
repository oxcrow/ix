let unit = ()
let write line = print_endline line
let header = write "* ix *"

(** Print Ix AST for debugging. *)
let print_ast (ast : Ixast.executable) =
  write ("> " ^ Ixast.show_executable ast ^ "\n")
;;

(** Driver code *)
let main =
  header;
  let code = File.read_file_content "main.ix" in
  let ast =
    match Parser.parse code with
    | Error x -> x
    | Ok x -> x
  in
  print_ast ast;
  ignore ast;
  unit
;;
