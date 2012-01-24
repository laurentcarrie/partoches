module Chord : sig
  type t = {
    c : string
  }
end

module Part : sig
  type t = {
    name : string ;
    bars : Bar.t list ;
  }
end

module Score : sig
  type t = {
    name : string ;
    parts : Part.t list ;
  }
end



module Lilypond : sig
  type t = {
    content : string ;
  }

  val of_score : Score.t -> t
  val output : t -> string -> unit

end

	       
