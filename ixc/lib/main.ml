let unit = ()
let write line = print_endline line
let header = write " * ix *\n"

(** Print Ix AST for debugging. *)
let print_ast (ast : Ixast.executable) = write (" + " ^ Ixast.show_executable ast ^ "\n")

(** Unwrap result or crash *)
let unwrap_result x =
  match x with
  | Ok y -> y
  | Error _ -> failwith "Unwrap failed!"
;;

(** Extract string value from toml table *)
let get_toml_string config x = Otoml.find_result config Otoml.get_string x

(** Driver code *)
let main =
  header;
  let config = Otoml.Parser.from_file "ix.toml" in
  let name = get_toml_string config [ "src"; "name" ] |> unwrap_result in
  let code = File.read_file_content "main.ix" in
  let ast = Parser.parse code |> unwrap_result in
  write (" + Compiling: " ^ name);
  print_ast ast;
  ignore config;
  ignore code;
  ignore ast;
  unit
;;
