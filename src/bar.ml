open Printf
open ExtString
open Util

type t = { 
  ly : string ;
  chords : string ;
}
    
let to_json t = 
  let module Bu = Json_type.Build in
  let j = Bu.objekt [
    "ly",Bu.string t.ly ;
    "chords",Bu.string t.chords
  ] in
    j
	
let from_json j = 
  let module Br = Json_type.Browse in
  let j = Br.objekt j in
  let table = Br.make_table j in
    {
      ly = Br.string(Br.field table "ly") ;
      chords = Br.string(Br.field table "chords") ;
    }
    
