open Util
open Printf

type t = {
  name : string ;
  score : Score.t ;
  parts : Part.t list ;
}


let of_file filename = __PA__try "of_file" (
  let module Br = Json_type.Browse in
  let j = Json_io.load_json filename in
  let table = Br.make_table (Br.objekt j) in
  let name = Br.string (Br.field table "name") in
  let () = log Debug "name = %s" name in
  let parts = Br.list Part.of_json (Br.field table "parts") in
  let score = Score.of_json (Br.field table "score") parts in
  let () = log Debug "%d parts" (List.length parts) in
    { name=name ; score=score ; parts=parts }
) ;;


let to_lilypond song = __PA__try "to_lilypond" (
  let content = sprintf "\n\
\\version \"2.12.3\"\n\
\\include \"predefined-guitar-fretboards.ly\" \n\
#(set-default-paper-size \"a4\")\n\
\n\
\\header {\n\
  title = \"%s\"\n\
}\n\
\n\
%s
  \\score {\n\
<<
      \\new Staff {\n\
	\\clef \"treble_8\"\n\
	\\set Staff.midiInstrument = #\"acoustic guitar (steel)\"\n\
	\\set Staff.instrumentName = #\"guitar\"\n\
%s
      }

      \\new TabStaff {\n\
	\\clef \"treble_8\"\n\
	\\set Staff.midiInstrument = #\"acoustic guitar (steel)\"\n\
	\\set Staff.instrumentName = #\"guitar\"\n\
%s
      }
>>

    \n\
    \\midi{\n\
\n\
    }\n\
\n\
    \\layout{\n\
      ragged-right = ##t\n\
      indent = 4\\cm\n\
      short-indent = 2\\cm\n\
    }\n\
\n\
	}\n\
" 
      song.name
      (List.fold_left ( fun acc part -> acc ^ "\n" ^ (Part.to_lilypond part)) "" song.parts)
      (List.fold_left ( fun acc part -> acc ^ "\n\\" ^ (part.Part.name)) "" song.parts)
      (List.fold_left ( fun acc part -> acc ^ "\n\\" ^ (part.Part.name)) "" song.parts)
  in
    content

) ;;

let output song = __PA__try "output" (
  let () = Std.output_file ~filename:"data.ly" ~text:(to_lilypond song) in
  let filename = Str.global_replace (Str.regexp " ") "-" song.name in
  let command = sprintf "lilypond  --pdf -o %s data.ly" filename in 
    system command
) ;;
