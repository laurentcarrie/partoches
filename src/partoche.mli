
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
val to_ly_file : t -> notes:bool -> tabs:bool -> chords:bool -> unit
val to_ly_midichords : t -> unit
val to_tex_file : t -> unit
val to_json : t -> Json_type.t
val save_json : t -> unit
val load_json : string -> t

