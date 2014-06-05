#include "FiveWin.ch"

class TAGet
   data aMa  // materias
   data lMa

   method New() constructor
   method Load()
EndClass

Method New() Class TAGet
   ::aMa := {}
   ::lMa := .t.

return self

method Load()
   local aAuxArray := {}
   local nAuxOrder
   local nAuxRecno
   local nArea    := Select()

   // fichero MATERIAS
   if ::lMa
		::aMa := oApp():aMaterias
		ASort(::aMa)
      ::lMa := .f.
   endif
return nil



