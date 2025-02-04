let unit = ()
let write line = print_endline line
let header = write "* ix *\n"

(** Print Ix AST for debugging. *)
let print_ast (ast : Ixast.executable) =
  write ("> " ^ Ixast.show_executable ast ^ "\n")
;;

let unwrap_error x =
  match x with
  | Ok y -> y
  | Error _ -> failwith "Unwrap failed!"
;;

(** Driver code *)
let main =
  header;
  let config = Otoml.Parser.from_file "ix.toml" in
  let name =
    Otoml.find_result config Otoml.get_string [ "src"; "name" ] |> unwrap_error
  in
  let code = File.read_file_content "main.ix" in
  let ast =
    match Parser.parse code with
    | Error x ->
      let _ = write "Fatal error: Failed to parse code." in
      x
    | Ok x -> x
  in
  write ("Compiling: " ^ name);
  print_ast ast;
  ignore config;
  ignore code;
  ignore ast;
  unit
;;
