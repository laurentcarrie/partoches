\version "2.12.3"
\include "predefined-guitar-fretboards.ly"


#(set-default-paper-size "a4")

\header {
  title = "Under the Bridge"
}

intro = \relative c {
  \set TabStaff.minimumFret = #2
  d8\5 fis a fis16 d' ~ d a8. cis,16 b a gis 
  fis8 cis' fis cis16 ais'16 ~ ais  fis8. \appoggiatura e8 fis16 e d b 
  d8\5 fis a fis16 d' ~ d a8. cis,16 b a gis
  fis8 cis' fis cis16 ais'16 ~ ais fis8. \appoggiatura e8 fis16 e d b 
}

myChords =  \chordmode { d1 fis1 d,1 fis1 }

myMusic = { \intro }

\paper {
				%  system-separator-markup = \slashSeparator
}

\book {
  \score {
    \new StaffGroup { <<
      
      \new Staff {
	\clef "treble_8"
	\set Staff.midiInstrument = #"acoustic guitar (steel)"
	\set Staff.instrumentName = #"guitar"
	\myMusic
      }
%{
      \new ChordNames {
	\set Staff.midiInstrument = #"acoustic grand"
	\myChords
      }
      \new FretBoards {
	\set Staff.midiInstrument = #"acoustic grand"
	\myChords
      }
%}
      \new TabStaff {
	\set Staff.midiInstrument = #"acoustic guitar (steel)"
	\myMusic
      }
      \new DrumStaff <<
	\new DrumVoice { 
	  \voiceOne \drummode {
	    hh8 hh8 hh8 hh8 hh8 hh8 hh8 hh8
	    hh8 hh8 hh8 hh8 hh8 hh8 hh8 hh8
	    hh8 hh8 hh8 hh8 hh8 hh8 hh8 hh8
	    hh8 hh8 hh8 hh8 hh8 hh8 hh8 hh8
	  }
	}
	\new DrumVoice {
	  \voiceTwo \drummode {
	    bd4 sn4 bd4 sn4
	    bd4 sn4 bd4 sn4
	    bd4 sn4 bd4 sn4
	    bd4 sn4 bd4 sn4
	  }
	}
      >>
    >>
		    }
    
    \midi{

    }

    \layout{
      ragged-right = ##t
      indent = 4\cm
      short-indent = 2\cm
    }
  }
}




