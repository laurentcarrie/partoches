open Util
open Eliom_pervasives
open Lwt
open HTML5.M
open Eliom_services
open Eliom_parameters
open Eliom_output.Html5
open ExtList

open Printf

module Bu = struct
  include Json_type.Build
    let string_with_label label s = 
      string (sprintf "<span class=\"edit-label\">%s : </span> <span class=\"edit-value\">%s</span>" label s )
end


module Key = struct
  type t = { partoche : string ; instrument_name : string option ; part_name : string option  ; collection : string option ; score_index : int option ; }
  let to_string t = 
    let j = Bu.objekt [
      "partoche",Bu.string t.partoche ;
      "instrument",Bu.option (Option.map Bu.string t.instrument_name) ;
      "part",Bu.option (Option.map Bu.string t.instrument_name) ;
      "collection",Bu.option (Option.map Bu.string t.collection) ;
      "score_index",Bu.option (Option.map Bu.int t.score_index) ;
    ] in
    Json_io.string_of_json j

  let make ?(instrument_name=None) ?(part_name=None) ?(score_index=None) partoche = 
    to_string { partoche=partoche ; instrument_name = instrument_name ; part_name = part_name ; collection = None ; score_index = score_index }
  let make_collection label partoche = 
    to_string { partoche = partoche ; instrument_name = None ; part_name = None ; collection = Some label ; score_index = None }
  let from_string s : t  = __PA__try "Key.from_string" (
      let module Br = Json_type.Browse in
      let j = Json_io.json_of_string s in
      let j = Br.objekt j in
      let table = Br.make_table j in
      {
	partoche = Br.string (Br.field table "partoche")  ;
	instrument_name = Option.map Br.string (Br.optfieldx table "instrument") ;
	part_name = Option.map Br.string(Br.optfieldx table "part") ;
	collection  = Option.map Br.string (Br.optfieldx table "collection") ;
	score_index = Option.map Br.int (Br.optfieldx table "score_index") ;
      }
  )
end


let _ = Eliom_output.Text.register_service ~path:["get-json-instruments"] ~get_params:((Eliom_parameters.string "_") ** (Eliom_parameters.string "key") ) (
  fun (_,key) () ->
    let key = Key.from_string key in
    let filename = Str.global_replace (Str.regexp " ") "-" key.Key.partoche in 
    let song = Song.of_file ( (Unix.getcwd()) // (filename ^ ".json")) in 
    let j = Bu.list ( fun i ->
      Bu.objekt [
	"title",Bu.string i.Instrument.name ;
	"name",Bu.string i.Instrument.name ;
	"key",Bu.string (Key.make ~instrument_name:(Some  i.Instrument.name) key.Key.partoche) ;
	"isLazy",Bu.bool false ;
	"isFolder",Bu.bool false ;
	"tooltip",Bu.string "instrument" ;
      ]
    ) song.Song.instruments
    in
    return ( Json_io.string_of_json j , "application/json" )
) 


let _ = Eliom_output.Text.register_service ~path:["get-json-bars2"] ~get_params:((Eliom_parameters.string "_") ** (Eliom_parameters.string "key") ) (
  fun (_,key) () ->
    let key = Key.from_string key in
    let filename = Str.global_replace (Str.regexp " ") "-" key.Key.partoche in 
    let part_name = Option.get key.Key.part_name in
    let song = Song.of_file ( (Unix.getcwd()) // (filename ^ ".json")) in 
    let part = try List.find ( fun p -> p.Part.name = part_name ) song.Song.parts with
      | Not_found -> __PA__failwith "no such part"
    in
    let j = Bu.list ( fun (i,_) ->
      Bu.objekt [
	"title",Bu.string i.Instrument.name ;
	"name",Bu.string i.Instrument.name ;
	"key",Bu.string (Key.make ~instrument_name:(Some i.Instrument.name) ~part_name:(Some part_name) key.Key.partoche) ;
	"url",Bu.string "get-json-bars" ;
	"isLazy",Bu.bool true ;
	"isFolder",Bu.bool true ;
	"tooltip",Bu.string "bars" ;
      ]
    ) part.Part.bars
    in
    return ( Json_io.string_of_json j , "application/json" )
) 
 

let _ = Eliom_output.Text.register_service ~path:["get-json-bars"] ~get_params:((Eliom_parameters.string "_") ** (Eliom_parameters.string "key") ) (
  fun (_,key) () ->
    let key = Key.from_string key in
    let filename = Str.global_replace (Str.regexp " ") "-" key.Key.partoche in 
    let part_name = Option.get key.Key.part_name in
    let song = Song.of_file ( (Unix.getcwd()) // (filename ^ ".json")) in 
    let part = try List.find ( fun p -> p.Part.name = part_name ) song.Song.parts with
      | Not_found -> __PA__failwith "no such part"
    in
    let j = Bu.list ( fun (i,_) ->
      Bu.objekt [
	"title",Bu.string i.Instrument.name ;
	"name",Bu.string i.Instrument.name ;
	"key",Bu.string (Key.make ~instrument_name:(Some i.Instrument.name) ~part_name:(Some part_name) key.Key.partoche) ;
	"url",Bu.string "get-json-bars2" ;
	"isLazy",Bu.bool true ;
	"isFolder",Bu.bool true ;
	"tooltip",Bu.string "bars" ;
      ]
    ) part.Part.bars
    in
    return ( Json_io.string_of_json j , "application/json" )
) 
 
let _ = Eliom_output.Text.register_service ~path:["get-json-elements"] ~get_params:((Eliom_parameters.string "_") ** (Eliom_parameters.string "key") ) (
  fun (_,key) () ->
    let key = Key.from_string key in
    let filename = Str.global_replace (Str.regexp " ") "-" key.Key.partoche in 
    let song = Song.of_file ( (Unix.getcwd()) // (filename ^ ".json")) in 
    let j = Bu.list ( fun i ->
      Bu.objekt [
	"title",Bu.string i.Part.name ;
	"name",Bu.string i.Part.name ;
	"key",Bu.string (Key.make ~part_name:(Some i.Part.name) key.Key.partoche) ;
	"url",Bu.string "get-json-bars" ;
	"isLazy",Bu.bool true ;
	"isFolder",Bu.bool true ;
	"tooltip",Bu.string "element" ;
      ]
    ) song.Song.parts
    in
    return ( Json_io.string_of_json j , "application/json" )
) 
  

let _ = Eliom_output.Text.register_service ~path:["get-json-structure"] ~get_params:((Eliom_parameters.string "_") ** (Eliom_parameters.string "key") ) (
  fun (_,key) () ->
    let key = Key.from_string key in
    let filename = Str.global_replace (Str.regexp " ") "-" key.Key.partoche in 
    let song = Song.of_file ( (Unix.getcwd()) // (filename ^ ".json")) in 
    let index = ref (-1) in
    let j = Bu.list ( fun (i,_) ->
      incr index ;
      Bu.objekt [
	"title",Bu.string i.Part.name ;
	"name",Bu.string i.Part.name ;
	"key",Bu.string (Key.make ~score_index:(Some !index) key.Key.partoche) ;
	"isLazy",Bu.bool false ;
	"isFolder",Bu.bool false ;
	"tooltip",Bu.string "element" ;
      ]
    ) song.Song.score.Score.parts
    in
    return ( Json_io.string_of_json j , "application/json" )
) 
  


let _ = Eliom_output.Text.register_service ~path:["get-json-tree"] ~get_params:((Eliom_parameters.string "_") ** (Eliom_parameters.string "partoche") ) (
  fun (_,key) () ->
    (*let filename = Str.global_replace (Str.regexp " ") "-" partoche in 
      let song = Song.of_file ( (Unix.getcwd()) // (filename ^ ".json")) in *)
    let partoche = key in
    let j = Bu.objekt [
      "title",Bu.string "partoche" ;
	 "key",Bu.string "root" ;
	 "isLazy",Bu.bool true ;
	 "isFolder",Bu.bool true ;
	 "tooltip",Bu.string "racine du projet" ;
	 "partoche",Bu.string partoche ;
	 "children", Bu.array [
	   Bu.objekt [
	     "title",Bu.string_with_label "name" partoche ;
	     "key",Bu.string ("partoche-name") ;
	     "isLazy",Bu.bool false ;
	     "isFolder",Bu.bool false ;
	     "tooltip",Bu.string "nom de la partoche" ;
	   ] ;
	   Bu.objekt [
	     "title",Bu.string "instruments" ;
	     "key",Bu.string (Key.make_collection "instruments" partoche) ;
	     "url",Bu.string "get-json-instruments" ;
	     "isLazy",Bu.bool true ;
	     "isFolder",Bu.bool true ;
	     "tooltip",Bu.string "instruments" ;
	   ] ;
	   Bu.objekt [
	     "title",Bu.string "elements" ;
	     "key",Bu.string (Key.make_collection "elements" partoche) ;
	     "url",Bu.string "get-json-elements" ;
	     "isLazy",Bu.bool true ;
	     "isFolder",Bu.bool true ;
	     "tooltip",Bu.string "elements de structure" ;
	   ] ;
	   Bu.objekt [
	     "title",Bu.string "structure" ;
	     "key",Bu.string (Key.make_collection "structure" partoche) ;
	     "url",Bu.string "get-json-structure" ;
	     "isLazy",Bu.bool true ;
	     "isFolder",Bu.bool true ;
	     "tooltip",Bu.string "structure" ;
	   ]
	 ]
    ] in
    return ( Json_io.string_of_json j , "application/json" )
) 
  

let _ =
  let fallback = Eliom_output.Text.register_service ~path:["editer"] ~get_params:(Eliom_parameters.unit) ( 
  fun () () -> 
    log Normal "no get here !" ;
    let () = __PA__failwith "NO GET here" in
    return ("ok","application/text") 
  ) in

  let _ = Eliom_output.Html5.register_post_service ~fallback ~post_params:(Eliom_parameters.string "name") (
    fun () (filename) -> 
      let song = Song.of_file ( (Sys.getcwd()) // filename) in
      return ( 
	html (
	  head (title (pcdata song.Song.name)) [
	    css_link ~uri:(make_uri (static_dir ()) ["css";"jquery-ui-1.8.17.custom.css"]) () ;
	    css_link ~uri:(make_uri (static_dir ()) ["css";"ui.dynatree.css"]) () ;
	    css_link ~uri:(make_uri (static_dir ()) ["css";"partoches.css"]) () ; 
	    js_script ~uri:(make_uri (static_dir ()) ["js";"jquery-1.7.1.min.js"]) () ;  
	    js_script ~uri:(make_uri (static_dir())  ["js";"jquery-ui-1.8.17.custom.min.js"]) () ;
	    js_script ~uri:(make_uri (static_dir ()) ["js";"jquery.dynatree.min.js"]) () ;  
	    js_script ~uri:(make_uri (static_dir ()) ["js";"editer.js"]) () ;  


	  ])

	    (body ([
	      div ~a:[a_id "tree"] [] ;
	      div ~a:[a_id "info"] [] ;
	    ]))
	  
      )) in
  ()

