open Printf

module Chord = struct
  type t = {
    c : string
  }
end


module Part = struct
  type t = {
    name : string ;
    bars : Bar.t list ;
  }
end

module Score = struct
  type t = {
    name : string ;
    parts : Part.t list ;
  }

end

module Lilypond = struct
  type t = {
    content : string ;
  }

  let of_note n = "c"

  let of_bar b = match b with
    | Bar.NL nl -> List.fold_left ( fun acc n -> acc ^ " " ^ (of_note n) ) "" nl
    | Bar.CL _ -> __PA__NOT_IMPLEMENTED__

  let of_part p : string = 
    sprintf "\n\
%s = { %s } " p.Part.name ( List.fold_left ( fun acc bar -> acc ^ " " ^ (of_bar bar)) "" p.Part.bars ) ;;

  let of_score p = 
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
	\set Staff.midiInstrument = #\"acoustic guitar (steel)\"\n\
	\set Staff.instrumentName = #\"guitar\"\n\
%s
      }

      \\new TabStaff {\n\
	\\clef \"treble_8\"\n\
	\set Staff.midiInstrument = #\"acoustic guitar (steel)\"\n\
	\set Staff.instrumentName = #\"guitar\"\n\
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
      p.Score.name
      (List.fold_left ( fun acc p -> sprintf "%s\n%s" acc (of_part p)) "" p.Score.parts)
      (List.fold_left ( fun acc p -> sprintf "%s\n\\%s" acc p.Part.name) "" p.Score.parts)
      (List.fold_left ( fun acc p -> sprintf "%s\n\\%s" acc p.Part.name) "" p.Score.parts)
  in 
    { content=content }


  let output p filename =
    let () = Std.output_file ~filename:"data.ly" ~text:p.content in
    let command = sprintf "lilypond  --pdf -o %s data.ly" filename in 
      match Unix.system command with
	| Unix.WEXITED 0 -> ()
	| Unix.WEXITED i -> __PA__failwith ("command " ^ command ^ " exited with code " ^ (string_of_int i))
	| Unix.WSIGNALED i -> __PA__failwith ("command " ^ command ^ " signaled with code " ^ (string_of_int i))
	| Unix.WSTOPPED i -> __PA__failwith ("command " ^ command ^ " stopped with code " ^ (string_of_int i))
end
