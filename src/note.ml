open Printf
open Util

type t = {
  height : string ;
  color : int ;
}

let duration_of_color t = __PA__try "duration_of_color" (
  match t.color with
    | 1 -> 4
    | 2 -> 2
    | 4 -> 1
    | n -> __PA__failwith "bad color"
) ;;

let of_json j  = __PA__try "of_json" (
  let module Br = Json_type.Browse in
  let j = Br.objekt j in
  let table =    Br.make_table j in
  let height =   Br.string ( Br.field table "height" ) in
  let color = Br.int ( Br.field table  "color" ) in
    { height = height ; color = color ; }
)
  

let to_json t = __PA__try "to_json" (
  let module Bu = Json_type.Build in
  Bu.objekt [
    "height",Bu.string t.height ;
    "color",Bu.int t.color ;
  ]
) ;;

let to_lilypond t = __PA__try "to_lilypond" (
  sprintf "%s%d" t.height t.color
) ;;
