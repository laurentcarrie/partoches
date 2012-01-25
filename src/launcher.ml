open Printf
(* open Util *)
module Bu = Json_type.Build

let (//) = Filename.concat

let log_dir = "ocsigen-logs"

let conf mime_types_path  port pa_root = sprintf "\n\
<ocsigen> \n\
  <server>\n\
    <port>%d</port>\n\
    <!-- Update all the directories according to your installation -->\n\
    <!-- A default configuration file is usually provided in /etc/ocsigen/ -->\n\
    <logdir>ocsigen-logs</logdir>\n\
    <datadir>/tmp</datadir>\n\
    <user></user>\n\
    <group></group>\n\
    <commandpipe>/tmp/ocsigen_command</commandpipe>\n\
    <mimefile>%s/mime.types</mimefile>\n\
\n\
    <charset>utf-8</charset>\n\
    <debugmode/>\n\
    <findlib path=\"/usr/lib/ocaml\"/>\n\
    <findlib path=\"%s/lib/ocamlfind\"/>\n\
\n\
    <extension findlib-package=\"ocsigenserver.ext.staticmod\"/>\n\
    <extension findlib-package=\"ocsigenserver.ext.redirectmod\"/>\n\
    <extension findlib-package=\"json-wheel\"/>\n\
    <extension findlib-package=\"unix\"/>\n\
    <extension findlib-package=\"str\"/>\n\
\n\
    <extension findlib-package=\"ocsigenserver.ext.ocsipersist-sqlite\">\n\
      <database file=\"/tmp/ocsidb\"/>\n\
    </extension>\n\
\n\
    <extension findlib-package=\"eliom.server\"/>\n\
    <extension findlib-package=\"extlib\"/>\n\
\n\
    <host hostfilter=\"*\">\n\
\n\
      <!-- The directory containing static files (must be absolute): -->\n\
      <static dir=\"%s/staticdir\" />\n\
\n\
      <eliom module=\"%s/bin/partoches.cmxs\" />\n\
\n\
    </host>\n\
\n\
  </server>\n\
\n\
</ocsigen>\n\
" port mime_types_path pa_root pa_root pa_root


let getenv s = 
  try  Unix.getenv s with
    | Not_found -> __PA__failwith("Environment variable " ^ s ^ " not defined")

let _ = try
  let opt = OptParse.OptParser.make ~version:(Version.version)  () in

  let opt_port = OptParse.Opt.value_option "" None (fun a -> a) (fun e _ -> Printexc.to_string e) in
  let () = OptParse.OptParser.add opt ~long_name:"port" ~help:"port number of web server" opt_port in

  let opt_edit = OptParse.Opt.value_option "" None (fun a -> a) (fun e _ -> Printexc.to_string e) in
  let () = OptParse.OptParser.add opt ~long_name:"edit" ~help:"edit the following models (it is a string converted to a list, do \"a b c \" " opt_edit in


  let opt_debug = OptParse.StdOpt.store_true () in
  let () = OptParse.OptParser.add opt ~long_name:"debug" ~help:"activate debug traces" opt_debug in

  let opt_verbose = OptParse.StdOpt.store_true () in
  let () = OptParse.OptParser.add opt ~long_name:"verbose" ~help:"activate verbose traces" opt_verbose in

  let _ = OptParse.OptParser.parse_argv opt in

  let log_level = match OptParse.Opt.get opt_verbose,OptParse.Opt.get opt_debug with
    | _,true -> "debug"
    | true,false -> "verbose"
    | false,false -> "normal"
  in


  let edits = match OptParse.Opt.opt opt_edit with
    | None -> []
    | Some s -> Str.split (Str.regexp "[ \t]+") s
  in

  let edits = Bu.list Bu.string edits in

  let j = Bu.objekt [
    "edit-models",edits ;
    "log-level",Bu.string log_level
  ] in


  let () = Json_io.save_json ".config.json" j in

  let pa_root = getenv "Partoches_ROOT" in
  let port = __PA__try "web port" (
    match OptParse.Opt.opt opt_port with
      | None -> 8080
      | Some s -> int_of_string s
  ) in
  let mime_types_path = match Sys.os_type with
    | "Unix" -> "/usr/etc"
    | "Win32" -> __PA__NOT_IMPLEMENTED__
    | s -> __PA__failwith ("no such os : " ^ s)
  in
  let () = match Sys.file_exists log_dir with
    | false -> Unix.mkdir log_dir 0o777
    | true -> ( if Sys.is_directory log_dir then () else __PA__failwith (log_dir ^ " is not a valid directory"))
  in
  let conf = conf mime_types_path port pa_root in
  let () = printf "using port %d\n" port ; flush stdout in
  let () = Std.output_file ~filename:"pa.conf" ~text:conf in
  let command =  sprintf "ocsigenserver.opt -c %s" ( (Unix.getcwd()) // "pa.conf") in

    
  let ret = Unix.system command in
  let () = match ret with
    | Unix.WEXITED 0 -> ()
    | Unix.WEXITED i -> eprintf "exit with code %d\n" i ; exit i
    | Unix.WSIGNALED i -> eprintf "signaled with code %d\n" i ; exit i 
    | Unix.WSTOPPED i -> eprintf "stopped with code %d\n" i ; exit i 
  in
    ()
  with
    | e -> let () = __PA__print_exn_stack e in exit 1
      
    
