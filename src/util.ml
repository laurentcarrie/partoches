open Printf
open ExtList


module List = struct
  include List
  let find f l = try Some(List.find f l) with | Not_found -> None
  let assoc f l = try Some(List.assoc f l) with | Not_found -> None
  let replace_if cmp new_item l =
    let (l,found) = List.fold_left ( fun (acc,found) i ->
      if cmp i then (new_item::acc),true else (i::acc),found
    ) ([],false) l in
    let l = if found then l else new_item::l in
      List.rev l ;;

  let string_join sep l =
    match l with
      | [] -> ""
      | hd::[] -> hd
      | hd::tl ->  List.fold_left ( fun acc i -> sprintf "%s%s%s" acc sep i ) hd tl

end

module PMap = struct
  include PMap
  let find k m = try Some (PMap.find k m) with | Not_found -> None
end


type log_level = | Silent | Normal | Verbose | Debug

let log_active = ref Normal

let set_log_level l = 
  (*
  printf "=========================> new log level : %s\n" (
    match l with
    | Silent -> "silent" 
    | Normal -> "normal"
    | Verbose -> "verbose"
    | Debug -> "debug"
    ) ; flush stdout ; 
  *)
  log_active := l

let i_of_level level = match level with
  | Silent -> 0
  | Normal -> 1
  | Verbose -> 2
  | Debug -> 3

let log level fs =
  let do_it = (i_of_level !log_active) >= (i_of_level level) in
    if do_it then  ksprintf ( print_endline ) fs else  ksprintf ( fun _ -> ()) fs 

let util_assert b fs =
  if not b then ( fun x -> ksprintf (print_endline) fs x  )
  else ( ksprintf ( fun _ -> ()) fs )
;;


let system cmd =
  match Unix.system cmd with
    | Unix.WEXITED 0   -> ()
    | Unix.WEXITED i   -> failwith (sprintf "%s\ncommand returned code %d" cmd i)
    | Unix.WSIGNALED i -> failwith (sprintf "%s\nprocess was killed with code %d" cmd i)
    | Unix.WSTOPPED i  -> failwith (sprintf "%s\nprocess was stopped with code %d" cmd i)
;;

let mkdir dir = 
  try 
    let s = Unix.stat dir in 
      match s.Unix.st_kind with
	| Unix.S_DIR -> ()
	| _ -> failwith(Printf.sprintf "could not create directory %s" dir)
  with
    | Unix.Unix_error(e,s1,s2) -> (
	match e with
	  | Unix.ENOENT -> (
	      try
		Unix.mkdir dir 0o770
	      with
		| e -> (* Printf.printf "mkdir (1) \"%s\" ; %s ; %s" dir s1 s2 ; *) raise e
	    )
	  | _ -> failwith(Printf.sprintf "mkdir (2) \"%s\" ; %s ; %s" dir s1 s2)
	      
      )

(*
  attention : ce mkdir_p est eclipse par un autre plus loin
*)
let rec mkdir_p dir = 
  try
    mkdir dir 
  with
    | e ->
	match dir with
	  | "/" -> failwith ("cannot get parent of dir /")
	  | _ ->
	      let parent = Filename.dirname dir in
		mkdir_p parent ;
		mkdir dir
		  

let checkdir d = __PA__try (sprintf "checkdir %S" d) (
  let () = log Debug "checkdir %s" d in
    if Sys.file_exists d then  (
      if not (Sys.is_directory d) then 
      let msg = sprintf "%S is a file, it should be a directory" d in
	__PA__failwith msg
      else (
	()
    )
    )
    else (
      mkdir_p d ;
      ()
    )
) ;;


let ref_last_log_files = ref []

let last_log_files () = !ref_last_log_files

(* 
   sous Win32, il faut faire un cd /D a cause du changement possible de lettre
*)
let cd_command dir = 
  match Sys.os_type with
    | "Win32" -> 
	let rex = Pcre.regexp "^(.):/" in
	let dir = Pcre.replace ~rex ~templ:"$1:\\" dir in "cd /D \"" ^ dir ^ "\"" 
    | "Unix" -> "cd \"" ^ dir ^ "\""
    | os -> invalid_arg(Printf.sprintf "bad os_type :\"%s\"" os)
	

let rm_f filename =
  try Unix.unlink filename
  with _ -> ()

let with_file_out file action =
  let ic = open_out file in
    try 
      let result = action ic in
        close_out ic; result
    with
        x -> close_out ic; raise x
;;


let logname = 
  let word = 
    match Sys.os_type with
      | "Unix" -> "LOGNAME"
      | "Win32" -> "USERNAME"
      | _ -> failwith "bad os"
  in
    try
      Unix.getenv word
    with
      | _ -> failwith (sprintf "\"%s\" not defined in ENV" word)

;;

(* Execute une commande systeme et sort en exception s'il y a eu un pb 
   allow est la liste des codes retour qu'on accepte (en dehors de 0)
*)
let system ?(allow=[]) ?(title="") cmd =
  let tmp_file = Filename.temp_file "studio_result" ".log" in
  let date = 
    let tm = Unix.localtime (Unix.time ()) in
      sprintf "%02d:%02d:%02d , %02d/%02d/%04d" tm.Unix.tm_hour tm.Unix.tm_min tm.Unix.tm_sec tm.Unix.tm_mday tm.Unix.tm_mon (1900+tm.Unix.tm_year)
  in
  let cmd = sprintf "(%s) > %s 2>&1 " cmd tmp_file in
    log Debug "system : %s" cmd ;
    let status = Unix.system cmd in
    let () = ( ref_last_log_files := (date,title,cmd,status,tmp_file) :: !ref_last_log_files) in
      match status with
	| Unix.WEXITED 0   -> ()
	| Unix.WEXITED i   -> if not (List.mem i allow) then __PA__failwith (sprintf "%s\ncommand returned code %d" cmd i)
	| Unix.WSIGNALED i -> __PA__failwith (sprintf "%s\nprocess was killed with code %d" cmd i)
	| Unix.WSTOPPED i  -> __PA__failwith (sprintf "%s\nprocess was stopped with code %d" cmd i)
;;


(*
  Execute une commande systeme et ignore completement le resultat.
  Le '_' en premier caractere est reminiscent de la syntaxe make ou
  l'on utilise un '-' pour signaler que l'echec d'une commande ne
  
*)
let _system cmd =
  ignore (Unix.system cmd)
;;

(*
  Meme chose que system mais prend directement un formattage a la
  printf pour construire la commande.
*)
let systemf fs =
  kprintf ( fun fs -> system ~title:"" fs)  fs
;;


(*
  Meme chose que _system mais prend directement un formattage a la
  printf pour construire la commande.
*)
let _systemf fs =
  kprintf _system fs
;;



let rm_rf, cp_r, mkdir, mkdir_p, chmod_w, ls, sh_ext, bg_color =
  let q = Filename.quote in
  let (%) f g a = f (g a) in
  let (%%) f g a1 a2 = f (g a1) (g a2) in
    match Sys.os_type with
      | "Win32" ->
	  sprintf "rmdir /S /Q %s || echo ok" % q, (* renvoie une erreur si le repertoire n'existe pas *)
	  sprintf "xcopy /E /Y /I %s %s" %% q,
	  sprintf "mkdir %s" % q,
	  sprintf "mkdir %s" % q,
	  sprintf "attrib -R /S %s" % q,
	  sprintf "dir %s" % q,
	  ".cmd",
	  "fc"
      | "Unix" ->
	  sprintf "rm -rf %s" % q, (* jamais d'erreur *)
	  sprintf "cp -R %s %s" %% q,
	  sprintf "mkdir %s" % q,
	  sprintf "mkdir -p %s" % q,
	  sprintf "chmod -R +w %s" % q,
	  sprintf "ls %s" % q,
	  ".sh",
	  "grey"
      | _ -> assert(false)

let (//) = Filename.concat


let run_shell ?(keep_scripts = false) ~(bg:string) ~(fg:string) ~label ~use_xterm command = __PA__try 
  (sprintf "run_shell %S" command) (
  log Verbose "%s" command ;
  let cif_install_dir = Unix.getenv "PA_ROOT" in
  
  let sleep = match true with
    | false -> " ; sleep 0"
    | true -> " || sleep 0"  
  in

  let tmp_file = Filename.temp_file "studio_test_tmp" sh_ext in

  let action_win32 fout =
    let () = fprintf fout "call %s\\PA_env.cmd \n" (cif_install_dir)  in
      (* let () = fprintf fout "set PA_LICENSE_FILE=%s\\..\\cif.license \n" path in *)
    let () = fprintf fout "set PATH=%%PA_USR_INSTALL%%\\bin;%%PATH%%\n" in
    let () = fprintf fout "color fc\n"  in
    let () = fprintf fout "%s\n" command  in
    let () = fprintf fout "color \n"  in
    let () = fprintf fout "if not errorlevel 1 goto fin\n" in
    let () = fprintf fout "rem echo \"sleep...\"\n" in
    let () = fprintf fout "rem ruby -e \"sleep 1000\"\n" in
    let () = fprintf fout ":fin\n" in
    let () = fprintf fout "color 07 \n" in
    let () = fprintf fout "echo \"script done\"\n" in
    let () = close_out fout in
    let () = log Verbose "tmpfile : %s" tmp_file in
      (* let color = "fc" in *)
    let ret = if use_xterm then
      sprintf "start /wait \"%s\" cmd /C %s" label tmp_file 
      else
	sprintf "\"%s\" " tmp_file 
    in
      system ~title:"" ret
  in

  let action_unix fout =
    (* let fout = open_out tmp_file in *)
    let () = fprintf fout ". %s/PA_env.bashrc && " (cif_install_dir)  in 
      (* let () = fprintf fout "export PA_LICENSE_FILE=%s/../cif.license && " path in *)
    let () = fprintf fout "%s" command  in
    let () = close_out fout in
    let () = log Verbose "tmpfile : %s" tmp_file  in
      
    let (ret:string) = if use_xterm then
      sprintf "xterm -title \"%s\" -bg %s -fg %s -geometry 150x30 -e \"(/bin/bash %s ) %s\"" label bg fg tmp_file sleep  
      else
	sprintf "/bin/bash %s" tmp_file 
    in
    let (a:string) = ret in
      __PA__try a (
	system ~title:"" ret
      ) 
  in
    
  let action = match Sys.os_type with
    | "Unix" -> action_unix
    | "Win32" -> action_win32
    | _ -> assert(false)
  in

    with_file_out tmp_file action ;
    if not keep_scripts then (try Sys.remove tmp_file with _ -> ()) 
) ;;



