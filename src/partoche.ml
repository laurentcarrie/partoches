open Printf
open ExtString
open Util



  type pdf_score = {
    notes : bool ;
    tabs : bool ;
    chords : bool ;
  } 
  type t = {
    name : string ;
    parts : (Part.id * Part.t) list ;
    structure : Part.id list ;
    signature:int ;
    midi : bool ;
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

  let to_tex_file t =
    let filename = sprintf "%s-song.tex" t.name in
    let filename = Str.global_replace (Str.regexp " ") "_" filename in
    let fout = open_out filename in
    let p fs = kfprintf ( fun fout -> ())  fs in 
      p fout "
\\documentclass[12pt]{article}
\\usepackage[T1]{fontenc}
\\usepackage[latin1]{inputenc}
\\usepackage{makeidx}
\\usepackage{verbatim}
\\usepackage{tabularx}
\\begin{document}
\\fontsize{14}{14}\\selectfont

"  ; 
      p fout "Structure : \\begin{itemize} \n" ;
      List.iter ( fun part -> p fout "\\item %s (%d mesures) \n" part.Part.name (List.length part.Part.bars) ) (struct_of_t t) ;
      p fout "\\end{itemize} \n" ;
      let ncols = 4 in
	List.iter ( fun part -> 
	  (* p fout "Partie : %s \\\\ \n" part.Part.name ;
	     p fout "%d mesures \\\\ \n" (List.length part.Part.bars) ;*)
	  p fout "\\begin{table}[ht] \n" ;
	  (* p fout "\\caption{%s} \n" part.Part.name ; *)
	  p fout "\\centering \n" ;
	  p fout "\\begin{tabular}{|" ;
	  for i=1 to 4 do p fout "p{2cm}|" ; done;
	  p fout "} \n" ;
	  p fout "\\multicolumn{%d}{c}{%s} \\tabularnewline \n \\hline \n" ncols part.Part.name ;
	  List.iter ( fun line ->
	    p fout " %s \\tabularnewline \n" (list_to_string (List.map ( fun b -> "\\centering " ^ (string_of_ly_chord b.Bar.chords)) line) " & " ) ;
	    p fout "\\hline\n" ;
	  ) (list_to_list_of_list part.Part.bars ncols {Bar.ly="";chords="-"}) ;
	  p fout "\\end{tabular}\n" ;
	  p fout "\\end{table} \n" ;
	) (struct_of_t t) ;
	p fout "\\end{document}\n" ;
	close_out fout ;
	()
	  

  let internal_to_ly_file ~t ~filename ~notes ~tabs ~chords ~midichords = 
    let fout = open_out filename in
    let p fs = kfprintf ( fun fout -> ())  fs in 
      p fout "\\version \"2.12.3\"\n"  ;
      p fout "\\header { \ntitle = \"%s\" \ncomposer= \"... to do...\" \n }\n" t.name ; 
      p fout "symbols = \\relative c {\n" ;
      List.iter ( fun pa -> 
	p fout "%% ========= %s\n" pa.Part.name ;
	p fout "\\mark \"sec:%s\" \n" pa.Part.name ; 
	p fout "\\tempo 4 = %d \n" t.tempo ; 
	p fout "\\time %d\n" ( match pa.Part.signature with
	  | Some s -> s | None -> t.signature ) ;
	List.iter ( fun b ->
	  p fout "%s | " b.Bar.ly
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


      if midichords then (
	p fout "\\score {\n" ;
	p fout "  <<\n" ;
	p fout " \\new ChordNames { \n" ;
	p fout "   \\override BarLine #'bar-extent = #'(-2 . 2) \n" ;
	(* p fout "   \\consists \"Bar_engraver\" \n" ; *)
	p fout "    \\accords \n" ;
	p fout " } \n" ;
	p fout "  >>\n" ;
	(* p fout "  \\layout{}\n" ;*)
	p fout "  \\midi{}\n" ;
	p fout "}\n" ;
      ) else (
	p fout "\\score {\n" ;
	p fout "  <<\n" ;
	if chords then p fout "    \\new ChordNames { \\accords } \n" ;
	if notes then p fout "   \\new Staff { \\clef \"treble_8\" \\symbols }\n" ;
	if tabs then p fout "   \\new TabStaff { \\symbols } \n" ;
	p fout "  >>\n" ;
	p fout "  \\layout{}\n" ;
	p fout "}\n" ;

	p fout "\\score {\n" ;
	p fout "  <<\n" ;
	p fout "   \\new Staff { \\clef \"treble_8\" \\symbols }\n" ;
	p fout "  >>\n" ;
	p fout "  \\midi{}\n" ;
	p fout "}\n" ;
      ) ;

      close_out fout ;
      ()
	


  let to_ly_file t ~notes ~tabs ~chords = try
    let filename = sprintf "%s.ly" t.name in
    let filename = Str.global_replace (Str.regexp " ") "_" filename in
      internal_to_ly_file ~t ~filename ~notes ~tabs ~chords ~midichords:false ;
      List.iter ( fun part ->
	let t = { t with structure=[part.Part.id] ; name=sprintf "%s-%s" t.name part.Part.name } in
	let filename = sprintf "%s.ly" t.name in
	let filename = Str.global_replace (Str.regexp " ") "_" filename in
	  internal_to_ly_file ~t ~filename ~notes ~tabs ~chords ~midichords:false ;
      ) (struct_of_t t)
    with
      | e -> eprintf "to_ly_file\n" ; raise e

  let to_ly_midichords t = try
    let filename = sprintf "%s-chords.ly" t.name in
    let filename = Str.global_replace (Str.regexp " ") "_" filename in
      internal_to_ly_file ~t ~filename ~notes:false ~tabs:false ~chords:true ~midichords:true
    with
      | e -> eprintf "to_ly_midichords\n" ; raise e

  let to_json t = try
    let module Bu = Json_type.Build in
    let j = Bu.objekt [
      "name",Bu.string t.name ;
      "parts",Bu.list Part.to_json (List.map snd t.parts) ;
      "struct",Bu.list Bu.string (List.map ( fun p -> p.Part.id ) (struct_of_t t))
    ] in
      j
    with
      | e -> eprintf "to_json\n" ; raise e
  let save_json t =
    let filename = Str.global_replace (Str.regexp " ") "_" t.name in
    let filename = filename ^ ".json" in
      Json_io.save_json filename (to_json t)


  let load_json filename =
    let module Br = Json_type.Browse in
    let j = Json_io.load_json filename in
    let j = Br.objekt j in
    let table = Br.make_table j in
      {
	name = Br.string(Br.field table "name") ;
	midi = false ;
	signature = Br.int(Br.field table "signature") ;
	tempo = Br.int(Br.field table "tempo") ;
	parts = Br.list Part.from_json (Br.field table "parts") ;
	structure = Br.list Br.string (Br.field table "struct") ;
      }


