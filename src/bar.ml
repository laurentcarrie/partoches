open Util
open Printf

type t = 
    | NL of Note.t list 
    | CL of Chord.t list 


let empty_bar = NL [ { Note.height = "r" ; color = 1 } ]

let to_string t = 
  match t with
    | NL nl -> List.fold_left ( fun acc n -> sprintf "%s ; %s %d" acc n.Note.height n.Note.color) "" nl
    | CL _ -> __PA__NOT_IMPLEMENTED__

let valid t = match t with
    | NL nl ->  
	let d = List.fold_left ( fun d note -> d + (Note.duration_of_color note)) 0 nl in
	  if d=4 then t else __PA__failwith ("bad duration for bar ; " ^ (to_string t))
    | CL _ -> __PA__NOT_IMPLEMENTED__

let of_json (j:Json_type.t) : t = __PA__try "of_json" (
  
  let module Br = Json_type.Browse in
  let notes = Br.list Note.of_json j  in
  let t = valid (NL notes) in
    t
) ;;

let to_json t = __PA__try "to_json" (
  let module Bu = Json_type.Build in
  match t with
    | NL nl -> Bu.list Note.to_json nl
    | CL _ -> __PA__NOT_IMPLEMENTED__
) ;;

let to_lilypond t = __PA__try "to_lilypond" (
  match t with
    | NL nl ->
	List.fold_left ( fun acc n -> acc ^ " " ^ (Note.to_lilypond n)  ) "" nl
    | CL _ -> __PA__NOT_IMPLEMENTED__
) ;;
