let unit = ()
let write line = print_endline line

(** Print list of strings similar to utop *)
let print_string_list list =
  let print_string_list_component string =
    let _ = print_string "\"" in
    let _ = print_string string in
    let _ = print_string "\"; " in
    unit
  in
  let _ = print_string "[" in
  let _ = list |> List.iter print_string_list_component in
  let _ = print_string "]" in
  let _ = print_endline "" in
  unit
;;

(** Split code on newlines to return a list of each line. *)
let split_by_newlines string : string list =
  let split = string |> String.split_on_char '\n' in
  split
;;

(** Lex code. *)
let lex code =
  let split = split_by_newlines code in
  ignore split;
  unit
;;
