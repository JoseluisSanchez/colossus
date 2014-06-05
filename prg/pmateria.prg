#include "dbinfo.ch"
#include "FiveWin.ch"
#include "xBrowse.ch"

/*_____________________________________________________________________________*/

function Materia(lSelect,cClMateria,oGet,oGridCL)
   local oDlgMat, oGridMa, oCol
   local lOk := .f.
   local aPoint := IIF(oGet!=NIL,AdjustWnd(oGet,250,150),)

   if ! lSelect
      DEFINE DIALOG oDlgMat RESOURCE 'MATER01_'+oApp():cLanguage     ;
         TITLE i18n("Gestión de materias") FONT oApp():oFont
   else
      DEFINE DIALOG oDlgMat RESOURCE 'MATER02_'+oApp():cLanguage     ;
         TITLE i18n("Selección de materias") FONT oApp():oFont
   endif

   oGridMa := TXBrowse():New( oDlgMat )
	Ut_BrwRowConfig( oGridMa, )
	oGridMa:SetArray(oApp():aMaterias)
   oGridMa:aCols[1]:cHeader  := i18n("Materia")
   oGridMa:aCols[1]:nWidth   := 100
   if lSelect
      oGridMa:aCols[1]:bLDClickData  := {|| (lOk:=.t.,oDlgMat:End()) }
   else
      oGridMa:aCols[1]:bLDClickData  := {|| MaEdit(oGridMa, .f.,oGridCL,oDlgMat) }
   endif
   oGridMa:bKeyDown := {|nKey| MaTecla( nKey, oGridMa, lSelect, @lOk, oGridCL, oDlgMat ) }
   oGridMa:CreateFromResource( 101 )

   REDEFINE BUTTON ID 402 OF oDlgMat  ;
      ACTION MaEdit( oGridMa, .t., oGridCL, oDlgMat)

   REDEFINE BUTTON ID 403 OF oDlgMat  ;
      ACTION MaEdit( oGridMa, .f., oGridCL, oDlgMat )

   REDEFINE BUTTON ID 404 OF oDlgMat  ;
      ACTION MaBorra( oGridMa, oGridCL )

   if ! lSelect
      REDEFINE BUTTON ID 400 OF oDlgMat  ;
         ACTION oDlgMat:End()

      ACTIVATE DIALOG oDlgMat ;
         ON INIT DlgCenter(oDlgMat,oApp():oWndMain)
   else
      REDEFINE BUTTON ID 400 OF oDlgMat  ;
         ACTION (lOk := .t., oDlgMat:End())
      REDEFINE BUTTON ID 401 OF oDlgMat  ;
         ACTION (lOk := .f., oDlgMat:End())

      ACTIVATE DIALOG oDlgMat ;
         ON INIT (oDlgMat:Move(aPoint[1], aPoint[2],,,.t.),;
                  oGridMa:SetFocus(.t.))

      if lOK
         cClMateria := oApp():aMaterias[oGridMa:nArrayAt]
         oGet:refresh()
      endif
   endif

   select CL

return nil

/*_____________________________________________________________________________*/

function MaEdit( oGridMa, lAppend, oGridCL, oDlgMat )
   local oDlgEM
   local cMaMateria  := oApp():aMaterias[oGridMa:nArrayAt]
   local cOldMateria := oApp():aMaterias[oGridMa:nArrayAt]
   local lSave       := .f.
   local lDuplicado
   local cTitulo
   local cSay01, cSay02
	local oGet01, nClOrder, nClRecno

   if lAppend
      cMaMateria  := space(20)
      cSay01      := i18n("Nueva materia")
   else
      cSay01      := i18n("Modificar materia")
   endif

   DEFINE DIALOG oDlgEM RESOURCE 'MATER03_'+oApp():cLanguage ;
      TITLE cSay01 FONT oApp():oFont
   oDlgEm:lHelpIcon = .f.

   REDEFINE SAY VAR cSay01     ID 11 OF oDlgEM
   REDEFINE GET oGet01 VAR cMaMateria ID 12 OF oDlgEM  ;
      VALID MaUnica(@cMaMateria,oGet01,lAppend)

   REDEFINE BUTTON ID 400 OF oDlgEM  ;
      ACTION (lSave := .t., oDlgEM:End())
   REDEFINE BUTTON ID 401 OF oDlgEM CANCEL;
      ACTION (lSave := .f., oDlgEM:End())

   ACTIVATE DIALOG oDlgEM ON INIT DlgCenter(oDlgEm,oDlgMat)

   if lSave
      if lAppend
         /*___ nueva materia __________________________________________________*/
			AAdd(oApp():aMaterias, cMaMateria)
			ASort(oApp():aMaterias,,, {|x,y| upper(x) < upper(y) } )
      else
         /*___ modificación ___________________________________________________*/
			oApp():aMaterias[oGridMa:nArrayAt] := cMaMateria
			ASort(oApp():aMaterias,,, {|x,y| upper(x) < upper(y) } )
         if cMaMateria != cOldMateria
            select CL
            nClOrder := CL->(OrdNumber())
            nClRecno := CL->(Recno())
            CL->(DbSetOrder(0))
            CL->(DbGoTop())
            replace CL->ClMateria with cMaMateria for CL->ClMateria == cOldMateria
            CL->(DbCommit())
            CL->(DbSetOrder(nClOrder))
            CL->(DbGoTo(nClRecno))
            oGridCL:Refresh()
         endif
      endif
   endif
   oGridMa:Refresh(.t.)
   oGridMa:SetFocus( .t. )
return nil

/*_____________________________________________________________________________*/

function MaBorra(oGridMa,oGridCL)
   local cMaMateria := oApp():aMaterias[oGridMa:nArrayAt]
	local oGet01, nClOrder, nClRecno
   if MsgYesNo(i18n("¿ Está seguro de querer borrar esta materia ?")+CRLF+(cMaMateria))
		ADel(oApp():aMaterias,oGridMa:nArrayAt,.t.)
      // dejo en blanco la materia de las claves implicadas
      select CL
      nClOrder := CL->(OrdNumber())
      nClRecno := CL->(Recno())
      CL->(DbSetOrder(0))
      CL->(DbGoTop())
      replace CL->ClMateria with "" for CL->ClMateria == cMaMateria
      CL->(DbCommit())
      CL->(DbSetOrder(nClOrder))
      CL->(DbGoTo(nClRecno))
      if oGridCL != NIL
         oGridCL:Refresh()
      endif
   endif
   oGridMa:Refresh(.t.)
   oGridMa:SetFocus(.t.)
return nil
/*_____________________________________________________________________________*/
function MaClave(cMateria,oGet)
	if AScan(oApp():aMaterias, cMateria) == 0
		MsgAlert("La materia no existe. Se dará de alta al guardar la clave.")
	endif
return .t.
function MaUnica(cMateria,oGet,lAppend)
   local lRet   := .t.
   if Empty(cMateria)
      MsgStop( i18n( "Es obligatorio introducir la materia." ) )
      retu .f.
   endif
   if AScan(oApp():aMaterias, cMateria) != 0
      if lAppend
         MsgStop(i18n("Materia existente, no se puede realizar el alta."))
         cMateria := space(20)
         oGet:Refresh()
         lRet := .f.
      else
         MsgStop(i18n("Materia existente, no se puede realizar la modificación."))
         cMateria := space(20)
         oGet:Refresh()
         lRet := .f.
      endif
   endif
return lRet
/*_____________________________________________________________________________*/
function MaTecla( nKey, oGridMa, lSelect, lOk, oGridCL, oDlgMat )
   do case
      case nKey==VK_RETURN .AND. lSelect
         lOk := .t.
         oDlgMat:End()
      case nKey==VK_RETURN .AND. ! lSelect
         MaEdit( oGridMa, .f., oGridCL, oDlgMat )
      case nKey==VK_INSERT
         MaEdit( oGridMa, .t., oGridCL, oDlgMat )
      case nKey==VK_DELETE
         MaBorra(oGridMa)
      otherwise
         //if nKey>=96 .AND. nKey <=105
         //  nKey := nKey - 48
         //endif
         if nKey>=48 .AND. nKey <=90
            MaBusca(oGridMa, chr(nKey))
         endif
   endcase
return nil
/*_____________________________________________________________________________*/

function MaBusca( oGridMa, cChr )
   local nRecno    := oGridMa:nArrayAt
   local oDlg, oGet, cGet
   local cMateria  := space(20)
   local lSeek     := .f.
	local lRet 		 := .f.

   DEFINE DIALOG oDlg RESOURCE 'DlgBusca' FONT oApp():oFont ;
      TITLE i18n("Búsqueda de materias")

   REDEFINE SAY PROMPT i18n("Introduzca la materia") ID 20 OF oDlg
   REDEFINE SAY PROMPT i18n("Materia")+":"           ID 21 OF Odlg
   cGet     := cMateria

   /*__ si he pasado un caracter lo meto en la cadena a buscar ________________*/

   if cChr != nil
      cGet := cChr+SubStr(cGet,1,len(cGet)-1)
   endif

   REDEFINE GET oGet VAR cGet ID 101 OF oDlg

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION (lSeek := .t., oDlg:End())
   REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
      PROMPT i18n( "&Cancelar" )  ;
      ACTION (lRet := .f., oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT (DlgCenter(oDlg,oApp():oWndMain), IIF(cChr!=NIL,oGet:SetPos(2),))

   if lSeek
      cGet := rtrim(Upper(cGet))
      if AScan(oApp():aMaterias, cGet) == 0
         MsgAlert(i18n("No encuentro esa materia."))
		else
			oGridMa:nArrayAt := AScan(oApp():aMaterias, cGet)
      endif
   endif
   oGridMa:Refresh()
   oGridMa:SetFocus( .t. )
return nil

//_____________________________________________________________________________//

