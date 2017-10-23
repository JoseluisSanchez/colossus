#include "dbinfo.ch"
#include "FiveWin.ch"
#include "xBrowse.ch"

/*_____________________________________________________________________________*/

FUNCTION Materia( lSelect, cClMateria, oGet, oGridCL )

   LOCAL oDlgMat, oGridMa, oCol
   LOCAL lOk := .F.
   LOCAL aPoint := iif( oGet != NIL, AdjustWnd( oGet, 250, 150 ), )

   IF ! lSelect
      DEFINE DIALOG oDlgMat RESOURCE 'MATER01_' + oApp():cLanguage     ;
         TITLE i18n( "Gestión de materias" )
      oDlgMat:SetFont( oApp():oFont )
   ELSE
      DEFINE DIALOG oDlgMat RESOURCE 'MATER02_' + oApp():cLanguage     ;
         TITLE i18n( "Selección de materias" )
      oDlgMat:SetFont( oApp():oFont )
   ENDIF

   oGridMa := TXBrowse():New( oDlgMat )
   oGridMa:SetArray( oApp():aMaterias )
   Ut_BrwRowConfig( oGridMa, )
   oGridMa:aCols[ 1 ]:cHeader  := i18n( "Materia" )
   oGridMa:aCols[ 1 ]:nWidth   := 130
   oGridMa:aCols[ 1 ]:AddResource( "16_SORT_A" )
   oGridMa:aCols[ 1 ]:AddResource( "16_SORT_B" )
   oGridMa:aCols[ 1 ]:nHeadBmpNo  := 1 // { || iif(.t.,1,2) }
   oGridMa:aCols[ 1 ]:nHeadBmpAlign := AL_RIGHT
   oGridMa:aCols[ 1 ]:nHeadStrAlign := AL_LEFT
   oGridMa:aCols[ 2 ]:cHeader  := i18n( "Claves" )
   oGridMa:aCols[ 2 ]:nWidth   := 60
   oGridMa:aCols[ 2 ]:nHeadStrAlign := AL_RIGHT


   IF lSelect
      oGridMa:aCols[ 1 ]:bLDClickData  := {|| ( lOk := .T., oDlgMat:End() ) }
   ELSE
      oGridMa:aCols[ 1 ]:bLDClickData  := {|| MaEdit( oGridMa, .F., oGridCL, oDlgMat ) }
   ENDIF
   oGridMa:bKeyDown := {| nKey| MaTecla( nKey, oGridMa, lSelect, @lOk, oGridCL, oDlgMat ) }
   oGridMa:CreateFromResource( 101 )

   REDEFINE BUTTON ID 402 OF oDlgMat  ;
      ACTION MaEdit( oGridMa, .T., oGridCL, oDlgMat )

   REDEFINE BUTTON ID 403 OF oDlgMat  ;
      ACTION MaEdit( oGridMa, .F., oGridCL, oDlgMat )

   REDEFINE BUTTON ID 404 OF oDlgMat  ;
      ACTION MaBorra( oGridMa, oGridCL )

   IF ! lSelect
      REDEFINE BUTTON ID 400 OF oDlgMat  ;
         ACTION oDlgMat:End()

      ACTIVATE DIALOG oDlgMat ;
         ON INIT DlgCenter( oDlgMat, oApp():oWndMain )
   ELSE
      REDEFINE BUTTON ID 400 OF oDlgMat  ;
         ACTION ( lOk := .T., oDlgMat:End() )
      REDEFINE BUTTON ID 401 OF oDlgMat  ;
         ACTION ( lOk := .F., oDlgMat:End() )

      ACTIVATE DIALOG oDlgMat ;
         ON INIT ( oDlgMat:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. ), ;
         oGridMa:SetFocus( .T. ) )

      IF lOK
         cClMateria := oApp():aMaterias[ oGridMa:nArrayAt, 1 ]
         ? cClMateria
         oGet:refresh()
      ENDIF
   ENDIF

   SELECT CL

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION MaEdit( oGridMa, lAppend, oGridCL, oDlgMat )

   LOCAL oDlgEM
   LOCAL cMaMateria  := iif( oGridMa:nArrayAt > 0, oApp():aMaterias[ oGridMa:nArrayAt ], Space( 20 ) )
   LOCAL cOldMateria := iif( oGridMa:nArrayAt > 0, oApp():aMaterias[ oGridMa:nArrayAt ], Space( 20 ) )
   LOCAL lSave       := .F.
   LOCAL lDuplicado
   LOCAL cTitulo
   LOCAL cSay01, cSay02
   LOCAL oGet01, nClOrder, nClRecno

   IF lAppend
      cMaMateria  := Space( 20 )
      cSay01      := i18n( "Nueva materia" )
   ELSE
      cSay01      := i18n( "Modificar materia" )
   ENDIF

   DEFINE DIALOG oDlgEM RESOURCE 'MATER03_' + oApp():cLanguage ;
      TITLE cSay01
   oDlgEm:SetFont( oApp():oFont )
   oDlgEm:lHelpIcon = .F.

   REDEFINE SAY ID 11 OF oDlgEM
   REDEFINE GET oGet01 VAR cMaMateria ID 12 OF oDlgEM  ;
      VALID MaUnica( @cMaMateria, oGet01, lAppend )

   REDEFINE BUTTON ID 400 OF oDlgEM  ;
      ACTION ( lSave := .T., oDlgEM:End() )
   REDEFINE BUTTON ID 401 OF oDlgEM CANCEL;
      ACTION ( lSave := .F., oDlgEM:End() )

   ACTIVATE DIALOG oDlgEM ON INIT DlgCenter( oDlgEm, oDlgMat )

   IF lSave
      IF lAppend
         /*___ nueva materia __________________________________________________*/
         AAdd( oApp():aMaterias, cMaMateria )
         ASort( oApp():aMaterias,,, {| x, y| Upper( x ) < Upper( y ) } )
      ELSE
         /*___ modificación ___________________________________________________*/
         oApp():aMaterias[ oGridMa:nArrayAt ] := cMaMateria
         ASort( oApp():aMaterias,,, {| x, y| Upper( x ) < Upper( y ) } )
         IF cMaMateria != cOldMateria
            SELECT CL
            nClOrder := CL->( ordNumber() )
            nClRecno := CL->( RecNo() )
            CL->( dbSetOrder( 0 ) )
            CL->( dbGoTop() )
            REPLACE CL->ClMateria WITH cMaMateria FOR CL->ClMateria == cOldMateria
            CL->( dbCommit() )
            CL->( dbSetOrder( nClOrder ) )
            CL->( dbGoto( nClRecno ) )
            oGridCL:Refresh()
         ENDIF
      ENDIF
   ENDIF
   oGridMa:Refresh( .T. )
   oGridMa:SetFocus( .T. )

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION MaBorra( oGridMa, oGridCL )

   LOCAL cMaMateria := oApp():aMaterias[ oGridMa:nArrayAt ]
   LOCAL oGet01, nClOrder, nClRecno

   IF MsgYesNo( i18n( "¿ Está seguro de querer borrar esta materia ?" ) + CRLF + ( cMaMateria ) )
      ADel( oApp():aMaterias, oGridMa:nArrayAt, .T. )
      // dejo en blanco la materia de las claves implicadas
      SELECT CL
      nClOrder := CL->( ordNumber() )
      nClRecno := CL->( RecNo() )
      CL->( dbSetOrder( 0 ) )
      CL->( dbGoTop() )
      REPLACE CL->ClMateria WITH "" FOR CL->ClMateria == cMaMateria
      CL->( dbCommit() )
      CL->( dbSetOrder( nClOrder ) )
      CL->( dbGoto( nClRecno ) )
      IF oGridCL != NIL
         oGridCL:Refresh()
      ENDIF
   ENDIF
   oGridMa:Refresh( .T. )
   oGridMa:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION MaClave( cMateria, oGet )

   IF AScan( oApp():aMaterias, {|a| a[ 1 ] == cMateria } ) == 0
      MsgAlert( "La materia no existe. Se dará de alta al guardar la clave." )
   ENDIF

   RETURN .T.
/*_____________________________________________________________________________*/
FUNCTION MaUnica( cMateria, oGet, lAppend )

   LOCAL lRet   := .T.

   IF Empty( cMateria )
      MsgStop( i18n( "Es obligatorio introducir la materia." ) )
      RETU .F.
   ENDIF
   IF AScan( oApp():aMaterias, cMateria ) != 0
      IF lAppend
         MsgStop( i18n( "Materia existente, no se puede realizar el alta." ) )
         cMateria := Space( 20 )
         oGet:Refresh()
         lRet := .F.
      ELSE
         MsgStop( i18n( "Materia existente, no se puede realizar la modificación." ) )
         cMateria := Space( 20 )
         oGet:Refresh()
         lRet := .F.
      ENDIF
   ENDIF

   RETURN lRet
/*_____________________________________________________________________________*/
FUNCTION MaTecla( nKey, oGridMa, lSelect, lOk, oGridCL, oDlgMat )

   DO CASE
   CASE nKey == VK_RETURN .AND. lSelect
      lOk := .T.
      oDlgMat:End()
   CASE nKey == VK_RETURN .AND. ! lSelect
      MaEdit( oGridMa, .F., oGridCL, oDlgMat )
   CASE nKey == VK_INSERT
      MaEdit( oGridMa, .T., oGridCL, oDlgMat )
   CASE nKey == VK_DELETE
      MaBorra( oGridMa )
   OTHERWISE
      // if nKey>=96 .AND. nKey <=105
      // nKey := nKey - 48
      // endif
      IF nKey >= 48 .AND. nKey <= 90
         MaBusca( oGridMa, Chr( nKey ) )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION MaBusca( oGridMa, cChr )

   LOCAL nRecno    := oGridMa:nArrayAt
   LOCAL oDlg, oGet, cGet
   LOCAL cMateria  := Space( 20 )
   LOCAL lSeek     := .F.
   LOCAL lRet    := .F.

   DEFINE DIALOG oDlg RESOURCE 'DlgBusca'  ;
      TITLE i18n( "Búsqueda de materias" )
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY PROMPT i18n( "Introduzca la materia" ) ID 20 OF oDlg
   REDEFINE SAY PROMPT i18n( "Materia" ) + ":"           ID 21 OF Odlg
   cGet     := cMateria

   /*__ si he pasado un caracter lo meto en la cadena a buscar ________________*/

   IF cChr != nil
      cGet := cChr + SubStr( cGet, 1, Len( cGet ) -1 )
   ENDIF

   REDEFINE GET oGet VAR cGet ID 101 OF oDlg

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION ( lSeek := .T., oDlg:End() )
   REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
      PROMPT i18n( "&Cancelar" )  ;
      ACTION ( lRet := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter( oDlg, oApp():oWndMain ), iif( cChr != NIL, oGet:SetPos( 2 ), ) )

   IF lSeek
      cGet := RTrim( Upper( cGet ) )
      IF AScan( oApp():aMaterias, cGet ) == 0
         MsgAlert( i18n( "No encuentro esa materia." ) )
      ELSE
         oGridMa:nArrayAt := AScan( oApp():aMaterias, cGet )
      ENDIF
   ENDIF
   oGridMa:Refresh()
   oGridMa:SetFocus( .T. )

   RETURN NIL

// _____________________________________________________________________________//
