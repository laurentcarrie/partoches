open Util
open Printf


type t = {
  name : string ;
  bars : Bar.t list ;
}


let of_json j = __PA__try "of_json" (
  let module Br = Json_type.Browse in
  let j = Br.objekt j in
  let table = Br.make_table j in
  let name = Br.string (Br.field table "name") in
  let () = log Debug "name : %s" name in
  let bars = Br.list Bar.of_json (Br.field table "bars") in
    { name = name ; bars = bars }
) ;;


let to_lilypond t = __PA__try "to_lilypond" (
  sprintf "\n\
%s = { %s } "
    t.name
    (List.fold_left ( fun acc b -> acc ^ " " ^ (Bar.to_lilypond b)) "" t.bars)
) ;;
