let unit = ()
let write line = print_endline line
let unwrap result = Error.unwrap_result result
let header = write " * ix *\n"

(** Print Ix AST for debugging. *)
let print_ast (ast : Ixast.executable) = write (" + " ^ Ixast.show_executable ast ^ "\n")

(** Print compiled code *)
let print_asm asm = asm |> List.iter (List.iter write)

(** Extract string value from toml table *)
let get_toml_string config x = Otoml.find_result config Otoml.get_string x

(** Driver code *)
let main =
  header;
  let config = Otoml.Parser.from_file "ix.toml" in
  let name = get_toml_string config [ "src"; "name" ] |> unwrap in

  let code = File.read_file_content "main.ix" in
  let ast = Parser.parse code |> unwrap in
  let asm = Emitter.emit ast |> unwrap in

  print_asm asm;

  ignore config;
  ignore name;
  ignore code;
  ignore ast;
  ignore asm;
  unit
;;
