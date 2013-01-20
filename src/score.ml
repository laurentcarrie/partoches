open Printf
open ExtString
open Util

let (//) = Filename.concat
let tmp_filename s = 
  (* let _ = system "rm -rf .tmp" in *)
  let _ = if not (Sys.file_exists ".tmp") then (Unix.mkdir ".tmp" 0o700) else () in
  ".tmp" // s

let c_of_bool b = if b then 't' else 'f'


type ly_t = 
    | Midi of bool (* drums *)
    | Midi_chords of bool (* drums *)
    | Pdf of bool * bool * bool * bool  (*   notes,tabs,chords,drums *)

type t = {
  name : string ;
  parts : (Part.id * Part.t) list ;
  structure : Part.id list ;
  signature:int ;
  tempo : int ;
}



let part_of_id t id = 
  try
    List.assoc id t.parts
  with
    | Not_found -> (
	eprintf "No part with id '%s', available : \n" id ; 
	List.iter ( fun (id,part) -> eprintf "\t%s ; %s\n" id part.Part.id ) t.parts ;
	raise Not_found
      )

let struct_of_t t =
  List.map ( part_of_id t ) t.structure

let generate_pdf_struct t =
  let filename = Str.global_replace (Str.regexp " ") "_" t.name in
  let filename = tmp_filename (sprintf "%s-song.tex" filename) in
  let fout = open_out filename in
  let p fs = kfprintf ( fun fout -> ())  fs in 
    p fout "
\\documentclass{article}
%% ##############################################################################
%% ### Parametres de la page
%% ##############################################################################
\\setlength{\\paperwidth}{21cm}
\\setlength{\\paperheight}{29.7cm}
\\setlength{\\hoffset}{-1in}
\\setlength{\\voffset}{-1in}
%%\\setlength{\\oddsidemargin}{2cm}
%%\\setlength{\\marginparsep}{0cm}
%%\\setlength{\\marginparwidth}{0cm}
\\setlength{\\textwidth}{18cm}
\\setlength{\\topmargin}{0.5cm}
\\setlength{\\headsep}{1cm}

\\setlength{\\textheight}{26cm}
\\setlength{\\footskip}{0.5cm}

\\setlength{\\itemsep}{1cm}
\\setlength{\\columnsep}{0.5cm}
\\setlength{\\columnseprule}{0.4pt}
\\usepackage[T1]{fontenc}
\\usepackage[latin1]{inputenc}
\\usepackage{multicol}
\\usepackage{paralist}
\\usepackage[pdftex]{graphicx}

\\newcommand{\\makechord}[1]{\\textbf{##1}}
\\renewenvironment{itemize}[1]{\\begin{compactitem}#1}{\\end{compactitem}}

\\newcommand{\\HRule}{\\centering{\\rule{\\linewidth}{0.5mm}}}

\\title{%s}


\\begin{document}

\\HRule \\\\[0.4cm]


{ \\huge \\bfseries %s }\\\\[0.3cm]

\\HRule 

\\begin{multicols*}{2}


"      t.name t.name ;
    p fout "\nStructure : \\\\[0.01cm] \\begin{itemize} \n" ;
    List.iter ( fun part -> p fout "\\item %s (%d mesures) \n" part.Part.name (List.length part.Part.bars) ) (struct_of_t t) ;
    p fout "\\end{itemize} \n\n" ;
    p fout "\\vfill \n"; 
    p fout "\\columnbreak \n"; 
    let ncols = 4 in
      List.iter ( fun part -> 
	(* p fout "Partie : %s \\\\ \n" part.Part.name ;
	   p fout "%d mesures \\\\ \n" (List.length part.Part.bars) ;*)
	(* p fout "\\begin{table}[ht] \n" ; *)
	(* p fout "\\caption{%s} \n" part.Part.name ; *)
	p fout "\\centering \n" ;
	p fout "\\begin{tabular}{|" ;
	for i=1 to 4 do p fout "p{1.5cm}|" ; done;
	p fout "} \n" ;
	p fout "\\multicolumn{%d}{c}{%s} \\tabularnewline \n \\hline \n" ncols part.Part.name ;
	List.iter ( fun line ->
	  p fout " %s \\tabularnewline \n" (list_to_string (List.map ( fun b -> "\\centering " ^ (string_of_ly_chord b.Bar.chords)  ) line) " & " ) ;
	  p fout "\\hline\n" ;
	) (list_to_list_of_list part.Part.bars ncols {Bar.ly="";chords="-"}) ;
	p fout "\\end{tabular} \n\n \n\n" ;
	p fout "\\vspace{1cm}\n" ;
	(* p fout "\\end{table} \n" ; *)
      ) (struct_of_t t) ;
      p fout "\\end{multicols*} \n" ; 
      p fout "\\end{document}\n" ;
      close_out fout ;
      system (sprintf "cd .tmp && pdflatex %s ; pdflatex %s ; pdflatex %s" (Filename.basename filename) (Filename.basename filename)  (Filename.basename filename)  ) ;
      ()
	

let remove_tab_reference s =
  Str.global_replace (Str.regexp "\\\\set TabStaff\\.minimumFret  *=.*$") "" s

let internal_to_ly_file ~t ~filename ~ly_t =
  let () = log "writing file %s" filename in
  let fout = open_out filename in
  let tabs = match ly_t with
    | Midi _ | Midi_chords _ -> false
    | Pdf(_,b,_,_) -> b
  in
  let p fs = kfprintf ( fun fout -> ())  fs in 
    p fout "\\version \"2.12.3\"\n"  ;
    p fout "\\header { \ntitle = \"%s\" \ncomposer= \"... to do...\" \n }\n" t.name ; 
    p fout "symbols =  {\n" ;
    List.iter ( fun pa -> 
      p fout "%% ========= %s\n" pa.Part.name ;
      p fout "\\mark \"sec:%s\" \n" pa.Part.name ; 
      p fout "\\tempo 4 = %d \n" t.tempo ; 
      p fout "\\time %d/4\n" ( match pa.Part.signature with
	| Some s -> s | None -> t.signature ) ;
      List.iter ( fun b ->
	p fout "%s | " (if not tabs then remove_tab_reference b.Bar.ly else b.Bar.ly)
      ) pa.Part.bars 
    ) (struct_of_t t) ;
    p fout "} \n" ;

    p fout "accords = { \n" ;
    p fout "  \\set chordChanges=##t \n" ;
    p fout "  \\chordmode { \n" ;
    List.iter ( fun part ->
      List.iter ( fun bar -> 
	p fout "%s | " bar.Bar.chords
      ) part.Part.bars
    ) (struct_of_t t) ;
    p fout "   }\n" ;
    p fout "}\n" ;


    p fout "drumssymbolshh = \\drummode {\n" ;
    List.iter ( fun pa ->
      List.iter ( fun b ->
	let signature = match pa.Part.signature with | None -> t.signature | Some i -> i in
	  for i=0 to signature-1 do
	    p fout " hh8 hh8 "
	  done ;
	  p fout " | " ;
      ) pa.Part.bars
    ) (struct_of_t t) ;
    p fout "} \n" ;

    p fout "drumssymbolssn = \\drummode {\n" ;
    List.iter ( fun pa ->
      List.iter ( fun b ->
	let signature = match pa.Part.signature with | None -> t.signature | Some i -> i in
	  (match signature with
	    | 4 -> p fout "r4 sn4 r4 sn4"
	    | 3 -> p fout  "r4 sn4 sn4"
	    | _ -> eprintf "signature not managed : must be 3 or 4\n" ; assert(false)) ;
	  p fout " | " ;
      ) pa.Part.bars
    ) (struct_of_t t) ;
    p fout "} \n" ;

    p fout "drumssymbolsbd = \\drummode {\n" ;
    List.iter ( fun pa ->
      List.iter ( fun b ->
	let signature = match pa.Part.signature with | None -> t.signature | Some i -> i in
	  p fout "bd4 " ;
	  for i=0 to signature-2 do
	    p fout " r4  "
	  done ;
	  p fout " | " ;
      ) pa.Part.bars
    ) (struct_of_t t) ;
    p fout "} \n" ;


    let () = match ly_t with
      | Midi_chords drums ->  (
	  p fout "\\score {\n" ;
	  p fout "  <<\n" ;
	  p fout " \\new ChordNames { \n" ;
	  p fout "   \\override BarLine #'bar-extent = #'(-2 . 2) \n" ;
	  (* p fout "   \\consists \"Bar_engraver\" \n" ; *)
	  p fout "    \\accords \n" ;
	  if drums then ( 
	    p fout "   \\new DrumStaff << \n" ;
	    p fout "         \\new DrumVoice \\drumssymbolshh \n" ;
	    p fout "         \\new DrumVoice \\drumssymbolssn \n" ;
	    p fout "         \\new DrumVoice \\drumssymbolsbd \n" ;
	    p fout "    >> \n" ;
	  ) else () ;
	  p fout " } \n" ;
	  p fout "  >>\n" ;
	  p fout "  \\midi{}\n" ;
	  p fout "}\n" ;
	)
      | Midi drums ->  (
	  p fout "\\score {\n" ;
	  p fout "  <<\n" ;
	  p fout "   \\new Staff { \\clef \"treble_8\" \\symbols }\n" ;
	  if drums then ( 
	    p fout "   \\new DrumStaff << \n" ;
	    p fout "         \\new DrumVoice \\drumssymbolshh \n" ;
	    p fout "         \\new DrumVoice \\drumssymbolssn \n" ;
	    p fout "         \\new DrumVoice \\drumssymbolsbd \n" ;
	    p fout "    >> \n" ;
	  ) else () ;
	  p fout "  >>\n" ;
	  p fout "  \\midi{}\n" ;
	  p fout "}\n" ;
	)
      | Pdf (notes,tabs,chords,drums) -> (
	  p fout "\\score {\n" ;
	  p fout "  <<\n" ;
	  if chords then p fout "    \\new ChordNames { \\accords } \n" ;
	  if notes then p fout "   \\new Staff { \\clef \"treble_8\" \\symbols }\n" ;
	  if tabs then p fout "   \\new TabStaff { \\symbols } \n" ;
	  if drums then (
	    p fout "   \\new DrumStaff << \n" ;
	    p fout "         %%\\new DrumVoice  \\drumssymbolshh \n" ;
	    p fout "         \\new DrumVoice  \\drumssymbolssn \n" ;
	    p fout "         \\new DrumVoice \\drumssymbolsbd \n" ;
	    p fout "    >> \n" ;
	  ) else () ;
	  p fout "  >>\n" ;
	  p fout "  \\layout{}\n" ;
	  p fout "}\n" ;
	)
    in
      close_out fout ;
      ()


let generate_pdf ~notes ~tabs ~chords ~drums t = try
    let filename = tmp_filename (sprintf "%s-%c%c%c.ly" t.name (c_of_bool notes) (c_of_bool tabs) (c_of_bool chords)) in
    let () = log "generating %s\n" filename in
    let filename = Str.global_replace (Str.regexp " ") "_" filename in
      internal_to_ly_file ~t ~filename ~ly_t:(Pdf (notes,tabs,chords,drums)) ;
      List.iter ( fun part ->
	let t = { t with structure=[part.Part.id] ; name=sprintf "%s-%s" t.name part.Part.name } in
	let filename = sprintf "%s.ly" t.name in
	let filename = Str.global_replace (Str.regexp " ") "_" filename in
	  internal_to_ly_file ~t ~filename ~ly_t:(Pdf (notes,tabs,chords,drums)) ;
      ) (struct_of_t t) ;
      system (sprintf "lilypond --output %s %s "  (Filename.chop_extension filename) filename)
  with
    | e -> eprintf "generate_pdf\n" ; raise e

let generate_midi t ~drums = try
    let name2 =  Str.global_replace (Str.regexp " ") "_" t.name in
    let filename = tmp_filename (sprintf "%s-midi.ly" name2) in
      internal_to_ly_file ~t ~filename ~ly_t:(Midi drums) ;
      system (sprintf "lilypond --output %s %s" (Filename.chop_extension filename) filename)
  with
    | e -> eprintf "to_ly_midichords\n" ; raise e
	
let generate_midi_parts t ~drums =
  List.iter ( fun (id,part) ->
    let t = { t with name = sprintf "%s-%s" t.name part.Part.name ; structure = [ id ] } in 
      generate_midi t ~drums
  ) t.parts

let generate_midi_chords t ~drums = try
    let name2 =  Str.global_replace (Str.regexp " ") "_" t.name in
    let filename = tmp_filename (sprintf "%s-chords.ly" name2) in
      internal_to_ly_file ~t ~filename ~ly_t:(Midi_chords drums) ;
      system (sprintf "lilypond --output %s %s" (Filename.chop_extension filename ) filename)
  with
    | e -> eprintf "to_ly_midichords\n" ; raise e

let to_json t = try
    let module Bu = Json_type.Build in
    let j = Bu.objekt [
      "name",Bu.string t.name ;
      "parts",Bu.list Part.to_json (List.map snd t.parts) ;
      "tempo",Bu.int t.tempo ;
      "signature",Bu.int t.signature ;
      "struct",Bu.list Bu.string (List.map ( fun p -> p.Part.id ) (struct_of_t t))
    ] in
      j
  with
    | e -> eprintf "to_json\n" ; raise e

let save_json t filename =
  Json_io.save_json filename (to_json t)


let load_json filename =
  let module Br = Json_type.Browse in
  let j = Json_io.load_json filename in
  let j = Br.objekt j in
  let table = Br.make_table j in
    {
      name = Br.string(Br.field table "name") ;
      signature = Br.int(Br.field table "signature") ;
      tempo = Br.int(Br.field table "tempo") ;
      parts = Br.list Part.from_json (Br.field table "parts") ;
      structure = Br.list Br.string (Br.field table "struct") ;
    }


