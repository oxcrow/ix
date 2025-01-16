let unit = ()
let write line = print_endline line
let header = write "* ix *\n"

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
    | Error x ->
      let _ = write "Fatal error: Failed to parse code." in
      x
    | Ok x -> x
  in
  let _ = print_ast ast in
  let _ = Emitter.emit ast in
  ignore code;
  ignore ast;
  unit
;;
