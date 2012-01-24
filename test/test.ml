
open Util

let main () = __PA__try "main" (
  let song = Song.of_file Sys.argv.(1) in
  let () = Song.output song in
    ()
)

let _ = try
    set_log_level Debug ;
    main ()
  with
    | e -> let () = __PA__print_exn_stack e in exit 1
