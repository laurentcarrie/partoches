open Util
open Printf


type t = {
  name : string ;
  nbars : int ;
  bars : ( Instrument.t * Bar.t list ) list ;
}

let fill_with_rest instruments t = __PA__try "fill_with_rest" (
  let bars = List.map ( fun (i,bars) ->
    let gap = t.nbars - List.length bars in
    let () = if gap < 0 then __PA__failwith "invariant error" else () in
    let bars = bars @ (List.init gap ( fun _ -> Bar.empty_bar)) in
      i,bars
  ) t.bars in
  let bars =  List.fold_left ( fun acc i ->
    match List.find ( fun (o,_) -> o = i ) bars with
      | Some b -> b :: acc
      | None -> (i,List.init t.nbars ( fun _ -> Bar.empty_bar)) :: acc
  ) [] instruments in
    { t with bars=List.rev bars }
) ;;


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
      let () = log Debug "bar, instrument : %s" instrument in
      let instrument = match List.find ( fun i -> i.Instrument.name = instrument ) instruments with
	| Some i -> i
	| None -> __PA__failwith ("no such instrument " ^ instrument)
      in
      let bars = Br.list Bar.of_json (Br.field table "bars") in
	(instrument,bars)
  ) (Br.array (Br.field table "instruments")) in 

  let nbars = List.fold_left ( fun nbars (_,l) ->
    if (nbars > List.length l) then nbars else List.length l
  ) 0 bars in
  let t = { name = name ; nbars = nbars ; bars = bars } in
    fill_with_rest instruments t
) ;;

let to_json t = __PA__try "to_json" (
let module Bu = Json_type.Build in
let j = Bu.objekt [
  "name", Bu.string t.name ;
  "nbars",Bu.int t.nbars ;
  "instruments",Bu.array ( List.map ( fun (i,bars) ->
    Bu.objekt [
      "instrument",Bu.string i.Instrument.name ;
    "bars",Bu.list Bar.to_json bars
  ]) t.bars) ;
] in
j
);;


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


	     
	     
