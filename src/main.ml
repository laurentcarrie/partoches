open Eliom_pervasives
open Lwt
open HTML5.M
open Eliom_services
open Eliom_parameters
open Eliom_output.Html5


open Printf

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

