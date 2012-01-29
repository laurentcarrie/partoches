open Util
open Printf


type t = {
  parts : (Part.t * int (* mesure de demarrage *) ) list ;
}
    

let of_json j defined_parts = __PA__try "of_json" (
  let module Br = Json_type.Browse in
  let parts = __PA__try "parts" (List.map ( fun j ->
    let pname = __PA__try "name" (Br.string j) in
    let part = match List.find ( fun part -> part.Part.name = pname ) defined_parts with
      | None -> __PA__failwith ("part " ^ pname ^ "not found")
      | Some p -> p
    in
      part
  )  (Br.array j) ) in 

  let (parts,_) = List.fold_left ( fun (parts,start) p ->
    (p,start) :: parts,start+p.Part.nbars ) ([],1) parts
  in
  { parts = List.rev parts ; }
) ;;

let to_json t = __PA__try "to_json" (
  let module Bu = Json_type.Build in
  Bu.list ( fun (p,_) -> Bu.string p.Part.name) t.parts
) ;;


