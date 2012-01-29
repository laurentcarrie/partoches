open Util
open Printf

type t = {
  name : string ;
  score : Score.t ;
  instruments : Instrument.t list ;
  parts : Part.t list ;
}


let of_json j = __PA__try "of_json" (
  let module Br = Json_type.Browse in
  let table = Br.make_table (Br.objekt j) in
  let name = Br.string (Br.field table "name") in
  let () = log Debug "name = %s" name in
  let instruments = Br.list Instrument.of_json (Br.field table "instruments") in
  let parts = Br.list (Part.of_json instruments) (Br.field table "parts") in
  let score = Score.of_json (Br.field table "score") parts in
  let () = log Debug "%d parts" (List.length parts) in
    { name=name ; score=score ; parts=parts ; instruments=instruments ; }
) ;;

let to_json t = __PA__try "of_json" (
  let module Bu = Json_type.Build in
  let j = Bu.objekt [
    "name",Bu.string t.name ;
    "instruments",Bu.list Instrument.to_json t.instruments ;
    "parts",Bu.list Part.to_json t.parts ;
    "score",Score.to_json t.score ;
  ] in
  j
) ;;

let of_file filename = __PA__try "of_file" (
  let j = Json_io.load_json filename in
    of_json j
) ;;

let to_file song filename = __PA__try "to_file" (
  let j = to_json song in
  Json_io.save_json filename j
) ;;

let save song path = __PA__try "save" (
  let name = Str.global_replace (Str.regexp " ") "-" song.name in
  let filename = path // (name ^ ".json") in
  to_file song filename
) ;;

let to_lilypond song = __PA__try "to_lilypond" (

  let staff instrument  = __PA__try "staff instrument" (
    sprintf "\n\
      \\new Staff {\n\
        \\tempo 4 = 180 \n\
	\\clef \"treble_8\"\n\
	\\set Staff.midiInstrument = #\"%s\"\n\
	\\set Staff.instrumentName = #\"%s\"\n\
%s \n\
      }" 
      instrument.Instrument.midi
      instrument.Instrument.name
      (List.fold_left ( fun acc (part,_) -> acc ^ "\n\\" ^ (part.Part.name) ^ (instrument.Instrument.name)) "" song.score.Score.parts)
  )  in

  let content = sprintf "\n\
\\version \"2.12.3\"\n\
\\include \"predefined-guitar-fretboards.ly\" \n\
#(set-default-paper-size \"a4\")\n\
\n\
\\header {\n\
\ttitle = \"%s\"\n\
}\n\
\n\
%s
\\score {\n\
\t<<\n\
%s
\t>>\n\
\\midi{\n\
\n\
}\n\
\n\
\\layout{\n\
\tragged-right = ##t\n\
\tindent = 4\\cm\n\
\tshort-indent = 2\\cm\n\
}\n\
\n\
}\n\
" 
      song.name
      (List.fold_left ( fun acc part -> acc ^ "\n" ^ (Part.to_lilypond part)) "" song.parts)
      (List.fold_left ( fun acc instrument -> acc ^ (staff instrument) ^ "\n" ) "" song.instruments)
  in
    content

) ;;

let midi_filename song = 
  let s = song.name ^ ".midi" in
    Str.global_replace (Str.regexp " ") "-" s

let output song = __PA__try "output" (
  let () = Std.output_file ~filename:"data.ly" ~text:(to_lilypond song) in
  let filename = Str.global_replace (Str.regexp " ") "-" song.name in
  let command = sprintf "lilypond  --png -o %s data.ly" filename in 
    system command
) ;;
