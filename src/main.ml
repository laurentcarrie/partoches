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

let _ =
  let fallback = Eliom_output.Text.register_service ~path:["partoche"] ~get_params:(Eliom_parameters.unit) ( 
    fun () () -> 
      log Normal "no get here !" ;
      let () = __PA__failwith "NO GET here" in
	return ("ok","application/text") 
  ) in

  let _ = Eliom_output.Html5.register_post_service ~fallback ~post_params:(Eliom_parameters.string "data") (
    fun () (data) ->  
      let song = Song.of_json (Json_io.json_of_string data) in return (
	html (
	  head (title (pcdata ("partoche " ^ song.Song.name))) [
	    css_link ~uri:(make_uri (static_dir ()) ["partoches.css"]) () ; 
	  ]
	)
	  (body [
	    h1 ~a:[a_class ["song-title"]] [pcdata song.Song.name] ;
	    div ~a:[a_id "song-score"] [
	      ul (List.map ( fun p -> li [ pcdata p.Part.name ]) (song.Song.score.Score.parts))
	    ]
	  ]
	  )
      )
  )in
    ()

let upload_s =
  let fallback = Eliom_output.Text.register_service ~path:["xxx"] ~get_params:(Eliom_parameters.unit) ( 
    fun () () -> 
      log Normal "no get here !" ;
      let () = __PA__failwith "NO GET here" in
	return ("ok","application/text") 
  ) in

  let s = Eliom_output.Html5.register_post_service ~fallback ~post_params:(Eliom_parameters.file "fileselect[]") (
    fun () name ->
      return (
	html 
	  (head (title (pcdata "hello")) [])
	  (body [
	    p [ pcdata (sprintf "tmp-filename : %s" (Eliom_request_info.get_tmp_filename name)) ] ;
	    p [ pcdata (sprintf "filesize : %Ld" (Eliom_request_info.get_filesize name)) ] ;
	  (* p [ pcdata (sprintf "raw : %s" (Eliom_request_info.get_raw_original_filename name)) ] ; *)
	    p [ pcdata (sprintf "raw : %s" (Eliom_request_info.get_original_filename name)) ] ;
	  ]
	  )
      )
  ) in
    s

let _ =
  let fallback = Eliom_output.Text.register_service ~path:["upload-file"] ~get_params:(Eliom_parameters.unit) ( 
    fun () () -> 
      log Normal "no get here !" ;
      let () = __PA__failwith "NO GET here" in
	return ("ok","application/text") 
  ) in

  let _ = Eliom_output.Html5.register_post_service ~fallback ~post_params:(Eliom_parameters.raw_post_data) (
    fun () file ->  
      let (a,b) = file in 
      let (c,d) = match a with
	  | None -> __PA__failwith "internal error"
	  | Some (c,d) -> c,d
      in
      let (e,f) = c in
      let () = log Debug "file was uploaded" in
      let () = log Debug "content e : %s" e in
      let () = log Debug "content f : %s" f in
      let () = log Debug "content length d : %d" (List.length d) in
      let (g,h) = List.fold_left ( fun (g,h) (i,j) -> g^i,h^j) ("","") d in
      let () = log Debug "content g : %s" g in
      let () = log Debug "content h : %s" h in

      let max_size = (* Ocsigen_config.get_maxrequestbodysizeinmemory () *) 1000_1000 in
      let (l : string Lwt.t) = match b with
	  | None -> __PA__failwith "no stream"
	  | Some stream -> Ocsigen_stream.string_of_stream max_size (Ocsigen_stream.get stream)
      in

	(l
	  >>= fun s -> 
	    log Debug "uploaded file of size %d" (String.length s) ;
	    return (
	      html (
		head (title (pcdata ("partoche"))) [
		  css_link ~uri:(make_uri (static_dir ()) ["partoches.css"]) () ; 
		]
	      )
		(body [
		]
		)
	    )
	)) in
    ()


let _ =
  let _ = Eliom_output.Html5.register_service ~path:["upload"] ~get_params:(Eliom_parameters.unit) ( 
    fun () () -> return (
      html (
	head (title (pcdata ("upload"))) [
	  css_link ~uri:(make_uri (static_dir ()) ["css";"partoches.css"]) () ; 
	  css_link ~uri:(make_uri (static_dir ()) ["css";"upload.css"]) () ; 
	  js_script ~uri:(make_uri (static_dir ()) ["js";"upload.js"]) () ;  
	  (* js_script ~uri:(make_uri (static_dir ()) ["js";"filedrag.js"]) () ;   *)
	  
	]
      )
	(body [

	  div ~a:[a_id "output" ; a_class ["clearfix"]] [
	    ul ~a:[a_id "output-listing01"] [] 
	  ] ;
	  (*
	  div [
	    Eliom_output.Html5.post_form ~service:upload_s ( fun  name -> [
	      div [ 
		pcdata "hello" ;
		Eliom_output.Html5.file_input ~a:[a_id "fileselect"] ~name:name ()
	      ] ;
	      div ~a:[a_id "filedrag"] [ pcdata "or drop files here" ] ;
              Eliom_output.Html5.string_input ~input_type:`Submit ~value:"Click" () ;
	    ] ; ) () ;
	  ] ;
	  *)
	]
	))
  ) in ()
      

