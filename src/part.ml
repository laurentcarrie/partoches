open Util
open Printf


type t = {
  name : string ;
  bars : ( Instrument.t * Bar.t list ) list ;
}




let of_json instruments j = __PA__try "of_json" (
  let module Br = Json_type.Browse in
  let j = Br.objekt j in
  let table = Br.make_table j in
  let name = Br.string (Br.field table "name") in
  let () = log Debug "name : %s" name in

  let bars = List.map ( 
    fun j ->
      let j = Br.objekt j in 
      let table = Br.make_table j in
      let instrument = Br.string ( Br.field table "instrument" ) in
      let instrument = match List.find ( fun i -> i.Instrument.name = instrument ) instruments with
	| Some i -> i
	| None -> __PA__failwith ("no such instrument " ^ instrument)
      in
      let bars = Br.list Bar.of_json (Br.field table "bars") in
	(instrument,bars)
  ) (Br.array (Br.field table "instruments")) in 

    { name = name ; bars = bars }
) ;;


let to_lilypond t = __PA__try "to_lilypond" (
  List.fold_left ( fun acc (instrument,bars) -> sprintf "%s\n\
%s%s = { 
\\mark \\markup { \\italic { %s } }
%s } "
    acc
    t.name instrument.Instrument.name
    t.name
    (List.fold_left ( fun acc b -> acc ^ " " ^ (Bar.to_lilypond b)) " \\bar \"||\" " bars)
  ) "" t.bars
) ;;


	     
	     
