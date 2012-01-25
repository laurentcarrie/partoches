open Util
open Eliom_pervasives
open Lwt
open HTML5.M
open Eliom_services
open Eliom_parameters
open Eliom_output.Html5


open Printf

let _ = set_log_level Debug

let _ =
  let main_s = Eliom_services.service ~path:[""] ~get_params:unit () in
  let () = Eliom_output.Html5.register ~service:main_s 
    (fun () () -> return (
	html (
	  head (title (pcdata "cif")) [
	  ]
	)
	  
	  (body [
	    
	    h1 [ pcdata "hello world" ] 
	  ]
	  )
      ))
  in
    ()


let _ =
  let fallback = Eliom_output.Text.register_service ~path:["midi"] ~get_params:(Eliom_parameters.unit) ( 
    fun () () -> 
      log Normal "no get here !" ;
      let () = __PA__failwith "NO GET here" in
	return ("ok","application/text") 
  ) in

  let _ = Eliom_output.Text.register_post_service ~fallback ~post_params:(Eliom_parameters.string "data") (
    fun () (data) -> 
      let song = Song.of_json (Json_io.json_of_string data) in
      let () = Song.output song in
      return (
	Std.input_file ~bin:true (Song.midi_filename song),"audio/midi") 
  ) in
    ()
