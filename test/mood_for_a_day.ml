open Printf

let mes1 = { 
  Bar.ly = "
  \\set TabStaff.minimumFret = #2
  <g, d g b d' g'>8
  <g, d g b d' g'>
  <g, d g b d' g'>
  <g, d g b d' g'>
  <fis, cis fis ais cis' fis'>16
  r8.
" ;
  chords = "g2 fis4" ;
}

let mes2 = { Bar.ly = "
  <g, d g b d' g'>8
  <g, d g b d' g'>
  <g, d g b d' g'>
  <g, d g b d' g'>
  \\set TabStaff.minimumFret = #0
  <fis, cis fis ais cis' e'>16
  r16
  <fis, cis fis ais cis' e'>16
  r16
" ; 
	     chords="g2 fis4:7" ;
}

let mes3 = { Bar.ly = "
  \\set TabStaff.minimumFret = #0
  r8
  <fis cis' fis ais cis e>8
  r8
  <fis cis' fis ais cis e>8
  r8
  <fis cis' fis ais cis e>8
" ;
	     chords="fis2." ;
}

let mes4 = {
  Bar.ly = "fis,8 g ais8 b d dis" ;
  chords="b2.:m" ;
}

let mes5 = {
  Bar.ly = "g,8 fis8 r4 r4" ;
  chords="b2.:m" ;
}


let part1 = { Part.name="A" ; id="A" ;  bars=[ 
  mes1 ; mes1 ; mes2 ; mes3 ; 
  mes1 ; mes1 ; mes2 ; mes3 ; 
] ; signature=None ; }

let part2 = { Part.name="B" ; id="B" ; bars=[
  mes4 ; mes5
] ; signature=None}

let score = {
  Score.name = "mood for a day" ;
  parts = [ part1.Part.id,part1 ; part2.Part.id,part2 ] ;
  structure = [ part1.Part.id ; part2.Part.id ] ;
  signature=3 ;
  tempo = 120 ;
}


(*
let () = Score.to_ly_file score ~notes:true ~tabs:true ~chords:true
let () = Score.to_ly_midichords score 
let () = Score.to_tex_file score 
*)
let () = Score.save_json score (sprintf "mood_for_a_day.json")
