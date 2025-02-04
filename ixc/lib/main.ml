let unit = ()
let write line = print_endline line
let unwrap_result result = Error.unwrap_result result
let header = write " * ix *\n"

(** Print Ix AST for debugging. *)
let print_ast (ast : Ixast.executable) = write (" + " ^ Ixast.show_executable ast ^ "\n")

(** Extract string value from toml table *)
let get_toml_string config x = Otoml.find_result config Otoml.get_string x

(** Driver code *)
let main =
  header;
  let config = Otoml.Parser.from_file "ix.toml" in
  let name = get_toml_string config [ "src"; "name" ] |> unwrap_result in
  write (" + Compiling: " ^ name);

  let code = File.read_file_content "main.ix" in
  let ast = Parser.parse code |> unwrap_result in
  let mi = Interface.create_module_interface ast |> unwrap_result in

  ignore config;
  ignore code;
  ignore ast;
  ignore mi;
  unit
;;
