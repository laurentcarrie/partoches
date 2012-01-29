open Util
open Eliom_pervasives
open Lwt
open HTML5.M
open Eliom_services
open Eliom_parameters
open Eliom_output.Html5
open ExtList

open Printf



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
	    css_link ~uri:(make_uri (static_dir ()) ["css";"partoches.css"]) () ; 
	    ])

	    (body ([
	      h1 ~a:[a_class ["song-title"]] [ pcdata song.Song.name ] ;
	      div ~a:[a_id "song-score"] [
		let make_tr (p,from) =
		     tr ~a:[a_class ["song-score"]] [
		       td ~a:[a_class ["song-score-part-name"]] [pcdata p.Part.name] ;
		       td  ~a:[a_class ["song-score-part-nbars"]] [pcdata (sprintf "%d" p.Part.nbars)] ;
		       td  ~a:[a_class ["song-score-part-from"]] [
			 pcdata (sprintf "%d" from) ;
			 entity "rightarrow" ;
			 pcdata (sprintf "%d " (from + p.Part.nbars - 1 )) ;
		       ]
		     ] 
		in
		match song.Song.score.Score.parts with
		  | [] -> pcdata ""
		  | hd::tl -> (
		    table  ~a:[a_class ["song-score"]]  (make_tr hd) (List.map make_tr tl))
	     ] ;
	    ]))
	  
      )) in
  ()

