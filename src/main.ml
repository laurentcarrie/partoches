open Util

open Printf

let (//) = Filename.concat 


let main () =
  let opt = OptParse.OptParser.make ~version:(Version.version)  () in
  let options = 
    let add (long_name,help) =
      let o = OptParse.StdOpt.store_true ()  in
      let () = OptParse.OptParser.add opt ~long_name ~help o in
	o in
      List.map add [
	"verbose","verbose" ;
	"pdf","generate pdf" ;
	"beautify","beautify json file" ;
	"all","generate all midi and pdf" ;
	"midi","generate midi files" ;
	"song","generate song files (if --midi or --pdf) " ;
	"drums","generate drums track" ;
	"tabs","generate tab staff" ;
	"chords","generate chord staff" ;
	"list-json","returns list of available json files" ;
      ]
  in

  let opt_json_id = OptParse.Opt.value_option  "id" None int_of_string ( fun e _ -> Printexc.to_string e ) in
  let () = OptParse.OptParser.add opt ~long_name:"json-id" ~help:"id of json return file" opt_json_id in

  let args = OptParse.OptParser.parse_argv opt in

  let (verbose,do_pdf,do_all,do_beautify,do_midi,do_song,do_drums,do_tabs,do_chords,do_list) = 
    let l = List.map OptParse.Opt.get options in
      match l with
	| [a;b;c;d;e;f;g;h;i;j] -> a,b,c,d,e,f,g,h,i,j
	| _ -> assert(false)
  in

  let () = if verbose then ( do_log := true ) else ( do_log := false ) in

  let scores = List.map Score.load_json args in

    if do_all then (
      log "do all activated" ;
      List.iter ( fun t ->
	let () = List.iter ( fun notes ->
	  List.iter ( fun tabs ->
	    List.iter ( fun chords ->
	      Score.generate_pdf t ~notes ~tabs ~chords ~drums:false
	    ) [ true;false ]
	  ) [true;false]
	) [true;false] in
	let () = Score.generate_midi_chords t ~drums:do_drums in
	let () = Score.generate_midi t ~drums:do_drums in
	let () = Score.generate_midi_parts t ~drums:do_drums in
	let () = Score.generate_pdf_struct t in
	  ()
      ) scores
    ) else ()  ;

    if do_beautify then ( 
      List.iter ( fun (t,filename)  ->
	let () = Score.save_json t filename in
	  ()
      ) (List.combine scores args)
    ) else () ;

    if (do_song &&  do_pdf) then (
      List.iter ( fun t ->
	let () = Score.generate_pdf_struct t in
	  ()
      ) scores
    ) else () ;
    
    if (do_midi) then (
      log "do midi" ;
      List.iter ( fun t -> 
	let () = Score.generate_midi t ~drums:do_drums in
	  ()
      ) scores
    ) else () ;


    if (do_pdf) then (
      List.iter ( fun t ->
	let () = Score.generate_pdf t ~tabs:do_tabs ~chords:do_chords ~notes:true ~drums:do_drums in
	  ()
      ) scores
    ) else () ;

    if (do_list) then (
      let json_id = OptParse.Opt.get opt_json_id in
      let rec r acc d = 
	let (dirs,files) = List.partition ( fun f -> Sys.is_directory ( d // f) ) (Array.to_list (Sys.readdir d)) in
	let files = List.filter ( fun f -> Filename.check_suffix f ".json" ) files in
	let files = List.map ( fun f -> d,f) files in
	let acc = List.fold_left ( fun acc d2 ->
	  r acc ( d // d2 )
	) (files@acc) dirs in
	  acc
      in
      let files = r [] "." in
      let module Bu = Json_type.Build in
      let j = Bu.objekt [
	"files",Bu.list ( fun (path,name) ->
	  Bu.objekt [
	    "path",Bu.string path ;
	    "filename",Bu.string name ;
	  ]
	) files
      ] in
      let filename = sprintf "return-%d.ret" json_id in
	Json_io.save_json filename j
    ) else () ;

    ()
	

      
let _ = try
    let () = main ()  in
      exit 0
  with
    | e -> printf "Printexc : %s" (Printexc.to_string e) ; exit 1
