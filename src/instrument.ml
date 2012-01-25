open Util
open Printf

type t = {
  name : string ;
  midi : string ;
}

let of_json (j:Json_type.t) : t = __PA__try "of_json" (
  let module Br = Json_type.Browse in
  let j = Br.objekt j in
  let table = Br.make_table j in
  let name = Br.string (Br.field table "name") in
  let midi = Br.string (Br.field table "midi") in
    { name = name ; midi = midi }
) ;;


