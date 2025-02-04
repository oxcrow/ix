(** Unwrap result or crash *)
let unwrap_result x =
  match x with
  | Ok y -> y
  | Error _ -> failwith "Unwrap failed!"
;;

(** Unwrap option or crash *)
let unwrap_option x =
  match x with
  | Some y -> y
  | None -> failwith "Unwrap failed!"
;;
