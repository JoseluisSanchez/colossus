#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "ttitle.ch"
#include "AutoGet.ch"

STATIC oReport
// _____________________________________________________________________________//

FUNCTION Claves( cDbfFile )

   LOCAL oBar
   LOCAL oBmp
   LOCAL oCol
   LOCAL cClState := GetPvProfString( "Browse", "State", "", oApp():cIniFile )
   LOCAL nClOrder := Val( GetPvProfString( "Browse", "Order", "1", oApp():cIniFile ) )
   LOCAL nClRecno := Val( GetPvProfString( "Browse", "Recno", "1", oApp():cIniFile ) )
   LOCAL nSplit   := 105
   LOCAL oCont
   LOCAL i
   LOCAL aTipo    := { i18n( "Sitio web" ), i18n( "Archivo" ), i18n( "Otro" ) }
   LOCAL aVItems[ 16 ]

   dbCloseAll()
   IF ! ClOpenFile( cDbfFile )
      RETU NIL
   ENDIF

   oApp():oClp   := TClipboard():New( , oApp():oWndMain )
   oApp():oClp:Empty()

   SELECT CL
   CL->( dbGoto( nClRecno ) )
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de claves' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )
   oApp():oDlg:NewMenu()

   ACTIVATE DIALOG oApp():oDlg NOWAIT  ;
      ON INIT oApp():oGrid:SetFocus()  ;
      VALID ( oApp():oGrid:nLen := 0, ;
      WritePProString( "Browse", "DbfFile", oApp():cDbfFile, oApp():cIniFile ), ;
      WritePProString( "Browse", "State", oApp():oGrid:SaveState(), oApp():cIniFile ), ;
      WritePProString( "Browse", "Order", LTrim( Str( Max( CL->( ordNumber() ), 1 ) ) ), oApp():cIniFile ), ;
      WritePProString( "Browse", "Recno", LTrim( Str( CL->( RecNo() ) ) ), oApp():cIniFile ), ;
      oApp():oVMenu:End(), oApp():oGrid:End(), oApp():oDlg := NIL, oApp():oGrid := NIL,  ;
      dbCloseArea(), FErase( oApp():cDbfFile + ".adi" ), .T. )

   RETURN NIL
// _____________________________________________________________________________//

FUNCTION ClNewFile()

   LOCAL lReturn := .F.
   LOCAL oDlg, aGet[ 4 ], oTitle
   LOCAL cNewFile  := Space( 80 )
   LOCAL cNewPwd1  := Space( 30 )
   LOCAL cNewPwd2  := Space( 30 )
   LOCAL lOk       := .T.
   LOCAL oPassFont := TFont():New( "Times New Roman", 0, -10,, .F.,,,, )

   DEFINE DIALOG oDlg RESOURCE 'PASSWD02_' + oApp():cLanguage;
      TITLE oApp():cAppName + oApp():cVersion
   oDlg:SetFont( oApp():oFont )

   // REDEFINE TITLE oTitle ID 100 OF oDlg NOBORDER SHADOW NOSHADOW ;
   // GRADIENT { { 1, RGB(30,30,30), RGB(30,30,30) } }

   // @ 10, 12 TITLETEXT OF oTitle TEXT "Indique el nombre y ubicación del fichero de claves a crear." FONT oApp():oFontBold COLOR CLR_WHITE
   // @ 32, 12 TITLETEXT OF oTitle TEXT "La extensión deberá ser .dat o quedar en blanco." FONT oApp():oFontBold COLOR CLR_WHITE

   REDEFINE SAY ID 20 OF oDlg
   REDEFINE SAY ID 21 OF Odlg
   REDEFINE SAY ID 22 OF Odlg
   REDEFINE SAY ID 23 OF Odlg
   REDEFINE SAY ID 24 OF Odlg

   REDEFINE GET aGet[ 1 ] VAR cNewFile ID 101 OF oDlg
   REDEFINE BUTTON aGet[ 2 ] ID 102 OF oDlg ;
      ACTION ( cNewFile := NIL,;
      cNewFile := cGetfile32( "*.dat", i18n( "Indique el nombre y ubicación del nuevo fichero de claves" ), 1, oApp():cDbfPath, .T., .T. ), ;
      aGet[ 1 ]:Refresh(), aGet[ 3 ]:SetFocus() )
   aGet[ 2 ]:cTooltip := i18n( "Nuevo fichero de claves" )
   REDEFINE GET aGet[ 3 ] VAR cNewPwd1 ID 103 OF oDlg FONT oPassFont ;
      VALID iif( Empty( cNewPwd1 ), ( MsgStop( "Es obligatorio escribir una contraseña." ), .F. ), .T. )
   REDEFINE GET aGet[ 4 ] VAR cNewPwd2 ID 104 OF oDlg FONT oPassFont ;
      VALID iif( RTrim( cNewPwd1 ) != RTrim( cNewPwd2 ), ( MsgStop( "Las contraseñas introducidas no coinciden." ), .F. ), .T. )

   REDEFINE BUTTON ID 400 OF oDlg ;
      ACTION ( lOk := .T., oDlg:End() )
   REDEFINE BUTTON ID 401 OF oDlg CANCEL ;
      ACTION ( lOk := .F., oDlg:End() )
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )
   IF lOk
      /*agrega la extencion DAT de ser necesario*/
      IF Empty( cFileExt( cNewFile ) )
         cNewFile += ".dat"
      ENDIF
      IF File( cNewFile )
         MsgStop( "No se puede sobreescribir un fichero existente." )
      ELSE
         dbCreate( cNewFile, { { "CLCONCEPTO", "C",  40,   0 },;
            { "CLUSUARIO", "C",  40,   0 },;
            { "CLCLAVE", "C",  20,   0 },;
            { "CLLONG", "C",   2,   0 },;
            { "CLMATERIA", "C",  20,   0 },;
            { "CLNOTAS", "C", 250,   0 },;
            { "CLINTERNET", "C",  60,   0 },;
            { "CLFTP", "C",  60,   0 },;
            { "CLEMAIL", "C",  60,   0 },;
            { "CLARCHIVO", "C",  80,   0 },;
            { "CLFCHADQ", "D",   8,   0 },;
            { "CLFCHCAD", "D",   8,   0 },;
            { "CLTIPO", "C",   1,   0 },;
            { "CLCRC", "C",   1,   0 } }, , .T. )
         AdsEnableEncryption( RTrim( cNewPwd1 ) )
         AdsEncryptTable()
         dbCloseArea()
         IF MsgYesNo( "Fichero de claves creado con éxito." + CRLF + "¿ Desea usar el nuevo fichero de claves ?" )
            // ClOpenFile(SubStr(cNewFile,1,len(cNewFile)-4), cNewPwd1)
            Claves( SubStr( cNewFile, 1, Len( cNewFile ) -4 ) )
         ENDIF
      ENDIF
   ENDIF
   oPassFont:End()

   RETURN NIL
// _____________________________________________________________________________//

FUNCTION ClOpenFile( cFile, cPassword )

   LOCAL lReturn := .F.
   LOCAL oDlg, aGet[ 3 ], oTitle
   LOCAL cGetFile  := Space( 80 )
   LOCAL cGetPwd   := Space( 30 )
   LOCAL lOk       := .T.
   LOCAL oPassFont := TFont():New( "Times New Roman", 0, -10,, .F.,,,, )

   IF oApp():oDlg != NIL
      MsgStop( "Debe cerrar el fichero actual para poder abrir otro." )
      RETU NIL
   ENDIF
   IF cFile != NIL
      cGetFile := PadR( cFile, 80, ' ' )
   ENDIF
   DEFINE DIALOG oDlg RESOURCE 'PASSWD01_' + oApp():cLanguage;
      TITLE oApp():cAppName + oApp():cVersion
   oDlg:SetFont( oApp():oFont )

   // REDEFINE TITLE oTitle TEXT "Selecciona el fichero de claves" ID 100 OF oDlg NOBORDER SHADOW NOSHADOW ;
   // GRADIENT { { 1, RGB(30,30,30), RGB(30,30,30) } }
   // @ 10, 12 TITLETEXT OF oTitle TEXT "Seleccione el fichero de claves a utilizar:" FONT oApp():oFontBold COLOR CLR_WHITE

   REDEFINE SAY ID 20 OF oDlg
   REDEFINE SAY ID 21 OF Odlg
   REDEFINE SAY ID 22 OF Odlg
   REDEFINE GET aGet[ 1 ] VAR cGetFile ID 101 OF oDlg
   REDEFINE BUTTON aGet[ 2 ] ID 102 OF oDlg ;
      ACTION ( cGetFile := NIL,;
      cGetFile := cGetfile32( "*.dat", i18n( "Seleccione el fichero de claves" ), 1, oApp():cDbfPath, .T., .T. ), ;
      aGet[ 1 ]:Refresh(), aGet[ 3 ]:SetFocus() )
   aGet[ 2 ]:cTooltip := i18n( "Seleccionar fichero de claves" )
   REDEFINE GET aGet[ 3 ] VAR cGetPwd ID 103 OF oDlg FONT oPassFont ;
      WHEN ! Empty( cGetFile ) ;
      VALID iif( Empty( cGetPwd ), ( MsgStop( "Es obligatorio escribir la contraseña." ), .F. ), .T. )

   REDEFINE BUTTON ID 400 OF oDlg ;
      ACTION ( lOk := .T., oDlg:End() )
   REDEFINE BUTTON ID 401 OF oDlg CANCEL ;
      ACTION ( lOk := .F., oDlg:End() )
   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter( oDlg, oApp():oWndMain ), iif( cFile != NIL, aGet[ 3 ]:Setfocus(), ) )
   IF lOk
      /*elimina la extencion DBF de ser necesario*/
      IF Upper( cFileExt( cGetFile ) ) == 'DAT'
         cGetFile := Left( cGetFile, Len( cGetFile ) -4 )
      ENDIF
      oApp():cDbfFile := RTrim( cGetFile )
      oApp():oWndMain:cTitle := oApp():cAppName + oApp():cVersion + " · " + oApp():cDbfFile + ".dat"
      IF oApp():oGrid != NIL
         oApp():oGrid:Hide()
         oApp():oGrid:Disable()
      ENDIF
      dbCloseAll()
      IF ClOpenNoIndex( oApp():cDbfFile, 'CL' )
         IF AdsEnableEncryption( RTrim( cGetPwd ) ) != 0
            MsgStop( "Contraseña errónea." )
         ELSE
            oApp():cDbfPwd  := RTrim( cGetPwd )
            ClIndex()
            dbSetIndex( oApp():cDbfFile + ".adi" )
            CL->( ordSetFocus( 1 ) )
            CL->( dbGoTop() )
            lReturn := .T.
         ENDIF
      ENDIF
   ENDIF
   oPassFont:End()

   RETURN lReturn
// -----------------------------------------------------------------------------//
FUNCTION ClPwdChange()

   LOCAL oDlg, oTitle, aGet[ 3 ], cPwd1, cPwd2, cPwd3, lOk
   LOCAL oPassFont := TFont():New( "Times New Roman", 0, -10,, .F.,,,, )

   DEFINE DIALOG oDlg RESOURCE 'PASSWD03_' + oApp():cLanguage;
      TITLE "Cambio de contraseña"
   oDlg:SetFont( oApp():oFont )

   // REDEFINE TITLE oTitle TEXT "Selecciona el fichero de claves" ID 100 OF oDlg NOBORDER SHADOW NOSHADOW ;
   // GRADIENT { { 1, RGB(30,30,30), RGB(30,30,30) } }

   // @ 10, 12 TITLETEXT OF oTitle TEXT "Cambio de contraseña." FONT oApp():oFontBold COLOR CLR_WHITE

   REDEFINE SAY ID 20 OF oDlg
   REDEFINE SAY ID 21 OF Odlg
   REDEFINE SAY ID 22 OF Odlg
   REDEFINE SAY ID 23 OF Odlg
   REDEFINE SAY ID 24 OF Odlg

   REDEFINE GET aGet[ 1 ] VAR cPwd1 ID 101 OF oDlg FONT oPassFont ;
      VALID iif( Empty( cPwd1 ), ( MsgStop( "Es obligatorio escribir la contraseña." ), .F. ), .T. )

   REDEFINE GET aGet[ 2 ] VAR cPwd2 ID 102 OF oDlg FONT oPassFont ;
      VALID iif( Empty( cPwd2 ), ( MsgStop( "Es obligatorio escribir la contraseña." ), .F. ), .T. )

   REDEFINE GET aGet[ 3 ] VAR cPwd3 ID 103 OF oDlg FONT oPassFont ;
      VALID iif( Empty( cPwd3 ), ( MsgStop( "Es obligatorio escribir la contraseña." ), .F. ), .T. )

   REDEFINE BUTTON ID 400 OF oDlg ;
      ACTION ( lOk := .T., oDlg:End() )
   REDEFINE BUTTON ID 401 OF oDlg CANCEL ;
      ACTION ( lOk := .F., oDlg:End() )
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )
   IF lOk
      IF AdsEnableEncryption( RTrim( cPwd1 ) ) != 0
         MsgStop( "Contraseña actual errónea." )
      ELSEIF RTrim( cPwd2 ) != RTrim( cPwd3 )
         MsgStop( "La nueva contraseña y su repetición no coinciden." + CRLF + "La contraseña no se ha modificado." )
      ELSE
         AdsDecryptTable()
         AdsEnableEncryption( RTrim( cPwd2 ) )
         AdsEncryptTable()
         MsgInfo( "Contraseña modificada correctamente." )
      ENDIF
   ENDIF
   oPassFont:End()

   RETURN NIL
// -----------------------------------------------------------------------------//
FUNCTION ClOpenNoIndex( cDbf, cAlias )

   IF File( cDbf + ".dat" )
      TRY
         USE &( cDbf + ".dat" ) ALIAS &( cAlias ) NEW
      CATCH
         msgStop( 'Ha sucedido un error al abrir el fichero de claves, o el fichero seleccionado no es un fichero de claves.' )
         RETURN .F.
      END
   ELSE
      MsgStop( i18n( "No se ha encontrado un archivo de datos - " + cDbf + "." ) + CRLF + ;
         i18N( "Por favor revise la configuración y reindexe los ficheros del programa." ) )
      RETURN .F.
   ENDIF

   RETURN .T.
// -----------------------------------------------------------------------------//

FUNCTION ClIndex()

   LOCAL aMaterias := {}
   LOCAL nAt
   FIELD clconcepto, clusuario, clclave, clmateria, clfchadq, clfchcad, mamateria

   PACK
   INDEX ON Upper( ClConcepto )  TAG concepto FOR ! Deleted() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
   INDEX ON Upper( ClUsuario )   TAG usuario  FOR ! Deleted() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
   INDEX ON Upper( ClClave )     TAG clave    FOR ! Deleted() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
   INDEX ON Upper( ClMateria )   TAG materia  FOR ! Deleted() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
   INDEX ON DToS( Clfchadq )   TAG fchadq   FOR ! Deleted() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
   INDEX ON DToS( Clfchcad )   TAG fchcad   FOR ! Deleted() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
   CL->( dbGoTop() )
   DO WHILE ! CL->( Eof() )
      nAt := AScan( aMaterias, {|a| a[ 1 ] == CL->ClMateria } )
      IF ! Empty( CL->ClMateria ) .AND. nAt == 0
         AAdd( aMaterias, { CL->ClMateria, 1 } )
      ELSEIF nAt != 0
         aMaterias[ nAt, 2 ] := aMaterias[ nAt, 2 ] + 1
      ENDIF
      CL->( dbSkip() )
   ENDDO
   oApp():aMaterias := aMaterias
   ASort( oApp():aMaterias,,, {| x, y| Upper( x[ 1 ] ) < Upper( y[ 1 ] ) } )
   // oAGet():lMa := .t.
   // oAGet():load()

   RETURN NIL

// _____________________________________________________________________________//
FUNCTION ClEdita( oGrid, lAppend )

   LOCAL oDlg, oRadio, oBtnAceptar, oBtnCancelar
   LOCAL lSave    := .F.
   LOCAL nRecPtr  := CL->( RecNo() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL bCl   := TRecord():new()
   LOCAL nClLong := GetPvProfString( "Config", "nLong", "12", oApp():cIniFile )
   LOCAL cGetFile
   LOCAL aGet[18 ]
   LOCAL aSay[19 ]
   LOCAL aBtn[7 ]
   LOCAL nAt

   /* ___ Fin de la definición de variables ___________________________________*/

   IF oApp():lGridHided
      MsgStop( i18n( "No se puede editar una clave con las claves ocultas." ) + CRLF + ;
         i18n( "Por favor, muestre las claves y vuelva a intentarlo." ) )
      RETURN NIL
   ENDIF
   IF lAppend
      CL->( dbAppend() )
      nRecAdd := CL->( RecNo() )
      REPLACE CL->Cllong WITH nClLong
      CL->( dbCommit() )
   ENDIF
   bCl:loadFromAlias( "CL" )
   bCL:nClLong := Val( Cl->Cllong )
   bCl:nClTipo  := iif( lAppend, 1, Val( Cl->ClTipo ) )

   DEFINE DIALOG oDlg RESOURCE 'CLAVE01_' + oApp():cLanguage ;
      TITLE iif( lAppend, ;
      i18n( "Introducción de una clave" ), ;
      i18n( "Modificación de una clave" ) )
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY aSay[ 01 ] ID 201 OF oDlg
   REDEFINE SAY aSay[ 02 ] ID 202 OF oDlg
   REDEFINE SAY aSay[ 03 ] ID 203 OF oDlg
   REDEFINE SAY aSay[ 04 ] ID 204 OF oDlg
   REDEFINE SAY aSay[ 05 ] ID 205 OF oDlg
   REDEFINE SAY aSay[ 06 ] ID 206 OF oDlg
   REDEFINE SAY aSay[ 07 ] ID 207 OF oDlg
   REDEFINE SAY aSay[ 08 ] ID 208 OF oDlg

   REDEFINE GET aGet[ 01 ] VAR bCl:ClConcepto  ID 101 OF oDlg ;
      VALID iif( Empty( bCl:ClConcepto ), MsgStop( i18n( "Es obligatorio introducir el nombre del servicio." ) ), .T. )

   REDEFINE GET aGet[ 02 ] VAR bCl:ClUsuario   ID 102 OF oDlg

   REDEFINE GET      aGet[ 03 ] ;
      VAR      bCl:nCllong ;
      ID       103 ;
      OF       oDlg ;
      PICTURE  '99' ;
      SPINNER  MIN 1 MAX 20

   aGet[ 03 ]:bLostFocus  := {|| ClChgClave( @bCl:nCllong, aGet ) }

   REDEFINE GET aGet[ 04 ] VAR bCl:ClClave  ID 104 OF oDlg ;
      PICTURE ( Replicate( "X", bCL:nCllong ) )
   REDEFINE BUTTON aBtn[ 1 ] ;
      ID 501 OF oDlg       ;
      ACTION      ( ClGenera( @bCl:ClClave, bCL:nCllong, .T. ), aGet[ 04 ]:refresh(), aGet[ 04 ]:SetFocus(), sysrefresh() )
   aBtn[ 1 ]:cTooltip := i18n( "Generar clave" )

   REDEFINE AUTOGET aGet[ 05 ] ;
      VAR bCl:ClMateria    ;
      DATASOURCE {}      ;
      FILTER MaListFilter( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 105   ;
      OF oDlg ;
      VALID ( MaClave( @bCl:ClMateria, aGet[ 05 ] ) ) ;
      GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ;
      GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ;
      LINECOLOR oApp():nClrHL ;
      ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aBtn[ 2 ] ;
      ID 502 OF oDlg       ;
      ACTION ( Materia( .T., @bCl:ClMateria, aGet[ 05 ], oApp():oGrid ), aGet[ 05 ]:refresh(), aGet[ 05 ]:SetFocus(), sysrefresh() )
   aBtn[ 2 ]:cTooltip := i18n( "Seleccionar materia" )

   REDEFINE GET aGet[ 06 ] VAR bCl:ClFchAdq   ID 106 OF oDlg
   REDEFINE BUTTON aBtn[ 3 ] ;
      ID 503 OF oDlg       ;
      ACTION ( SelecFecha( @bCl:ClFchAdq, aGet[ 06 ], oDlg, 200 ), aGet[ 06 ]:SetFocus(), SysRefresh() )
   aBtn[ 3 ]:cTooltip := i18n( "Seleccionar fecha" )

   REDEFINE GET aGet[ 07 ] VAR bCl:ClFchCad   ID 107 OF oDlg ;
      VALID ClFchValida( bCl:ClFchAdq, @bCl:ClFchCad, aGet[ 17 ] )
   REDEFINE BUTTON aBtn[ 4 ] ;
      ID 504 OF oDlg       ;
      ACTION ( SelecFecha( @bCl:ClFchCad, aGet[ 07 ], oDlg, 200 ), aGet[ 07 ]:SetFocus(), SysRefresh() )
   aBtn[ 4 ]:cTooltip := i18n( "Seleccionar fecha" )

   REDEFINE RADIO oRadio VAR bCl:nCltipo ID 301, 302, 303 OF oDlg

   REDEFINE SAY aSay[ 09 ] ID 209 OF oDlg
   REDEFINE SAY aSay[ 10 ] ID 210 OF oDlg
   REDEFINE SAY aSay[ 11 ] ID 211 OF oDlg

   REDEFINE GET aGet[ 08 ] VAR bCl:ClInternet ;
      ID 108 OF oDlg
   REDEFINE BUTTON aBtn[ 5 ] ID 505 OF oDlg ;
      ACTION ( GoWeb( RTrim( bCl:ClInternet ) ), aGet[ 08 ]:SetFocus(), sysrefresh() )
   aBtn[ 5 ]:cTooltip  := i18n( "Visitar sitio web" )

   REDEFINE GET aGet[ 09 ] VAR bCl:Clftp ;
      ID 109 OF oDlg

   REDEFINE GET aGet[ 10 ] VAR bCl:Clemail ;
      ID 110 OF oDlg

   REDEFINE BUTTON aBtn[ 6 ] ID 506 OF oDlg ;
      ACTION ( GoMail( RTrim( bCl:Clemail ) ), aGet[ 10 ]:SetFocus(), SysRefresh() )
   aBtn[ 6 ]:cTooltip := i18n( "Enviar e-mail" )

   REDEFINE SAY aSay[ 12 ] ID 212 OF oDlg

   REDEFINE GET aGet[ 11 ] VAR bCl:Clarchivo  ID 111 OF oDlg
   REDEFINE BUTTON aBtn[ 7 ] ID 507 OF oDlg ;
      ACTION ( cGetFile := NIL,;
      cGetFile := cGetfile32( "*.*", i18n( "Seleccione el fichero" ),,,, .T. ), ;
      bCl:ClArchivo := iif( !Empty( cGetFile ), cGetFile, bCl:ClArchivo ), ;
      aGet[ 11 ]:Refresh(), aGet[ 11 ]:SetFocus(), sysrefresh() )
   aBtn[ 7 ]:cTooltip := i18n( "Seleccionar archivo" )

   REDEFINE SAY aSay[ 13 ] ID 213 OF oDlg

   REDEFINE GET aGet[ 12 ] VAR bCl:ClNotas ;
      ID 112 MEMO OF oDlg

   /*___ dialogo principal _____________________________________________________*/

   REDEFINE BUTTON ID 400 OF oDlg       ;
      ACTION ( lSave := .T., oDlg:End() )
   REDEFINE BUTTOn ID 401 OF oDlg CANCEL;
      ACTION ( lSave := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter( oDlg, oApp():oWndMain ) )

   IF lSave
      IF lAppend
         CL->( dbGoto( nRecAdd ) )
      ELSE
         CL->( dbGoto( nRecPtr ) )
      ENDIF
      bCl:ClLong := Str( bCl:nCllong, 2 )
      bCl:ClTipo := Str( bCl:nClTipo, 1 )
      bCl:saveToAlias( 'CL' )
      CL->( dbCommit() )
      nRecPtr := nRecAdd
      nAt := AScan( oApp():aMaterias, {|a| a[ 1 ] == bCl:ClMateria } )
      IF nAt == 0
         AAdd( oApp():aMaterias, { CL->ClMateria, 1 } )
         ASort( oApp():aMaterias,,, {| x, y| Upper( x[ 1 ] ) < Upper( y[ 1 ] ) } )
      ELSE
         oApp():aMaterias[ nAt, 2 ] := oApp():aMaterias[ nAt, 2 ] + 1
      ENDIF
   ELSE
      IF lAppend
         /*___ no quiero salvar, deshago el append _____________________________*/
         CL->( dbGoto( nRecAdd ) )
         CL->( dbDelete() )
         CL->( dbGoto( nRecPtr ) )
      ENDIF
   ENDIF
   SELECT CL
   RefreshCont()
   oGrid:Refresh( .T. )
   oGrid:SetFocus()

   RETURN NIL

// _____________________________________________________________________________//
FUNCTION MaListFilter( aList, cData, oSelf )

   LOCAL aNewList := {}
   LOCAL i

   FOR i := 1 TO Len( oApp():aMaterias )
      // if cData == VK_SPACE
      // AAdd( aNewList, { oApp():amaterias[i] } )
      // else
      IF Upper( SubStr( oApp():amaterias[ i, 1 ], 1, Len( cData ) ) ) == Upper( cData )
         IF AScan( aNewList, {|a| a[ 1 ] == oApp():amaterias[ i, 1 ] } ) == 0
            AAdd( aNewList, { oApp():amaterias[ i, 1 ] } )
         ENDIF
      ENDIF
   NEXT

   RETURN aNewList
// -----------------------------------------------------------------------------//

STATIC FUNCTION ClChgClave( nCllong, aGet )

   LOCAL cTxt  := aGet[ 4 ]:GetText()

   cTxt        := SubStr( cTxt, 1, nCllong )
   WHILE Len( cTxt ) < nCllong
      cTxt     += Space( 1 )
   END
   aGet[ 4 ]:cText( cTxt )
   // Código de Manolo Calero Solís
   aGet[ 4 ]:cPicture  := Replicate( 'X', nClLong )
   aGet[ 4 ]:oGet:Assign()
   aGet[ 4 ]:oGet:Picture := Replicate( 'X', nClLong )
   aGet[ 4 ]:oGet:UpdateBuffer()

   RETURN NIL

// _____________________________________________________________________________//

FUNCTION ClBorra( oGrid, oSay )

   LOCAL nRecord := CL->( RecNo() )
   LOCAL nNext, nAt

   IF MsgYesNo( i18n( "¿ Está seguro de querer borrar esta clave ?" ) + CRLF + Trim( CL->ClConcepto ) )
      nAt := AScan( oApp():aMaterias, {|a| a[ 1 ] == CL->ClMateria } )
      oApp():aMaterias[ nAt, 2 ] := oApp():aMaterias[ nAt, 2 ] - 1
      CL->( dbSkip() )
      nNext := CL->( RecNo() )
      CL->( dbGoto( nRecord ) )
      CL->( dbDelete() )
      CL->( dbGoto( nNext ) )
      IF CL->( Eof() ) .OR. nNext == nRecord
         CL->( dbGoBottom() )
      ENDIF
   ENDIF
   RefreshCont()
   oGrid:Refresh( .T. )
   oGrid:SetFocus()

   RETURN NIL

// _____________________________________________________________________________//
FUNCTION ClImprime( oGrid )

   LOCAL oDlg, oFld, oCombo, oRadio, oLbx, oGet, oCol, oSay, oBtnDown, oBtnUp, oBtnShow, oBtnHide
   LOCAL oGet1
   LOCAL aCampos  := { "CLCONCEPTO", "CLUSUARIO", "CLCLAVE", "CLLONG", "CLNOTAS", ;
      "CLINTERNET", "CLFTP", "CLEMAIL", "CLARCHIVO", "CLFCHADQ", ;
      "CLFCHCAD", "CLMATERIA", "CLTIPO" }
   LOCAL aTitulos := { i18n( "Servicio" ), i18n( "Usuario" ), i18n( "Clave" ), i18n( "Longitud" ), i18n( "Notas" ), ;
      i18n( "Sitio web" ), i18n( "F.T.P." ), i18n( "e-mail" ), i18n( "Archivo" ), i18n( "Obtención" ), ;
      i18n( "Caducidad" ), i18n( "Materia" ), i18n( "Tipo" ) }
   LOCAL aWidth   := { 40, 40, 20, 2, 200, 60, 60, 60, 80, 8, 8, 20, 10 }
   LOCAL aShow    := { .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T. }
   LOCAL aPicture := { "CL01", "CL02", "CL03", "CL04", "CL05", "CL06", "CL07", "CL08", "CL09", "CL10", ;
      "CL11", "CL12", "CL13" }
   LOCAL aArray  := {}
   LOCAL nLen     := 13 // nº de campos a mostrar

   LOCAL cReport  := GetPvProfString( "Report", "ClReport", "", oApp():cIniFile )
   LOCAL cRptFont := GetPvProfString( "Report", "ClRptFont", "", oApp():cIniFile )
   LOCAL nRadio   := Val( GetPvProfString( "Report", "ClRadio", 1, oApp():cIniFile ) )
   LOCAL cTitulo1 := GetPvProfString( "Report", "ClTitulo1", Space( 50 ), oApp():cIniFile )
   LOCAL cTitulo2 := GetPvProfString( "Report", "ClTitulo2", Space( 50 ), oApp():cIniFile )

   LOCAL aoFont   := {, , }
   LOCAL aoSizes  := {, , }
   LOCAL aoEstilo := {, , }
   LOCAL acSizes  := { "10", "10", "10" }
   LOCAL acEstilo := { "Normal", "Normal", "Normal" }
   LOCAL acFont   := { "Courier New", "Courier New", "Courier New" }
   LOCAL aSizes   := { "08", "10", "12", "14", "16", "18", "20", "22", "24", "26", "28", "36", "48", "72" }
   LOCAL aEstilo  := { i18n( "Cursiva" ), i18n( "Negrita" ), i18n( "Negrita Cursiva" ),  i18n( "Normal" ) }
   LOCAL nDevice  := 0
   LOCAL aTipo    := { "Sitio web", "Acceso internet", "Archivo", "Otra clave" }
   LOCAL aMateria := {}
   LOCAL cMateria
   LOCAL nCounter := 0
   LOCAL nRec, nOrder
   LOCAL oFont1, oFont2, oFont3
   LOCAL i
   LOCAL cToken
   LOCAL aFont    := {}

   cTitulo1 := RTrim( cTitulo1 ) + Space( 50 -Len( cTitulo1 ) )
   cTitulo2 := RTrim( cTitulo2 ) + Space( 50 -Len( cTitulo2 ) )

   IF ! Empty( cReport )
      FOR i := 1 TO nLen
         cToken := StrToken( cReport, i, ";" )
         aCampos[ i ]  := StrToken( cToken, 1, ":" )
         aTitulos[ i ] := StrToken( cToken, 2, ":" )
         aWidth[ i ]   := Val( StrToken( cToken, 3, ":" ) )
         aShow[ i ]    := AllTrim( StrToken( cToken, 4, ":" ) ) == "S"
      NEXT
   ENDIF
   IF ! Empty( cRptFont )
      FOR i := 1 TO 3
         cToken := StrToken( cRptFont, i, ";" )
         acFont[ i ]   := StrToken( cToken, 1, ":" )
         acSizes[ i ]  := StrToken( cToken, 2, ":" )
         acEstilo[ i ] := StrToken( cToken, 3, ":" )
      NEXT
   ENDIF
	
   FOR i := 1 TO Len( oApp():aMaterias )
      AAdd( aMateria, oApp():aMaterias[ i, 1 ] )
   NEXT
	
   IF Len( aMateria ) > 0
      cMateria := aMateria[ 1 ]
   ELSE
      cMateria := Space( 20 )
   ENDIF

   aFont := aGetFont( oApp():oWndMain )

   DEFINE DIALOG oDlg RESOURCE 'INFORME1_' + oApp():cLanguage OF oApp():oWndMain ;
      TITLE i18n( "Informes de contraseñas" )
   oDlg:SetFont( oApp():oFont )

   REDEFINE FOLDER oFld ;
      ID 100 OF oDlg    ;
      ITEMS i18n( "&Tipo de informe" ), i18n( "&Selección de campos" ), i18n( "&Encabezado y tipografía" );
      DIALOGS 'INFORME1A_' + oApp():cLanguage, 'INFORME1B_' + oApp():cLanguage, 'INFORME1C_' + oApp():cLanguage ;
      OPTION 1

   REDEFINE RADIO oRadio VAR nRadio ID 300, 301, 302, 303, 304, 305, 306 OF oFld:aDialogs[ 1 ]

   REDEFINE COMBOBOX oCombo VAR cMateria  ;
      ID       200                        ;
      ITEMS    aMateria                   ;
      WHEN nRadio == 2                    ;
      OF       oFld:aDialogs[ 1 ]

   /* ___ 2º FOLDER ___________________________________________________________*/
   oLbx := TXBrowse():New( oFld:aDialogs[ 2 ] )

   FOR i := 1 TO nLen
      AAdd( aArray, { aShow[ i ], aTitulos[ i ], aWidth[ i ] } )
   NEXT

   oLbx:SetArray( aArray )

   oLbx:nMarqueeStyle       := MARQSTYLE_HIGHLWIN7
   oLbx:nColDividerStyle    := LINESTYLE_LIGHTGRAY
   oLbx:lColDividerComplete := .T.
   oLbx:lRecordSelector     := .F.
   oLbx:lHScroll     := .F.
   oLbx:nHeaderHeight       := 20
   oLbx:nRowHeight          := 20
   oLbx:lTransparent      := .F.
   oLbx:l2007       := .F.
   oLbx:nDataType     := 1 // array
   oLbx:bChange     := {|| oGet:Refresh() }
   oLbx:nStretchCol     := -1

   oLbx:aCols[ 1 ]:cHeader  := i18n( "Mostrar" )
   oLbx:aCols[ 1 ]:nWidth   := 44
   oLbx:aCols[ 1 ]:AddResource( "CHECK" )
   oLbx:aCols[ 1 ]:AddResource( " " )
   oLbx:aCols[ 1 ]:bBmpData := {|| if( aArray[ oLbx:nArrayAt, 1 ] == .T., 1, 2 ) }
   olbx:aCols[ 1 ]:bStrData := {|| NIL }

   oLbx:aCols[ 2 ]:cHeader  := i18n( "Columna" )
   oLbx:aCols[ 2 ]:nWidth   := 140

   oLbx:aCols[ 3 ]:cHeader  := i18n( "Ancho" )
   oLbx:aCols[ 3 ]:nWidth   := 100

   FOR i := 1 TO Len( oLbx:aCols )
      oCol := oLbx:aCols[ i ]
      oCol:bLDClickData  :=  {|| iif( aShow[ oLbx:nArrayAt ], oBtnHide:Click(), oBtnShow:Click() ) }
   NEXT
   oLbx:CreateFromResource( 200 )

   REDEFINE SAY oSay ID 210 OF oFld:aDialogs[ 2 ]
   REDEFINE GET oGet VAR aWidth[ oLbx:nArrayAt ] ;
      ID       211   ;
      SPINNER        ;
      MIN      1     ;
      MAX      99    ;
      PICTURE  "99"  ;
      VALID    aWidth[ oLbx:nArrayAt ] > 0 ;
      OF       oFld:aDialogs[ 2 ] ;
      ON CHANGE ( oLbx:aArrayData[ oLbx:nArrayAt, 3 ] := aWidth[ oLbx:nArrayAt ], oLbx:Refresh() )
   oGet:bLostFocus := {|| ( oLbx:aArrayData[ oLbx:nArrayAt, 3 ] := aWidth[ oLbx:nArrayAt ], oLbx:Refresh() ) }

   REDEFINE BUTTON oBtnUp        ;
      ID       201               ;
      OF       oFld:aDialogs[ 2 ]  ;
      WHEN oLbx:nArrayAt > 1          ;
      ACTION iif( oLbx:nArrayAt > 1, ;
      ( SwapUpArray( aShow, oLbx:nArrayAt ),;
      SwapUpArray( aTitulos, oLbx:nArrayAt ),;
      SwapUpArray( aCampos, oLbx:nArrayAt ),;
      SwapUpArray( aWidth, oLbx:nArrayAt ),;
      SwapUpArray( aPicture, oLbx:nArrayAt ),;
      SwapUpArray( oLbx:aArrayData, oLbx:nArrayAt ),;
      oLbx:nArrayAt- -,;
      oLbx:Refresh()                   ), ;
      MsgStop( "No se puede desplazar la columna." ) )

   REDEFINE BUTTON oBtnDown   ;
      ID    202               ;
      OF    oFld:aDialogs[ 2 ]  ;
      WHEN oLbx:nArrayAt < Len( aTitulos ) ;
      ACTION iif( oLbx:nArrayAt < Len( aTitulos ),  ;
      ( SwapDwArray( aShow, oLbx:nArrayAt ),;
      SwapDwArray( aTitulos, oLbx:nArrayAt ),;
      SwapDwArray( aCampos, oLbx:nArrayAt ),;
      SwapDwArray( aWidth, oLbx:nArrayAt ),;
      SwapDwArray( aPicture, oLbx:nArrayAt ),;
      SwapDwArray( oLbx:aArrayData, oLbx:nArrayAt ),;
      oLbx:nArrayAt+ +,;
      oLbx:Refresh()                   ), ;
      MsgStop( "No se puede desplazar la columna." ) )

   REDEFINE BUTTON oBtnShow   ;
      ID    203               ;
      OF    oFld:aDialogs[ 2 ]  ;
      WHEN ( ! aShow[ oLbx:nArrayAt ] ) ;
      ACTION ( aShow[ oLbx:nArrayAt ] := .T., ;
      oLbx:aArrayData[ oLbx:nArrayAt, 1 ] := .T., oLbx:Refresh(), ;
      oLbx:SetFocus(), oLbx:Refresh() )

   REDEFINE BUTTON oBtnHide   ;
      ID     204              ;
      OF     oFld:aDialogs[ 2 ] ;
      WHEN ( aShow[ oLbx:nArrayAt ] .AND. aScanN( aShow, .T. ) > 1 ) ;
      ACTION ( aShow[ oLbx:nArrayAt ] := .F., ;
      oLbx:aArrayData[ oLbx:nArrayAt, 1 ] := .F., oLbx:Refresh(), ;
      oLbx:SetFocus(), oLbx:Refresh() )

   REDEFINE SAY ID 100 OF oFld:aDialogs[ 3 ]
   REDEFINE SAY ID 101 OF oFld:aDialogs[ 3 ]
   REDEFINE SAY ID 102 OF oFld:aDialogs[ 3 ]
   REDEFINE GET oGet1 VAR cTitulo1 ;
      ID 200 OF oFld:aDialogs[ 3 ] UPDATE
   REDEFINE GET oGet1 VAR cTitulo2 ;
      ID 201 OF oFld:aDialogs[ 3 ] UPDATE

   REDEFINE SAY ID 211 OF oFld:aDialogs[ 3 ]
   REDEFINE SAY ID 212 OF oFld:aDialogs[ 3 ]
   REDEFINE COMBOBOX aoFont[ 1 ] VAR acFont[ 1 ] ;
      ID       213 ;
      ITEMS    aFont ;
      OF       oFld:aDialogs[ 3 ]

   REDEFINE COMBOBOX aoSizes[ 1 ] VAR acSizes[ 1 ] ;
      ID       214      ;
      ITEMS    aSizes   ;
      OF       oFld:aDialogs[ 3 ]

   REDEFINE COMBOBOX aoEstilo[ 1 ] VAR acEstilo[ 1 ] ;
      ID       215 ;
      ITEMS    aEstilo ;
      OF       oFld:aDialogs[ 3 ]

   REDEFINE SAY ID 216 OF oFld:aDialogs[ 3 ]
   REDEFINE COMBOBOX aoFont[ 2 ] VAR acFont[ 2 ] ;
      ID       217 ;
      ITEMS    aFont ;
      OF       oFld:aDialogs[ 3 ]

   REDEFINE COMBOBOX aoSizes[ 2 ] VAR acSizes[ 2 ] ;
      ID       218 ;
      ITEMS    aSizes ;
      OF       oFld:aDialogs[ 3 ]

   REDEFINE COMBOBOX aoEstilo[ 2 ] VAR acEstilo[ 2 ] ;
      ID       219 ;
      ITEMS    aEstilo ;
      OF       oFld:aDialogs[ 3 ]

   REDEFINE SAY ID 220 OF oFld:aDialogs[ 3 ]
   REDEFINE COMBOBOX aoFont[ 3 ] VAR acFont[ 3 ] ;
      ID       221 ;
      ITEMS    aFont ;
      OF       oFld:aDialogs[ 3 ]

   REDEFINE COMBOBOX aoSizes[ 3 ] VAR acSizes[ 3 ] ;
      ID       222 ;
      ITEMS    aSizes ;
      OF       oFld:aDialogs[ 3 ]

   REDEFINE COMBOBOX aoEstilo[ 3 ] VAR acEstilo[ 3 ] ;
      ID       223 ;
      ITEMS    aEstilo ;
      OF       oFld:aDialogs[ 3 ]

   REDEFINE BUTTON   ;
      ID       101   ;
      OF       oDlg  ;
      ACTION   ( nDevice := 1, oDlg:end( IDOK ) )

   REDEFINE BUTTON   ;
      ID       102   ;
      OF       oDlg  ;
      ACTION   ( nDevice := 2, oDlg:end( IDOK ) )

   REDEFINE BUTTON   ;
      ID       103   ;
      OF       oDlg  ;
      ACTION   oDlg:end( IDCANCEL )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   IF oDlg:nresult == IDOK
      nRec   := CL->( RecNo() )
      nOrder := CL->( ordNumber() )
      CL->( dbGoTop() )
      DO CASE
      CASE nRadio == 1
         nCounter := CL->( LastRec() )
      CASE nRadio == 2
         COUNT TO nCounter FOR RTrim( Cl->ClMateria ) == RTrim( cMateria )
      CASE nRadio == 3
         COUNT TO nCounter FOR Cl->ClTipo == '1'
      CASE nRadio == 4
         COUNT TO nCounter FOR Cl->ClTipo == '2'
      CASE nRadio == 5
         COUNT TO nCounter FOR Cl->ClTipo == '3'
      CASE nRadio == 6
         COUNT TO nCounter FOR ! Empty( Cl->ClNotas )
      CASE nRadio == 7
         COUNT TO nCounter FOR ! Empty( Cl->ClFchAdq ) .OR. ! Empty( Cl->ClFchCad )
      ENDCASE

      CL->( dbGoTop() )

      oFont1 := TFont():New( RTrim( acFont[ 1 ] ), 0, Val( acSizes[ 1 ] ),, ( i18n( "Negrita" ) $ acEstilo[ 1 ] ),,,, ( i18n( "Cursiva" ) $ acEstilo[ 1 ] ),,,,,,, )
      oFont2 := TFont():New( RTrim( acFont[ 2 ] ), 0, Val( acSizes[ 2 ] ),, ( i18n( "Negrita" ) $ acEstilo[ 2 ] ),,,, ( i18n( "Cursiva" ) $ acEstilo[ 2 ] ),,,,,,, )
      oFont3 := TFont():New( RTrim( acFont[ 3 ] ), 0, Val( acSizes[ 3 ] ),, ( i18n( "Negrita" ) $ acEstilo[ 3 ] ),,,, ( i18n( "Cursiva" ) $ acEstilo[ 3 ] ),,,,,,, )

      cTitulo1 := RTrim( cTitulo1 )
      cTitulo2 := RTrim( cTitulo2 )

      IF nDevice == 1
         REPORT oReport ;
            TITLE  " ", " ", cTitulo1, cTitulo2, " " CENTERED;
            FONT   oFont3, oFont2, oFont1 ;
            HEADER ' ', oApp():cAppName + oApp():cVersion;
            FOOTER ' ', "Fecha: " + DToC( Date() ) + "   Página.: " + Str( oReport:nPage, 3 ) ;
            CAPTION "LISTADO DE CONTRASEÑAS" PREVIEW
      ELSEIF nDevice == 2
         REPORT oReport ;
            TITLE  " ", " ", cTitulo1, cTitulo2, " " CENTERED;
            FONT   oFont3, oFont2, oFont1 ;
            HEADER ' ', oApp():cAppName + oApp():cVersion;
            FOOTER ' ', "Fecha: " + DToC( Date() ) + "   Página.: " + Str( oReport:nPage, 3 ) ;
            CAPTION "LISTADO DE CONTRASEÑAS" // PREVIEW
      ENDIF

      FOR i := 1 TO Len( aTitulos )
         IF aShow[ i ]
            IF aPicture[ i ] == "NO"
               RptAddColumn( { bTitulo( aTitulos, i ) },, { bCampo( aCampos, i ) }, aWidth[ i ], {}, {|| 1 }, .F.,,, .F., .F., )
            ELSEIF aPicture[ i ] == "CL01"
               COLUMN TITLE "Servicio" DATA Cl->Clconcepto SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL02"
               COLUMN TITLE "Usuario" DATA Cl->ClUsuario SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL03"
               COLUMN TITLE "Clave" DATA Cl->ClClave SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL04"
               COLUMN TITLE "Longitud" DATA Cl->ClLong SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL05"
               COLUMN TITLE "Notas" DATA Cl->ClNotas SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL06"
               COLUMN TITLE "Sitio web" DATA Cl->ClInternet SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL07"
               COLUMN TITLE "F.T.P." DATA Cl->ClFtp SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL08"
               COLUMN TITLE "E-mail" DATA Cl->ClEmail SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL09"
               COLUMN TITLE "Archivo" DATA Cl->ClArchivo SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL10"
               COLUMN TITLE "F. Adquisición" DATA Cl->ClFchAdq SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL11"
               COLUMN TITLE "F. Caducidad" DATA Cl->ClFchCad SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL12"
               COLUMN TITLE "Materia" DATA Cl->ClMateria SIZE aWidth[ i ] FONT 1
            ELSEIF aPicture[ i ] == "CL13"
               COLUMN TITLE "Categoria" DATA aTipo[ Max( 1, Val( CL->ClTipo ) ) ] SIZE aWidth[ i ] FONT 1
            ENDIF
         ENDIF
      NEXT
      END REPORT

      IF oReport:lCreated
         oReport:nTitleUpLine       := RPT_SINGLELINE
         oReport:nTitleDnLine       := RPT_SINGLELINE
         oReport:oTitle:aFont[ 3 ]    := {|| 3 }
         oReport:oTitle:aFont[ 4 ]    := {|| 2 }
         oReport:nTopMargin         := 0.1
         oReport:nDnMargin          := 0.1
         oReport:nLeftMargin        := 0.1
         oReport:nRightMargin       := 0.1
         oReport:oDevice:lPrvModal  := .T.
         oReport:Cargo      := 'claves.pdf'
      ENDIF

      DO CASE
      CASE nRadio == 1
         ACTIVATE REPORT oReport ;
            ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
            oReport:Say( 1, 'Contraseñas: ' + Tran( nCounter, '@E 999,999' ), 1 ), ;
            oReport:EndLine() )
      CASE nRadio == 2
         ACTIVATE REPORT oReport FOR RTrim( Cl->ClMateria ) == RTrim( cMateria ) ;
            ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
            oReport:Say( 1, 'Contraseñas: ' + Tran( nCounter, '@E 999,999' ), 1 ), ;
            oReport:EndLine() )
      CASE nRadio == 3
         ACTIVATE REPORT oReport FOR Cl->ClTipo == '1' ;
            ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
            oReport:Say( 1, 'Contraseñas: ' + Tran( nCounter, '@E 999,999' ), 1 ), ;
            oReport:EndLine() )
      CASE nRadio == 4
         ACTIVATE REPORT oReport FOR Cl->ClTipo == '2' ;
            ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
            oReport:Say( 1, 'Contraseñas: ' + Tran( nCounter, '@E 999,999' ), 1 ), ;
            oReport:EndLine() )
      CASE nRadio == 5
         ACTIVATE REPORT oReport FOR  Cl->ClTipo == '3' ;
            ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
            oReport:Say( 1, 'Contraseñas: ' + Tran( nCounter, '@E 999,999' ), 1 ), ;
            oReport:EndLine() )
      CASE nRadio == 6
         ACTIVATE REPORT oReport FOR ! Empty( CL->ClNotas );
            ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
            oReport:Say( 1, 'Contraseñas: ' + Tran( nCounter, '@E 999,999' ), 1 ), ;
            oReport:EndLine() )
      CASE nRadio == 7
         ACTIVATE REPORT oReport FOR ! Empty( CL->ClFchAdq ) .OR. ! Empty( CL->ClFchCad ) ;
            ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
            oReport:Say( 1, 'Contraseñas: ' + Tran( nCounter, '@E 999,999' ), 1 ), ;
            oReport:EndLine() )
      ENDCASE

      CL->( ordSetFocus( nOrder ) )
      CL->( dbGoto( nRec ) )

      oFont1:End()
      oFont2:End()
      oFont3:End()

      cReport := ""
      FOR i := 1 TO nLen
         cReport := cReport + aCampos[ i ] + ":"
         cReport := cReport + aTitulos[ i ] + ":"
         cReport := cReport + Str( aWidth[ i ], 2 ) + ":"
         cReport := cReport + iif( aShow[ i ], "S", "N" ) + ";"
      NEXT
      cRptFont := ""
      FOR i := 1 TO 3
         cRptFont := cRptFont + acFont[ i ] + ":"
         cRptFont := cRptFont + acSizes[ i ] + ":"
         cRptFont := cRptFont + acEstilo[ i ] + ";"
      NEXT
      WritePProString( "Report", "ClReport", cReport, oApp():cIniFile )
      WritePProString( "Report", "ClRptFont", cRptFont, oApp():cIniFile )
      WritePProString( "Report", "ClRadio", LTrim( Str( nRadio ) ), oApp():cIniFile )
      WritePProString( "Report", "ClTitulo1", cTitulo1, oApp():cIniFile )
      WritePProString( "Report", "ClTitulo2", cTitulo2, oApp():cIniFile )
   ENDIF

   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
// _____________________________________________________________________________//

FUNCTION bTitulo( aTitulos, nFor )
   RETURN {|| aTitulos[ nFor ] }

FUNCTION bCampo( aCampos, nFor )
   RETURN ( FieldWBlock( aCampos[ nFor ], Select() ) )

FUNCTION bPicture( aPicture, nFor )
   RETURN aPicture[ nFor ]

FUNCTION bArray( aArray, aCampos, nFor )

   LOCAL nIndex

   nIndex := Eval( bCampo( aCampos, nFor ) )

   RETURN aArray[ Val( nIndex ) ]
// _____________________________________________________________________________//

FUNCTION ClTecla( nKey, oGrid, oSay )

   DO CASE
   CASE nKey == VK_RETURN
      ClEdita( oGrid, .F., oSay )
   CASE nKey == VK_INSERT
      ClEdita( oGrid, .T., oSay )
   CASE nKey == VK_DELETE
      ClBorra( oGrid, oSay )
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         nKey := nKey - 48
      ENDIF
      IF nkey >= 48 .AND. nkey <= 90
         ClBusca( ogrid, Chr( nkey ) )
      ENDIF
   ENDCASE

   RETURN NIL

// _____________________________________________________________________________//

FUNCTION ClGenera( cClave, nLong, lFromUser )

   LOCAL cChar := '0123456789qwertyuiopñlkjhgfdsazxcvbnmMNBVCXZASDFGHJKLÑPOIUYTREWQ'
   LOCAL cNClave
   LOCAL i, n

   IF ! Empty( RTrim( cClave ) )
      IF ! MsgYesNo( i18n( "El servicio ya tiene una clave. ¿ Desea generar una nueva ?" ) )
         RETU NIL
      ENDIF
   ENDIF
   cNClave := ''
   FOR i := 1 TO nLong
      n := FT_RAND( 64 )
      cNClave := cNClave + SubStr( cChar, n, 1 )
   NEXT
   IF lFromUser
      IF MsgYesNo( i18n( "La nueva clave es" ) + " " + cNClave + CRLF + ;
            i18n( "¿ Desea aceptar la nueva clave ?" ) )
         cClave := cNClave
      ENDIF
   ENDIF

   RETURN NIL

// _____________________________________________________________________________//

FUNCTION ft_rand( nMax )

   // sacada de NanLib 3.05
   STATIC nSeed
   LOCAL m := 100000000
   LOCAL b := 31415621
   nSeed := iif( nSeed == NIL, Seconds(), nSeed )   // init_seed()

   RETURN ( nMax * ( ( nSeed := Mod( nSeed * b + 1, m ) ) / m ) )

// _____________________________________________________________________________//

FUNCTION ClBusca( oGrid, cChr )

   LOCAL nOrder    := CL->( ordNumber() )
   LOCAL nRecno    := CL->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL cConcepto := Space( 40 )
   LOCAL cUsuario  := Space( 20 )
   LOCAL dFecha    := CToD( '' )
   LOCAL lSeek     := .F.
   LOCAL lFecha    := .F.
   LOCAL lRet   := .F.

   IF oApp():lGridHided
      MsgStop( i18n( "No se puede realizar búsquedas de claves con las claves ocultas." ) + CRLF + ;
         i18n( "Por favor, muestre las claves y vuelva a intentarlo." ) )
      RETU NIL
   ENDIF

   DEFINE DIALOG oDlg RESOURCE 'DlgBusca' ;
      TITLE i18n( "Búsqueda de claves" )
   oDlg:SetFont( oApp():oFont )

   IF nOrder == 1
      REDEFINE SAY PROMPT i18n( "Introduzca el servicio" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Servicio" ) + ":" ID 21 OF Odlg
      cGet     := cConcepto
   ELSEIF nOrder == 2
      REDEFINE SAY PROMPT i18n( "Introduzca el nombre de usuario" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Usuario" ) + ":" ID 21 OF Odlg
      cGet     := cUsuario
   ELSEIF nOrder == 3
      REDEFINE SAY PROMPT i18n( "Introduzca la clave" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "clave" ) + ":" ID 21 OF Odlg
      cGet     := cUsuario
   ELSEIF nOrder == 4
      REDEFINE SAY PROMPT i18n( "Introduzca la fecha de obtención" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Fecha de obtención" ) + ":" ID 21 OF Odlg
      cGet   := dFecha
      lFecha := .T.
   ELSEIF nOrder == 5
      REDEFINE SAY PROMPT i18n( "Introduzca la fecha de caducidad" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Fecha de caducidad" ) + ":" ID 21 OF Odlg
      cGet   := dFecha
      lFecha := .T.
   ELSEIF nOrder == 6
      REDEFINE SAY PROMPT i18n( "Introduzca la materia" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Materia" ) + ":" ID 21 OF Odlg
      cGet   := cUsuario
      lFecha := .F.
   ELSE
      CL->( ordSetFocus( 1 ) )
      nOrder   := 1
      REDEFINE SAY PROMPT i18n( "Introduzca el servicio" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Servicio" ) + ":" ID 21 OF Odlg
      cGet     := cConcepto
      lFecha   := .F.
   ENDIF

   /*__ si he pasado un caracter lo meto en la cadena a buscar ________________*/
   IF cChr != NIL
      IF ! lFecha
         cGet := cChr + SubStr( cGet, 1, Len( cGet ) -1 )
      ELSE
         cGet := CToD( cChr + ' -  -    ' )
      ENDIF
   ENDIF

   REDEFINE GET oGet VAR cGet ID 101 OF oDlg
   IF cChr != NIL
      oGet:bGotFocus := {|| ( oGet:SetColor( CLR_BLACK, RGB( 255, 255, 127 ) ), oGet:SetPos( 2 ) ) }
   ENDIF

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION ( lSeek := .T., oDlg:End() )
   REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
      PROMPT i18n( "&Cancelar" )  ;
      ACTION ( lRet := .F., oDlg:End() )

   sysrefresh()

   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter( oDlg, oApp():oWndMain ) )// , IIF(cChr!=NIL,oGet:SetPos(2),), oGet:Refresh() )

   IF lSeek
      IF ! lFecha
         cGet := RTrim( Upper( cGet ) )
      ELSE
         cGet := DToS( cGet )
      ENDIF
      IF ! CL->( dbSeek( cGet, .T. ) )
         MsgAlert( i18n( "No encuentro esa clave." ) )
         CL->( dbGoto( nRecno ) )
      ENDIF
   ENDIF
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL

// _____________________________________________________________________________//

FUNCTION ClFchValida( dClFchAdq, dClFchCad, oGet )

   LOCAL lRet := .F.

   IF dClFchAdq == CToD( '' )
      lRet := .T.
   ELSEIF dClFchCad == CToD( '' )
      lRet := .T.
   ELSEIF dClFchAdq > dClFchCad
      MsgStop( i18n( 'La fecha de caducidad no puede ser anterior a la de obtención.' ) )
      lRet := .F.
   ELSE
      lRet := .T.
   ENDIF

   RETURN lRet

// _____________________________________________________________________________//
