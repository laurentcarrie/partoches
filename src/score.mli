type t = {
  name : string ;
  parts : (Part.id * Part.t) list ;
  structure : Part.id list ;
  signature:int ;
  tempo : int ;
}

val generate_pdf : notes:bool -> tabs:bool -> chords:bool -> drums:bool -> t -> string list
val generate_midi_chords : t -> drums:bool -> string list
val generate_midi : t -> drums:bool -> string list
val generate_midi_parts : t -> drums:bool -> string list
val generate_pdf_struct : t -> string list
val to_json : t -> Json_type.t
val save_json : t -> string -> unit
val load_json : string -> t

