let unit = ()
let write line = print_endline line
let header = write "* ix *"

(** Driver code *)
let main =
  header;
  let code = File.read_file_content "main.ix" in
  let lexemes = Lexer.lex code in
  ignore lexemes;
  unit
;;
