open Util
open Printf


type t = {
  parts : Part.t list ;
}
    

let of_json j parts = __PA__try "of_json" (
  let module Br = Json_type.Browse in
  let parts = List.map ( fun j ->
    let pname = Br.string j in
    let part = match List.find ( fun part -> part.Part.name = pname ) parts with
      | None -> __PA__failwith ("part " ^ pname ^ "not found")
      | Some p -> p
    in
      part
  ) ( Br.array j ) in
    { parts = parts ; }
) ;;
