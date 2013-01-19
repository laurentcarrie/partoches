open Printf
open ExtString

let system cmd = 
  match Unix.system cmd with
    | Unix.WEXITED 0 -> ()
    | Unix.WEXITED i -> eprintf "cmd '%s' exit with code %d\n" cmd i
    | Unix.WSTOPPED i -> eprintf "cmd '%s' stopped with code %d\n" cmd i
    | Unix.WSIGNALED i -> eprintf "cmd '%s' signaled with code %d\n" cmd i

let list_to_string l sep =
  match l with
    | [] -> ""
    | hd::[] -> hd
    | hd::tl -> List.fold_left ( fun acc s -> acc ^ sep ^ s ) hd tl
	
let do_log = ref false

let log fs =
    if (!do_log) then ksprintf ( print_endline ) fs else ksprintf ( fun _ -> ()) fs
      

let string_of_ly_chord s = 
  let string_of_ly_chord s =
    if s = "-" then "-" else (
      let l = String.explode s in
      let (note,l) = match l with 
	| [] -> assert (false) 
	| hd::tl -> String.uppercase (String.of_char hd),tl 
      in
      let note = sprintf "\\textbf{%s}" note in
      let (note,l) = match l with
	| 'i'::'s'::l -> sprintf "%s$\\sharp$" note,l
	| 'e'::'s'::l -> sprintf "%s$\\flat$" note,l
	| l -> note,l
      in
	(* la duree *)
      let (duree,l) = match l with
	| '1'::l -> 4,l
	| '4'::l -> 1,l
	| '2'::'.'::l -> 3,l
	| '2'::l -> 2,l
	| _ -> eprintf "l : '%s' ; '%s'\n" s (String.implode l) ; assert(false)
      in

      let alteration = match l with
	| [] -> ""
	| ':'::'7'::[] -> "7"
	| ':'::'m'::[] -> "m"
	| ':'::'m'::'7'::[] -> "m7"
	| _ ->  eprintf "l : '%s' ; '%s'\n" s (String.implode l) ; assert(false)
      in

	(* sprintf "%s(\\small{(%d)})" note duree *)
	(* sprintf "$_{%d}$%s%s" duree note alteration *)
	sprintf "%s%s%s"  note alteration ( let s=ref "" in for i=0 to duree-2 do s:=!s^"." ; done ; !s ) 
    )
  in
  let s = Str.split (Str.regexp " +") s in
  let l = List.map string_of_ly_chord s in
    list_to_string l " "


(* separe une liste de en des listes de longueur n *)
let list_to_list_of_list l n default = 
  let rec r acc current remaining =
    match remaining with
      | [] -> 
	  if List.length current = 0 then 
	    List.rev acc
	  else (
	    if List.length current < n then
	      r acc current [default]
	    else 
	      List.rev ( (List.rev current)::acc )
	  )
      | hd::tl -> 
	  if ( List.length current = n ) then
	    r ((List.rev current)::acc) [hd] tl
	  else
	    r acc (hd::current) tl
  in
    r [] [] l

