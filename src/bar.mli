type t = { 
  ly : string ;
  chords : string ;
}
    
val to_json : t -> Json_type.t
val from_json : Json_type.t -> t	
