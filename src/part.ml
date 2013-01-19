open Printf
open ExtString
open Util



type id = string 
type t = {
  id:id ;
  name:string ;
  bars: Bar.t list ;
  signature:int option;
}

let to_json t =
  let module Bu = Json_type.Build in
  let j = Bu.objekt [
    "name",Bu.string t.name ;
    "bars",Bu.list Bar.to_json t.bars ;
  ] in
    j
      
let from_json j =
  let module Br = Json_type.Browse in
  let j = Br.objekt j in
  let table = Br.make_table j in
  let name = Br.string(Br.field table "name") in
    name,
  {
    id=name ;
    name=name ;
    bars=Br.list Bar.from_json (Br.field table "bars")  ;
    signature= Option.map Br.int (Br.optfield table "signature") ;
  }
    
