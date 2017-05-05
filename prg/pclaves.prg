#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "ttitle.ch"
#include "AutoGet.ch"

static oReport
//_____________________________________________________________________________//

function Claves(cDbfFile)
   local oBar
   local oBmp
   local oCol
   local cClState := GetPvProfString("Browse", "State","", oApp():cIniFile)
   local nClOrder := VAL(GetPvProfString("Browse", "Order","1", oApp():cIniFile))
   local nClRecno := VAL(GetPvProfString("Browse", "Recno","1", oApp():cIniFile))
   local nSplit   := 105 
   local oCont
   local i
   local aTipo    := {i18n("Sitio web"), i18n("Archivo"), i18n("Otro")}
   local aVItems[16]

	DbCloseAll()
	if ! ClOpenFile(cDbfFile)
		retu nil
	endif

   oApp():oClp   := TClipboard():New( , oApp():oWndMain )
   oApp():oClp:Empty()

   SELECT CL
	CL->(DbGoTo(nClRecno))
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de claves')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )
   oApp():oDlg:NewMenu()

   ACTIVATE DIALOG oApp():oDlg NOWAIT  ;
      ON INIT oApp():oGrid:SetFocus()  ;
      VALID ( oApp():oGrid:nLen := 0 , ;
				  WritePProString("Browse","DbfFile",oApp():cDbfFile,oApp():cIniFile),;
              WritePProString("Browse","State",oApp():oGrid:SaveState(),oApp():cIniFile),;
              WritePProString("Browse","Order",Ltrim(Str(MAX(CL->(OrdNumber()),1))),oApp():cIniFile),;
              WritePProString("Browse","Recno",Ltrim(Str(CL->(Recno()))),oApp():cIniFile),;
              oApp():oVMenu:End(),oApp():oGrid:End(), oApp():oDlg := NIL, oApp():oGrid := NIL,  ;
              DbCloseArea(), FErase(oApp():cDbfFile+".adi"), .t. )
return nil
//_____________________________________________________________________________//

function ClNewFile()
	local lReturn := .f.
	local oDlg, aGet[4], oTitle
   local cNewFile  := space(80)
	local cNewPwd1  := space(30)
	local cNewPwd2  := space(30)
   local lOk       := .t.
   local oPassFont := TFont():New("Times New Roman",0,-10,,.f.,,,,)

   DEFINE DIALOG oDlg RESOURCE 'PASSWD02_'+oApp():cLanguage;
      TITLE oApp():cAppName+oApp():cVersion	 	
   oDlg:SetFont(oApp():oFont)

   //REDEFINE TITLE oTitle ID 100 OF oDlg NOBORDER SHADOW NOSHADOW ; 
	//	GRADIENT { { 1, RGB(30,30,30), RGB(30,30,30) } }

	//@ 10, 12 TITLETEXT OF oTitle TEXT "Indique el nombre y ubicación del fichero de claves a crear." FONT oApp():oFontBold COLOR CLR_WHITE
	//@ 32, 12 TITLETEXT OF oTitle TEXT "La extensión deberá ser .dat o quedar en blanco." FONT oApp():oFontBold COLOR CLR_WHITE

	REDEFINE SAY ID 20 OF oDlg
   REDEFINE SAY ID 21 OF Odlg
   REDEFINE SAY ID 22 OF Odlg
	REDEFINE SAY ID 23 OF Odlg
	REDEFINE SAY ID 24 OF Odlg

   REDEFINE GET aGet[1] VAR cNewFile ID 101 OF oDlg
   REDEFINE BUTTON aGet[2] ID 102 OF oDlg ;
      ACTION ( cNewFile := NIL ,;
               cNewFile := cGetfile32("*.dat", i18n( "Indique el nombre y ubicación del nuevo fichero de claves" ),1,oApp():cDbfPath,.t.,.t.),;
               aGet[1]:Refresh(), aGet[3]:SetFocus() )
   aGet[2]:cTooltip := i18n( "Nuevo fichero de claves" )
	REDEFINE GET aGet[3] VAR cNewPwd1 ID 103 OF oDlg FONT oPassFont ;
		VALID iif(Empty(cNewPwd1),(MsgStop("Es obligatorio escribir una contraseña."),.f.),.t.)
	REDEFINE GET aGet[4] VAR cNewPwd2 ID 104 OF oDlg FONT oPassFont ;
		VALID iif(Rtrim(cNewPwd1)!= Rtrim(cNewPwd2),(MsgStop("Las contraseñas introducidas no coinciden."),.f.),.t.)

   REDEFINE BUTTON ID 400 OF oDlg ;
      ACTION (lOk := .t., oDlg:End())
   REDEFINE BUTTON ID 401 OF oDlg CANCEL ;
      ACTION (lOk := .f., oDlg:End())
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)
	if lOk
	   /*agrega la extencion DAT de ser necesario*/
	   if empty( cFileExt( cNewFile ) )
	      cNewFile += ".dat"
	   endif
		if file(cNewFile)
			MsgStop("No se puede sobreescribir un fichero existente.")
		else
		   DBCREATE(cNewFile, {{"CLCONCEPTO"  , "C",  40,   0} ,;
		                    {"CLUSUARIO"   , "C",  40,   0} ,;
		                    {"CLCLAVE"     , "C",  20,   0} ,;
		                    {"CLLONG"      , "C",   2,   0} ,;
		                    {"CLMATERIA"   , "C",  20,   0} ,;
		                    {"CLNOTAS"     , "C", 250,   0} ,;
		                    {"CLINTERNET"  , "C",  60,   0} ,;
		                    {"CLFTP"       , "C",  60,   0} ,;
		                    {"CLEMAIL"     , "C",  60,   0} ,;
		                    {"CLARCHIVO"   , "C",  80,   0} ,;
		                    {"CLFCHADQ"    , "D",   8,   0} ,;
		                    {"CLFCHCAD"    , "D",   8,   0} ,;
		                    {"CLTIPO"      , "C",   1,   0} ,;
		                    {"CLCRC"       , "C",   1,   0}}, , .t.)
			AdsEnableEncryption(Rtrim(cNewPwd1))
			AdsEncryptTable()
			DbCloseArea()
			if MsgYesNo("Fichero de claves creado con éxito."+CRLF+"¿ Desea usar el nuevo fichero de claves ?")
				// ClOpenFile(SubStr(cNewFile,1,len(cNewFile)-4), cNewPwd1)
				Claves(SubStr(cNewFile,1,len(cNewFile)-4))
			endif
		endif
	endif
   oPassFont:End()
return nil
//_____________________________________________________________________________//

function ClOpenFile(cFile, cPassword)
	local lReturn := .f.
	local oDlg, aGet[3], oTitle
   local cGetFile  := space(80)
	local cGetPwd   := space(30)
   local lOk       := .t.
   local oPassFont := TFont():New("Times New Roman",0,-10,,.f.,,,,)
	if oApp():oDlg != NIL
		MsgStop("Debe cerrar el fichero actual para poder abrir otro.")
		retu nil
	endif
	if cFile != NIL
   	cGetFile := PadR(cFile, 80, ' ')
	endif
   DEFINE DIALOG oDlg RESOURCE 'PASSWD01_'+oApp():cLanguage;
      TITLE oApp():cAppName+oApp():cVersion	 	
	oDlg:SetFont(oApp():oFont)

   //REDEFINE TITLE oTitle TEXT "Selecciona el fichero de claves" ID 100 OF oDlg NOBORDER SHADOW NOSHADOW ; 
	//	GRADIENT { { 1, RGB(30,30,30), RGB(30,30,30) } }
	//@ 10, 12 TITLETEXT OF oTitle TEXT "Seleccione el fichero de claves a utilizar:" FONT oApp():oFontBold COLOR CLR_WHITE

	REDEFINE SAY ID 20 OF oDlg
   REDEFINE SAY ID 21 OF Odlg
	REDEFINE SAY ID 22 OF Odlg
   REDEFINE GET aGet[1] VAR cGetFile ID 101 OF oDlg
   REDEFINE BUTTON aGet[2] ID 102 OF oDlg ;
      ACTION ( cGetFile := NIL ,;
               cGetFile := cGetfile32("*.dat", i18n( "Seleccione el fichero de claves" ),1,oApp():cDbfPath,.t.,.t.),;
               aGet[1]:Refresh(), aGet[3]:SetFocus() )
   aGet[2]:cTooltip := i18n( "Seleccionar fichero de claves" )
	REDEFINE GET aGet[3] VAR cGetPwd ID 103 OF oDlg FONT oPassFont ;
		WHEN ! Empty(cGetFile) ;
		VALID iif(Empty(cGetPwd),(MsgStop("Es obligatorio escribir la contraseña."),.f.),.t.)

   REDEFINE BUTTON ID 400 OF oDlg ;
      ACTION (lOk := .t., oDlg:End())
   REDEFINE BUTTON ID 401 OF oDlg CANCEL ;
      ACTION (lOk := .f., oDlg:End())
   ACTIVATE DIALOG oDlg ;
      ON INIT (DlgCenter(oDlg,oApp():oWndMain), iif(cFile!=NIL,aGet[3]:Setfocus(),))
	if lOk
	   /*elimina la extencion DBF de ser necesario*/
	   if Upper(cFileExt(cGetFile)) == 'DAT'
	      cGetFile := Left(cGetFile, Len(cGetFile)-4)
	   endif
		oApp():cDbfFile := Rtrim(cGetFile)
		oApp():oWndMain:cTitle := oApp():cAppName+oApp():cVersion+" · "+oApp():cDbfFile+".dat"
		if oApp():oGrid != NIL
			oApp():oGrid:Hide()
			oApp():oGrid:Disable()
		endif
		DbCloseAll()
		if ClOpenNoIndex(oApp():cDbfFile,'CL')
			if AdsEnableEncryption(Rtrim(cGetPwd)) != 0
				MsgStop("Contraseña errónea.")
			else
				oApp():cDbfPwd  := Rtrim(cGetPwd)
				ClIndex()
				DbSetIndex(oApp():cDbfFile+".adi")
				CL->(OrdSetFocus(1))
				CL->(DbGoTop())
				lReturn := .t.
			endif
		endif
	endif
   oPassFont:End()
return lReturn
//-----------------------------------------------------------------------------//
function ClPwdChange()
	local oDlg, oTitle, aGet[3], cPwd1, cPwd2, cPwd3, lOk
	local oPassFont := TFont():New("Times New Roman",0,-10,,.f.,,,,)

	DEFINE DIALOG oDlg RESOURCE 'PASSWD03_'+oApp():cLanguage;
      TITLE "Cambio de contraseña"	
	oDlg:SetFont(oApp():oFont)

   //REDEFINE TITLE oTitle TEXT "Selecciona el fichero de claves" ID 100 OF oDlg NOBORDER SHADOW NOSHADOW ; 
	//	GRADIENT { { 1, RGB(30,30,30), RGB(30,30,30) } }

	//@ 10, 12 TITLETEXT OF oTitle TEXT "Cambio de contraseña." FONT oApp():oFontBold COLOR CLR_WHITE

	REDEFINE SAY ID 20 OF oDlg
   REDEFINE SAY ID 21 OF Odlg
	REDEFINE SAY ID 22 OF Odlg
	REDEFINE SAY ID 23 OF Odlg
	REDEFINE SAY ID 24 OF Odlg

	REDEFINE GET aGet[1] VAR cPwd1 ID 101 OF oDlg FONT oPassFont ;
		VALID iif(Empty(cPwd1),(MsgStop("Es obligatorio escribir la contraseña."),.f.),.t.)

	REDEFINE GET aGet[2] VAR cPwd2 ID 102 OF oDlg FONT oPassFont ;
		VALID iif(Empty(cPwd2),(MsgStop("Es obligatorio escribir la contraseña."),.f.),.t.)

	REDEFINE GET aGet[3] VAR cPwd3 ID 103 OF oDlg FONT oPassFont ;
		VALID iif(Empty(cPwd3),(MsgStop("Es obligatorio escribir la contraseña."),.f.),.t.)

   REDEFINE BUTTON ID 400 OF oDlg ;
      ACTION (lOk := .t., oDlg:End())
   REDEFINE BUTTON ID 401 OF oDlg CANCEL ;
      ACTION (lOk := .f., oDlg:End())
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)
	if lOk
		if AdsEnableEncryption(Rtrim(cPwd1)) != 0
			MsgStop("Contraseña actual errónea.")
		elseif rtrim(cPwd2) != rtrim(cPwd3)
			MsgStop("La nueva contraseña y su repetición no coinciden."+CRLF+"La contraseña no se ha modificado.")
		else
		  	AdsDecryptTable()
			AdsEnableEncryption(rtrim(cPwd2))
			AdsEncryptTable()
			MsgInfo("Contraseña modificada correctamente.")
		endif
	endif
   oPassFont:End()
return nil
//-----------------------------------------------------------------------------//
function ClOpenNoIndex(cDbf,cAlias)
   if file( cDbf + ".dat" )
		try
      	USE &(cDbf+".dat") ALIAS &(cAlias) NEW
		catch
			msgStop('Ha sucedido un error al abrir el fichero de claves, o el fichero seleccionado no es un fichero de claves.')
      	return .f.
		end
   else
      MsgStop( i18n( "No se ha encontrado un archivo de datos - "+cDbf+"." ) + CRLF + ;
               i18N( "Por favor revise la configuración y reindexe los ficheros del programa." ) )
      return .f.
   endif
return .t.
//-----------------------------------------------------------------------------//

function ClIndex()
   local aMaterias := {}
	local nAt
	field clconcepto, clusuario, clclave, clmateria, clfchadq, clfchcad, mamateria

	Pack
   INDEX ON Upper(ClConcepto)  TAG concepto FOR ! DELETED() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
   INDEX ON Upper(ClUsuario)   TAG usuario  FOR ! DELETED() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
   INDEX ON Upper(ClClave)     TAG clave    FOR ! DELETED() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
   INDEX ON Upper(ClMateria) 	 TAG materia  FOR ! DELETED() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
   INDEX ON dtos(Clfchadq) 	 TAG fchadq   FOR ! DELETED() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
   INDEX ON dtos(Clfchcad) 	 TAG fchcad   FOR ! DELETED() // EVAL (oProgress:SetPos(nProgress++),SysRefresh()) EVERY 1
	CL->(DbGoTop())
	do while ! CL->(Eof())
		nAt := AScan(aMaterias, { |a| a[1] == CL->ClMateria })
		if ! Empty(CL->ClMateria) .and. nAt == 0
			AAdd(aMaterias, { CL->ClMateria, 1 })
		elseif nAt != 0
			aMaterias[nAt, 2] := aMaterias[nAt, 2] + 1 
		endif
		CL->(DbSkip())
	enddo
	oApp():aMaterias := aMaterias
	ASort(oApp():aMaterias,,, {|x,y| upper(x[1]) < upper(y[1]) } )
	//oAGet():lMa := .t.
	//oAGet():load()
return nil

//_____________________________________________________________________________//
function ClEdita( oGrid, lAppend )
   local oDlg, oRadio, oBtnAceptar, oBtnCancelar
   local lSave    := .f.
   local nRecPtr  := CL->( RecNo() )
   local nRecAdd
   local lDuplicado
   local cClconcepto, cClusuario, cClclave, cClMateria, cClnotas, cClinternet,;
         cClftp, cClemail, cClarchivo, dClfchadq, dClfchcad, cClTipo
	local nClLong := GetPvProfString("Config", "nLong", "12", oApp():cIniFile)
	local cGetFile
   local aGet [18]
   local aSay [19]
   local aBtn [7]
	local nAt
   /* ___ Fin de la definición de variables ___________________________________*/

   if oApp():lGridHided
      MsgStop( i18n( "No se puede editar una clave con las claves ocultas." ) + CRLF + ;
              i18n( "Por favor, muestre las claves y vuelva a intentarlo." ) )
      return NIL
   endif
   if lAppend
      CL->(DbAppend())
      nRecAdd := CL->(RecNo())
      replace CL->Cllong with nClLong
      CL->(DbCommit())
   endif

   cClconcepto := iif(lAppend, CL->ClConcepto, Cl->Clconcepto)
   cClusuario  := iif(lAppend, CL->Clusuario, Cl->Clusuario)
   cClclave    := iif(lAppend, CL->ClClave, Cl->Clclave)
   cClMateria  := iif(lAppend, CL->ClMateria, Cl->ClMateria)
   nClLong     := VAL(Cl->Cllong)
   cClnotas    := iif(lAppend, CL->ClNotas, Cl->Clnotas)
   cClinternet := iif(lAppend, CL->ClInternet, Cl->Clinternet)
   cClftp      := iif(lAppend, CL->ClFtp, Cl->Clftp)
   cClemail    := iif(lAppend, CL->ClEmail, Cl->Clemail)
   cClarchivo  := iif(lAppend, CL->ClArchivo, CL->Clarchivo)
   dClfchadq   := iif(lAppend, CL->ClFchAdq, Cl->Clfchadq)
   dClfchcad   := iif(lAppend, CL->ClFchCad, Cl->Clfchcad)
   cClTipo     := iif(lAppend,1,VAL(Cl->ClTipo))

   DEFINE DIALOG oDlg RESOURCE 'CLAVE01_'+oApp():cLanguage ;
      TITLE iif( lAppend,;
                 i18n( "Introducción de una clave" ) , ;
                 i18n( "Modificación de una clave" ) ) 
	oDlg:SetFont(oApp():oFont)

   REDEFINE SAY aSay[01] ID 201 OF oDlg
   REDEFINE SAY aSay[02] ID 202 OF oDlg
   REDEFINE SAY aSay[03] ID 203 OF oDlg
   REDEFINE SAY aSay[04] ID 204 OF oDlg
   REDEFINE SAY aSay[05] ID 205 OF oDlg
   REDEFINE SAY aSay[06] ID 206 OF oDlg
   REDEFINE SAY aSay[07] ID 207 OF oDlg
   REDEFINE SAY aSay[08] ID 208 OF oDlg

   REDEFINE GET aGet[01] VAR cClConcepto  ID 101 OF oDlg ;
      VALID IIF( empty(cClConcepto), MsgStop(i18n( "Es obligatorio introducir el nombre del servicio." )), .t. )

   REDEFINE GET aGet[02] VAR cClUsuario   ID 102 OF oDlg

   REDEFINE GET      aGet[03] ;
            VAR      nCllong ;
            ID       103 ;
            OF       oDlg ;
            PICTURE  '99' ;
            SPINNER  MIN 1 MAX 20

   aGet[03]:bLostFocus  := {|| ClChgClave( @nCllong, aGet ) }

   REDEFINE GET aGet[04] VAR cClClave  ID 104 OF oDlg ;
      PICTURE ( Replicate( "X", nCllong ) )
   REDEFINE BUTTON aBtn[1] ;
      ID 501 OF oDlg       ;
      ACTION      ( ClGenera(@cClClave,nCllong,.t.), aGet[04]:refresh(), aGet[04]:SetFocus(), sysrefresh() )
   aBtn[1]:cTooltip := i18n( "Generar clave" )

   REDEFINE AUTOGET aGet[05] ;
      VAR cClMateria 		   ;
      DATASOURCE {}						;
		FILTER MaListFilter( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
      ID 105			;
      OF oDlg ;
      VALID ( MaClave( @cClMateria, aGet[05] ) ) ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
	   GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK
	// aGet[5]:bKeyDown = {|nKey| IIF( nKey == VK_SPACE, ShowCalculator( oGet ), .T. ) }

   REDEFINE BUTTON aBtn[2] ;
      ID 502 OF oDlg       ;
      ACTION ( Materia(.t.,@cClMateria,aGet[05],oApp():oGrid), aGet[05]:refresh(), aGet[05]:SetFocus(), sysrefresh() )
   aBtn[2]:cTooltip := i18n( "Seleccionar materia" )

   REDEFINE GET aGet[06] VAR dClFchAdq   ID 106 OF oDlg
   REDEFINE BUTTON aBtn[3] ;
      ID 503 OF oDlg       ;
      ACTION ( SelecFecha(@dClFchAdq, aGet[06], oDlg, 200), aGet[06]:SetFocus(), SysRefresh() )
   aBtn[3]:cTooltip := i18n( "Seleccionar fecha" )

   REDEFINE GET aGet[07] VAR dClFchCad   ID 107 OF oDlg ;
      VALID ClFchValida(dClFchAdq,@dClFchCad,aGet[17])
   REDEFINE BUTTON aBtn[4] ;
      ID 504 OF oDlg       ;
      ACTION ( SelecFecha(@dClFchCad, aGet[07], oDlg, 200), aGet[07]:SetFocus(), SysRefresh() )
   aBtn[4]:cTooltip := i18n( "Seleccionar fecha" )

   REDEFINE RADIO oRadio VAR cCltipo ID 301, 302, 303 OF oDlg

   REDEFINE SAY aSay[09] ID 209 OF oDlg
   REDEFINE SAY aSay[10] ID 210 OF oDlg
   REDEFINE SAY aSay[11] ID 211 OF oDlg

   REDEFINE GET aGet[08] VAR cClInternet	;
 		ID 108 OF oDlg
   REDEFINE BUTTON aBtn[5] ID 505 OF oDlg ;
      ACTION ( GoWeb(Rtrim(cClInternet)), aGet[08]:SetFocus(), sysrefresh() )
   aBtn[5]:cTooltip  := i18n( "Visitar sitio web" )

   REDEFINE GET aGet[09] VAR cClftp ;
		ID 109 OF oDlg

   REDEFINE GET aGet[10] VAR cClemail ;
   	ID 110 OF oDlg

   REDEFINE BUTTON aBtn[6] ID 506 OF oDlg ;
      ACTION ( GoMail(Rtrim(cClemail)), aGet[10]:SetFocus(), SysRefresh() )
   aBtn[6]:cTooltip := i18n( "Enviar e-mail" )

   REDEFINE SAY aSay[12] ID 212 OF oDlg

   REDEFINE GET aGet[11] VAR cClarchivo  ID 111 OF oDlg
   REDEFINE BUTTON aBtn[7] ID 507 OF oDlg ;
      ACTION ( cGetFile := NIL ,;
               cGetFile := cGetfile32("*.*", i18n( "Seleccione el fichero" ),,,,.t.),;
               cClArchivo := IIF(!EMPTY(cGetFile), cGetFile, cClArchivo),;
               aGet[11]:Refresh(), aGet[11]:SetFocus(), sysrefresh() )
   aBtn[7]:cTooltip := i18n( "Seleccionar archivo" )

   REDEFINE SAY aSay[13] ID 213 OF oDlg

   REDEFINE GET aGet[12] VAR cClNotas ;
   	ID 112 MEMO OF oDlg

   /*___ dialogo principal _____________________________________________________*/

   REDEFINE BUTTON ID 400 OF oDlg       ;
      ACTION (lSave := .t., oDlg:End())
   REDEFINE BUTTOn ID 401 OF oDlg CANCEL;
      ACTION (lSave := .f., oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter(oDlg,oApp():oWndMain))

   if lSave
   	if lAppend
         CL->(DbGoTo(nRecAdd))
		else
			CL->(DbGoTo(nRecPtr))
		endif
      replace Cl->Clconcepto  with PadR(cClconcepto,40,' ')
      replace Cl->Clusuario   with PadR(cClusuario,40,' ')
      replace Cl->Clclave     with PadR(cClclave,20,' ')
      replace Cl->ClMateria   with PadR(cClMateria,20,' ')
      replace Cl->Cllong      with Str(nCllong,2)
      replace Cl->Clnotas     with PadR(cClnotas,250,' ')
      replace Cl->Clinternet  with PadR(cClinternet,60,' ')
      replace Cl->Clftp       with PadR(cClftp,60,' ')
      replace Cl->Clemail     with PadR(cClemail,60,' ')
      replace Cl->Clarchivo   with PadR(cClarchivo,80,' ')
      replace Cl->Clfchadq    with dClfchadq
      replace Cl->Clfchcad    with dClfchcad
      replace CL->Cltipo      with Str(cClTipo,1)
      replace Cl->ClCRC       with 'x'
      CL->(DbCommit())
      nRecPtr := nRecAdd
		nAt := AScan(oApp():aMaterias, { |a| a[1] == cClMateria }) 
		if nAt == 0
			AAdd(oApp():aMaterias, { CL->ClMateria, 1 } )
			ASort(oApp():aMaterias,,, {|x,y| upper(x[1]) < upper(y[1]) } )
		else
			oApp():aMaterias[nAt,2] := oApp():aMaterias[nAt,2] + 1
		endif
   else
		if lAppend
         /*___ no quiero salvar, deshago el append _____________________________*/
         CL->(DbGoTo(nRecAdd))
         CL->(DbDelete())
         CL->(DbGoTo(nRecPtr))
      endif
   endif
   select CL
   RefreshCont()
   oGrid:Refresh(.t.)
   oGrid:SetFocus()
return nil

//_____________________________________________________________________________//
function MaListFilter( aList, cData, oSelf )
   local aNewList := {}
   local i
   for i := 1 to len(oApp():aMaterias)
		// if cData == VK_SPACE
   	// 	AAdd( aNewList, { oApp():amaterias[i] } )
      // else
		if UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
			if AScan(aNewList, { |a| a[1] == oApp():amaterias[i,1] }) == 0 
         	AAdd( aNewList, { oApp():amaterias[i,1] } )
			endif
      endif 
   next
return aNewList
//-----------------------------------------------------------------------------//

static function ClChgClave( nCllong, aGet )
   local cTxt  := aGet[ 4 ]:GetText()
   cTxt        := SubStr( cTxt, 1, nCllong )
   while len( cTxt ) < nCllong
      cTxt     += Space( 1 )
   end
   aGet[ 4 ]:cText( cTxt )
	//	Código de Manolo Calero Solís
	aGet[4]:cPicture  := Replicate('X', nClLong)
   aGet[4]:oGet:Assign()
   aGet[4]:oGet:Picture := Replicate('X', nClLong)
   aGet[4]:oGet:UpdateBuffer()
return nil

//_____________________________________________________________________________//

function ClBorra( oGrid, oSay )
   local nRecord := CL->(Recno())
   local nNext, nAt

   if MsgYesNo( i18n( "¿ Está seguro de querer borrar esta clave ?")+CRLF+trim(CL->ClConcepto))
		nAt := AScan(oApp():aMaterias, { |a| a[1] == CL->ClMateria })
 		oApp():aMaterias[nAt,2] := oApp():aMaterias[nAt,2] - 1
      CL->(DbSkip())
      nNext := CL->(Recno())
      CL->(DbGoto(nRecord))
      CL->(DbDelete())
      CL->(DbGoto(nNext))
      if CL->(EOF()) .or. nNext == nRecord
         CL->(DbGoBottom())
      endif
   endif
   RefreshCont()
   oGrid:Refresh(.t.)
   oGrid:SetFocus()
return NIL

//_____________________________________________________________________________//
function ClImprime( oGrid )
	local oDlg, oFld, oCombo, oRadio, oLbx, oGet, oCol, oSay, oBtnDown, oBtnUp, oBtnShow, oBtnHide
	local oGet1
   local aCampos  := { "CLCONCEPTO", "CLUSUARIO", "CLCLAVE", "CLLONG", "CLNOTAS",;
                       "CLINTERNET", "CLFTP", "CLEMAIL", "CLARCHIVO", "CLFCHADQ",;
                       "CLFCHCAD", "CLMATERIA", "CLTIPO" }
   local aTitulos := { i18n("Servicio"),i18n("Usuario"),i18n("Clave"),i18n("Longitud"),i18n("Notas"),;
                       i18n("Sitio web"), i18n("F.T.P."), i18n("e-mail"), i18n("Archivo"), i18n("Obtención"),;
                       i18n("Caducidad"), i18n("Materia"), i18n("Tipo") }
   local aWidth   := { 40, 40, 20, 2, 200, 60, 60, 60, 80, 8, 8, 20, 10 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "CL01","CL02","CL03","CL04","CL05","CL06","CL07","CL08","CL09","CL10",;
							  "CL11","CL12","CL13" }
	local aArray 	:= { }
   local nLen     := 13 // nº de campos a mostrar

   local cReport  := GetPvProfString("Report", "ClReport","",oApp():cIniFile)
   local cRptFont := GetPvProfString("Report", "ClRptFont","",oApp():cIniFile)
   local nRadio   := VAL(GetPvProfString("Report", "ClRadio",1,oApp():cIniFile))
   local cTitulo1 := GetPvProfString("Report", "ClTitulo1",space(50),oApp():cIniFile)
   local cTitulo2 := GetPvProfString("Report", "ClTitulo2",space(50),oApp():cIniFile)

   local aoFont   := { , , }
   local aoSizes  := { , , }
   local aoEstilo := { , , }
   local acSizes  := { "10", "10", "10" }
   local acEstilo := { "Normal", "Normal", "Normal" }
   local acFont   := { "Courier New", "Courier New", "Courier New" }
   local aSizes   := { "08", "10", "12", "14", "16", "18", "20", "22", "24", "26", "28", "36", "48", "72" }
   local aEstilo  := { i18n("Cursiva"), i18n("Negrita"), i18n("Negrita Cursiva"),  i18n("Normal") }
   local nDevice  := 0
   local aTipo    := {"Sitio web","Acceso internet","Archivo","Otra clave"}
   local aMateria := {}
	local cMateria
   local nCounter := 0
	local nRec, nOrder
	local oFont1, oFont2, oFont3
	local i
	local cToken
	local aFont    := {}

   cTitulo1 := Rtrim(cTitulo1)+Space(50-LEN(cTitulo1))
   cTitulo2 := Rtrim(cTitulo2)+Space(50-LEN(cTitulo2))

   if ! empty(cReport)
      for i:=1 TO nLen
         cToken := StrToken(cReport,i,";")
         aCampos[i]  := StrToken(cToken,1,":")
         aTitulos[i] := StrToken(cToken,2,":")
         aWidth[i]   := VAL(StrToken(cToken,3,":"))
         aShow[i]    := AllTrim(StrToken( cToken, 4, ":" ) ) == "S"
      next
   endif
   if ! empty(cRptFont)
      for i:=1 TO 3
         cToken := StrToken(cRptFont,i,";")
         acFont[i]   := StrToken(cToken,1,":")
         acSizes[i]  := StrToken(cToken,2,":")
         acEstilo[i] := StrToken(cToken,3,":")
      next
   endif
	
	for i := 1 to len(oApp():aMaterias)
		Aadd(aMateria, oApp():aMaterias[i,1] )
	next
	
   IF LEN(aMateria) > 0
      cMateria := aMateria[1]
   ELSE
      cMateria := space(20)
   ENDIF

   aFont := aGetFont( oApp():oWndMain )

   DEFINE DIALOG oDlg RESOURCE 'INFORME1_'+oApp():cLanguage OF oApp():oWndMain ;
      TITLE i18n("Informes de contraseñas") 
	oDlg:SetFont(oApp():oFont)

   REDEFINE FOLDER oFld ;
      ID 100 OF oDlg    ;
      ITEMS i18n("&Tipo de informe"), i18n("&Selección de campos"), i18n("&Encabezado y tipografía");
      DIALOGS 'INFORME1A_'+oApp():cLanguage, 'INFORME1B_'+oApp():cLanguage, 'INFORME1C_'+oApp():cLanguage ;
      OPTION 1

   REDEFINE RADIO oRadio VAR nRadio ID 300, 301, 302, 303, 304, 305, 306 OF oFld:aDialogs[1]

   REDEFINE COMBOBOX oCombo VAR cMateria  ;
      ID       200                        ;
      ITEMS    aMateria                   ;
      WHEN nRadio == 2                    ;
      OF       oFld:aDialogs[1]

   /* ___ 2º FOLDER ___________________________________________________________*/
	oLbx := TXBrowse():New( oFld:aDialogs[2] )

	for i := 1 to nLen
		Aadd( aArray, {aShow[i],aTitulos[i],aWidth[i]} )
	next

	oLbx:SetArray(aArray)

   oLbx:nMarqueeStyle       := MARQSTYLE_HIGHLWIN7
   oLbx:nColDividerStyle    := LINESTYLE_LIGHTGRAY
   oLbx:lColDividerComplete := .t.
   oLbx:lRecordSelector     := .f.
	oLbx:lHScroll				 := .f.
   oLbx:nHeaderHeight       := 20
   oLbx:nRowHeight          := 20
	oLbx:lTransparent  	 	 := .f.
	oLbx:l2007	 				 := .f.
   oLbx:nDataType 			 := 1 // array
	oLbx:bChange				 := { || oGet:Refresh() }
	oLbx:nStretchCol 			 := -1

   oLbx:aCols[1]:cHeader  := i18n("Mostrar")
   oLbx:aCols[1]:nWidth   := 44
  	oLbx:aCols[1]:AddResource("CHECK")
   oLbx:aCols[1]:AddResource(" ")
   oLbx:aCols[1]:bBmpData := { || if(aArray[oLbx:nArrayAt,1]==.t.,1,2)}
 	olbx:aCols[1]:bStrData := {|| NIL }

   oLbx:aCols[2]:cHeader  := i18n("Columna")
   oLbx:aCols[2]:nWidth   := 140

   oLbx:aCols[3]:cHeader  := i18n("Ancho")
   oLbx:aCols[3]:nWidth   := 100

   for i := 1 TO LEN(oLbx:aCols)
      oCol := oLbx:aCols[ i ]
		oCol:bLDClickData  :=  { || IIF(aShow[ oLbx:nArrayAt ],oBtnHide:Click(),oBtnShow:Click()) }
   next
   oLbx:CreateFromResource( 200 )

   REDEFINE SAY oSay ID 210 OF oFld:aDialogs[2]
   REDEFINE GET oGet VAR aWidth[ oLbx:nArrayAt ] ;
      ID       211   ;
      SPINNER        ;
      MIN      1     ;
      MAX      99    ;
      PICTURE  "99"  ;
      VALID    aWidth[ oLbx:nArrayAt ] > 0 ;
      OF       oFld:aDialogs[2] ;
		ON CHANGE ( oLbx:aArrayData[oLbx:nArrayAt,3] := aWidth[oLbx:nArrayAt], oLbx:Refresh() )
	oGet:bLostFocus := {|| (oLbx:aArrayData[oLbx:nArrayAt,3] := aWidth[oLbx:nArrayAt], oLbx:Refresh()) }

   REDEFINE BUTTON oBtnUp        ;
      ID       201               ;
      OF       oFld:aDialogs[2]  ;
      WHEN oLbx:nArrayAt > 1          ;
      ACTION IIF( oLbx:nArrayAt > 1,;
                ( SwapUpArray( aShow   , oLbx:nArrayAt ) ,;
                  SwapUpArray( aTitulos, oLbx:nArrayAt ) ,;
                  SwapUpArray( aCampos , oLbx:nArrayAt ) ,;
                  SwapUpArray( aWidth  , oLbx:nArrayAt ) ,;
                  SwapUpArray( aPicture, oLbx:nArrayAt ) ,;
                  SwapUpArray( oLbx:aArrayData, oLbx:nArrayAt ) ,;
						oLbx:nArrayAt --                      ,;
                  oLbx:Refresh()                   ),;
                MsgStop("No se puede desplazar la columna." ))

   REDEFINE BUTTON oBtnDown   ;
      ID    202               ;
      OF    oFld:aDialogs[2]  ;
      WHEN oLbx:nArrayAt < Len(aTitulos) ;
      ACTION IIF( oLbx:nArrayAt < Len(aTitulos),  ;
                ( SwapDwArray( aShow   , oLbx:nArrayAt ) ,;
                  SwapDwArray( aTitulos, oLbx:nArrayAt ) ,;
                  SwapDwArray( aCampos , oLbx:nArrayAt ) ,;
                  SwapDwArray( aWidth  , oLbx:nArrayAt ) ,;
                  SwapDwArray( aPicture, oLbx:nArrayAt ) ,;
						SwapDwArray( oLbx:aArrayData, oLbx:nArrayAt ) ,;
                  oLbx:nArrayAt ++                      ,;
                  oLbx:Refresh()                   ),;
                MsgStop("No se puede desplazar la columna." ))

   REDEFINE BUTTON oBtnShow   ;
      ID    203               ;
      OF    oFld:aDialogs[2]  ;
      WHEN ( ! aShow[ oLbx:nArrayAt ] ) ;
      ACTION ( aShow[ oLbx:nArrayAt ] := .t., ;
					oLbx:aArrayData[oLbx:nArrayAt,1] := .t., oLbx:Refresh(),;
					oLbx:SetFocus(), oLbx:Refresh() )

   REDEFINE BUTTON oBtnHide   ;
      ID     204              ;
      OF     oFld:aDialogs[2] ;
      WHEN ( aShow[ oLbx:nArrayAt ] .AND. aScanN( aShow, .t. ) > 1 ) ;
      ACTION ( aShow[ oLbx:nArrayAt ] := .f.,;
 					oLbx:aArrayData[oLbx:nArrayAt,1] := .f., oLbx:Refresh(),;
					oLbx:SetFocus(), oLbx:Refresh() )

   REDEFINE SAY ID 100 OF oFld:aDialogs[3]
   REDEFINE SAY ID 101 OF oFld:aDialogs[3]
   REDEFINE SAY ID 102 OF oFld:aDialogs[3]
   REDEFINE GET oGet1 VAR cTitulo1 ;
      ID 200 OF oFld:aDialogs[3] UPDATE
   REDEFINE GET oGet1 VAR cTitulo2 ;
      ID 201 OF oFld:aDialogs[3] UPDATE

   REDEFINE SAY ID 211 OF oFld:aDialogs[3]
   REDEFINE SAY ID 212 OF oFld:aDialogs[3]
   REDEFINE COMBOBOX aoFont[1] VAR acFont[1] ;
      ID       213 ;
      ITEMS    aFont ;
      OF       oFld:aDialogs[3]

   REDEFINE COMBOBOX aoSizes[1] VAR acSizes[1] ;
      ID       214      ;
      ITEMS    aSizes   ;
      OF       oFld:aDialogs[3]

   REDEFINE COMBOBOX aoEstilo[1] VAR acEstilo[1] ;
      ID       215 ;
      ITEMS    aEstilo ;
      OF       oFld:aDialogs[3]

   REDEFINE SAY ID 216 OF oFld:aDialogs[3]
   REDEFINE COMBOBOX aoFont[2] VAR acFont[2] ;
      ID       217 ;
      ITEMS    aFont ;
      OF       oFld:aDialogs[3]

   REDEFINE COMBOBOX aoSizes[2] VAR acSizes[2] ;
      ID       218 ;
      ITEMS    aSizes ;
      OF       oFld:aDialogs[3]

   REDEFINE COMBOBOX aoEstilo[2] VAR acEstilo[2] ;
      ID       219 ;
      ITEMS    aEstilo ;
      OF       oFld:aDialogs[3]

   REDEFINE SAY ID 220 OF oFld:aDialogs[3]
   REDEFINE COMBOBOX aoFont[3] VAR acFont[3] ;
      ID       221 ;
      ITEMS    aFont ;
      OF       oFld:aDialogs[3]

   REDEFINE COMBOBOX aoSizes[3] VAR acSizes[3] ;
      ID       222 ;
      ITEMS    aSizes ;
      OF       oFld:aDialogs[3]

   REDEFINE COMBOBOX aoEstilo[3] VAR acEstilo[3] ;
      ID       223 ;
      ITEMS    aEstilo ;
      OF       oFld:aDialogs[3]

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
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   if oDlg:nresult == IDOK
      nRec   := CL->(RecNo())
      nOrder := CL->(OrdNumber())
      CL->(DbGoTop())
      do case
         case nRadio == 1
            nCounter := CL->(LastRec())
         case nRadio == 2
            count to nCounter for RTRIM(Cl->ClMateria) == RTRIM(cMateria)
         case nRadio == 3
            count to nCounter for Cl->ClTipo == '1'
         case nRadio == 4
            count to nCounter for Cl->ClTipo == '2'
         case nRadio == 5
            count to nCounter for Cl->ClTipo == '3'
         case nRadio == 6
            count to nCounter for .not. Empty(Cl->ClNotas)
         case nRadio == 7
            count TO nCounter for .not. Empty(Cl->ClFchAdq) .or. .not. Empty(Cl->ClFchCad)
      endcase

      CL->(DbGoTop())

      oFont1 := TFont():New( Rtrim( acFont[ 1 ] ), 0, Val( acSizes[ 1 ] ),,( i18n("Negrita") $ acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ acEstilo[ 1 ] ),,,,,,, )
      oFont2 := TFont():New( Rtrim( acFont[ 2 ] ), 0, Val( acSizes[ 2 ] ),,( i18n("Negrita") $ acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ acEstilo[ 2 ] ),,,,,,, )
      oFont3 := TFont():New( Rtrim( acFont[ 3 ] ), 0, Val( acSizes[ 3 ] ),,( i18n("Negrita") $ acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ acEstilo[ 3 ] ),,,,,,, )

      cTitulo1 := Rtrim(cTitulo1)
      cTitulo2 := Rtrim(cTitulo2)

      if nDevice == 1
         REPORT oReport ;
         TITLE  " "," ",cTitulo1,cTitulo2," " CENTERED;
         FONT   oFont3, oFont2, oFont1 ;
         HEADER ' ', oApp():cAppName+oApp():cVersion;
         FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oReport:nPage,3) ;
         CAPTION "LISTADO DE CONTRASEÑAS" PREVIEW
      elseif nDevice == 2
         REPORT oReport ;
         TITLE  " "," ",cTitulo1,cTitulo2," " CENTERED;
         FONT   oFont3, oFont2, oFont1 ;
         HEADER ' ', oApp():cAppName+oApp():cVersion;
         FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oReport:nPage,3) ;
         CAPTION "LISTADO DE CONTRASEÑAS" //PREVIEW
      endif

      for i := 1 TO Len(aTitulos)
         if aShow[i]
            if aPicture[i] == "NO"
               RptAddColumn( {bTitulo(aTitulos,i)},,{bCampo(aCampos,i)},aWidth[i],{},{||1},.F.,,,.F.,.F.,)
            elseif aPicture[i] == "CL01"
               COLUMN TITLE "Servicio" DATA Cl->Clconcepto SIZE aWidth[i] FONT 1
				elseif aPicture[i] == "CL02"
					COLUMN TITLE "Usuario" DATA Cl->ClUsuario SIZE aWidth[i] FONT 1
				elseif aPicture[i] == "CL03"
               COLUMN TITLE "Clave" DATA Cl->ClClave SIZE aWidth[i] FONT 1
				elseif aPicture[i] == "CL04"
               COLUMN TITLE "Longitud" DATA Cl->ClLong SIZE aWidth[i] FONT 1
				elseif aPicture[i] == "CL05"
               COLUMN TITLE "Notas" DATA Cl->ClNotas SIZE aWidth[i] FONT 1
				elseif aPicture[i] == "CL06"
               COLUMN TITLE "Sitio web" DATA Cl->ClInternet SIZE aWidth[i] FONT 1
				elseif aPicture[i] == "CL07"
               COLUMN TITLE "F.T.P." DATA Cl->ClFtp SIZE aWidth[i] FONT 1
				elseif aPicture[i] == "CL08"
               COLUMN TITLE "E-mail" DATA Cl->ClEmail SIZE aWidth[i] FONT 1
				elseif aPicture[i] == "CL09"
               COLUMN TITLE "Archivo" DATA Cl->ClArchivo SIZE aWidth[i] FONT 1
				elseif aPicture[i] == "CL10"
               COLUMN TITLE "F. Adquisición" DATA Cl->ClFchAdq SIZE aWidth[i] FONT 1
				elseif aPicture[i] == "CL11"
               COLUMN TITLE "F. Caducidad" DATA Cl->ClFchCad SIZE aWidth[i] FONT 1
				elseif aPicture[i] == "CL12"
               COLUMN TITLE "Materia" DATA Cl->ClMateria SIZE aWidth[i] FONT 1
            elseif aPicture[i] == "CL13"
               COLUMN TITLE "Categoria" DATA aTipo[MAX(1, VAL(CL->ClTipo))] SIZE aWidth[i] FONT 1
            endif
         endif
      next
      END REPORT

      if oReport:lCreated
         oReport:nTitleUpLine       := RPT_SINGLELINE
         oReport:nTitleDnLine       := RPT_SINGLELINE
         oReport:oTitle:aFont[3]    := {|| 3 }
         oReport:oTitle:aFont[4]    := {|| 2 }
         oReport:nTopMargin         := 0.1
         oReport:nDnMargin          := 0.1
         oReport:nLeftMargin        := 0.1
         oReport:nRightMargin       := 0.1
         oReport:oDevice:lPrvModal  := .t.
			oReport:Cargo 					:= 'claves.pdf'
      endif

      do case
         case nRadio == 1
            ACTIVATE REPORT oReport ;
               ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
                        oReport:Say(1, 'Contraseñas: '+Tran(nCounter, '@E 999,999'), 1),;
                        oReport:EndLine() )
         case nRadio == 2
            ACTIVATE REPORT oReport FOR RTRIM(Cl->ClMateria) == RTRIM(cMateria) ;
               ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
                        oReport:Say(1, 'Contraseñas: '+Tran(nCounter, '@E 999,999'), 1),;
                        oReport:EndLine() )
         case nRadio == 3
            ACTIVATE REPORT oReport FOR Cl->ClTipo == '1' ;
               ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
                        oReport:Say(1, 'Contraseñas: '+Tran(nCounter, '@E 999,999'), 1),;
                        oReport:EndLine() )
         case nRadio == 4
            ACTIVATE REPORT oReport FOR Cl->ClTipo == '2' ;
               ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
                        oReport:Say(1, 'Contraseñas: '+Tran(nCounter, '@E 999,999'), 1),;
                        oReport:EndLine() )
         case nRadio == 5
            ACTIVATE REPORT oReport FOR  Cl->ClTipo == '3' ;
               ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
                        oReport:Say(1, 'Contraseñas: '+Tran(nCounter, '@E 999,999'), 1),;
                        oReport:EndLine() )
         case nRadio == 6
            ACTIVATE REPORT oReport FOR .NOT. Empty(CL->ClNotas);
               ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
                        oReport:Say(1, 'Contraseñas: '+Tran(nCounter, '@E 999,999'), 1),;
                        oReport:EndLine() )
         case nRadio == 7
            ACTIVATE REPORT oReport FOR .NOT. Empty(CL->ClFchAdq) .OR. .NOT. Empty(CL->ClFchCad) ;
               ON END ( oReport:StartLine(), oReport:EndLine(), oReport:StartLine(), ;
                        oReport:Say(1, 'Contraseñas: '+Tran(nCounter, '@E 999,999'), 1),;
                        oReport:EndLine() )
      endcase

      CL->(OrdSetFocus(nOrder))
      CL->(DbGoTo(nRec))

      oFont1:End()
      oFont2:End()
      oFont3:End()

      cReport := ""
      for i:=1 TO nLen
         cReport := cReport +aCampos[i]+":"
         cReport := cReport +aTitulos[i]+":"
         cReport := cReport +STR(aWidth[i],2)+":"
         cReport := cReport +IIF(aShow[i],"S","N")+";"
      next
      cRptFont := ""
      for i:=1 TO 3
         cRptFont := cRptFont +acFont[i]+":"
         cRptFont := cRptFont +acSizes[i]+":"
         cRptFont := cRptFont +acEstilo[i]+";"
      next
      WritePProString("Report","ClReport",cReport,oApp():cIniFile)
      WritePProString("Report","ClRptFont",cRptFont,oApp():cIniFile)
      WritePProString("Report","ClRadio",Ltrim(Str(nRadio)),oApp():cIniFile)
      WritePProString("Report","ClTitulo1",cTitulo1,oApp():cIniFile)
      WritePProString("Report","ClTitulo2",cTitulo2,oApp():cIniFile)
   endif

   oGrid:Refresh()
   oGrid:SetFocus( .t. )
return nil
//_____________________________________________________________________________//

function bTitulo( aTitulos, nFor )
return {|| aTitulos[ nFor ] }

function bCampo( aCampos, nFor )
return (fieldWBlock(aCampos[nFor],SELECT() ))

function bPicture( aPicture, nFor )
return aPicture[ nFor ]

function bArray( aArray,aCampos,nFor )
   local nIndex
   nIndex := EVAL(bCampo(aCampos,nFor))
return aArray[ VAL(nIndex) ]
//_____________________________________________________________________________//

function ClTecla(nKey,oGrid,oSay)
	do case
	   case nKey==VK_RETURN
	      ClEdita(oGrid,.f.,oSay)
	   case nKey==VK_INSERT
	      ClEdita(oGrid,.t.,oSay)
	   case nKey==VK_DELETE
	      ClBorra(oGrid,oSay)
	   otherwise
	      if nKey>=96 .AND. nKey <=105
	         nKey := nKey - 48
	      endif
	      if nkey>=48 .and. nkey <=90
	         ClBusca(ogrid, chr(nkey))
	      endif
	endcase
return nil

//_____________________________________________________________________________//

function ClGenera(cClave,nLong,lFromUser)
	local cChar := '0123456789qwertyuiopñlkjhgfdsazxcvbnmMNBVCXZASDFGHJKLÑPOIUYTREWQ'
	local cNClave
	local i, n
	if ! Empty(Rtrim(cClave))
	   if ! MsgYesNo( i18n( "El servicio ya tiene una clave. ¿ Desea generar una nueva ?" ) )
	      retu NIL
	   endif
	endif
	cNClave := ''
	for i := 1 to nLong
	   n := FT_RAND(64)
	   cNClave := cNClave + substr(cChar,n,1)
	next
	if lFromUser
	   if MsgYesNo( i18n( "La nueva clave es" )+" "+ cNClave + CRLF + ;
	               i18n( "¿ Desea aceptar la nueva clave ?" ) )
	      cClave := cNClave
	   endif
	endif
return nil

//_____________________________________________________________________________//

function ft_rand(nMax)
   // sacada de NanLib 3.05
   static nSeed
   local m := 100000000
   local b := 31415621
   nSeed := iif( nSeed == NIL, seconds(), nSeed )   // init_seed()
return ( nMax * ( ( nSeed := mod( nSeed*b+1, m ) ) / m ) )

//_____________________________________________________________________________//

function ClBusca( oGrid, cChr )
   local nOrder    := CL->(OrdNumber())
   local nRecno    := CL->(Recno())
   local oDlg, oGet, cGet, cPicture
   local cConcepto := space(40)
   local cUsuario  := space(20)
   local dFecha    := CtoD('')
   local lSeek     := .f.
   local lFecha    := .f.
	local lRet		 := .f.

   if oApp():lGridHided
      MsgStop( i18n( "No se puede realizar búsquedas de claves con las claves ocultas." ) + CRLF + ;
               i18n( "Por favor, muestre las claves y vuelva a intentarlo." ) )
      retu NIL
   endif

   DEFINE DIALOG oDlg RESOURCE 'DlgBusca' ;
      TITLE i18n("Búsqueda de claves")
	oDlg:SetFont(oApp():oFont)

   if nOrder == 1
      REDEFINE SAY PROMPT i18n( "Introduzca el servicio" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Servicio" )+":" ID 21 OF Odlg
      cGet     := cConcepto
   elseif nOrder == 2
      REDEFINE SAY PROMPT i18n( "Introduzca el nombre de usuario" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Usuario" )+":" ID 21 OF Odlg
      cGet     := cUsuario
   elseif nOrder == 3
      REDEFINE SAY PROMPT i18n( "Introduzca la clave" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "clave" )+":" ID 21 OF Odlg
      cGet     := cUsuario
   elseif nOrder == 4
      REDEFINE SAY PROMPT i18n( "Introduzca la fecha de obtención" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Fecha de obtención" )+":" ID 21 OF Odlg
      cGet   := dFecha
      lFecha := .t.
   elseif nOrder == 5
      REDEFINE SAY PROMPT i18n( "Introduzca la fecha de caducidad" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Fecha de caducidad" )+":" ID 21 OF Odlg
      cGet   := dFecha
      lFecha := .t.
   elseif nOrder == 6
      REDEFINE SAY PROMPT i18n( "Introduzca la materia" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Materia" )+":" ID 21 OF Odlg
      cGet   := cUsuario
      lFecha := .f.
   else
      CL->(OrdSetFocus(1))
      nOrder   := 1
      REDEFINE SAY PROMPT i18n( "Introduzca el servicio" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Servicio" )+":" ID 21 OF Odlg
      cGet     := cConcepto
      lFecha   := .f.
   endif

   /*__ si he pasado un caracter lo meto en la cadena a buscar ________________*/
   if cChr != NIL
      if .NOT. lFecha
         cGet := cChr+SubStr(cGet,1,len(cGet)-1)
      else
         cGet := CtoD(cChr+' -  -    ')
      endif
   endif

   REDEFINE GET oGet VAR cGet ID 101 OF oDlg
   if cChr != NIL
      oGet:bGotFocus := { || ( oGet:SetColor( CLR_BLACK, RGB(255,255,127) ), oGet:SetPos(2) ) }
   endif

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION (lSeek := .t., oDlg:End())
   REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
      PROMPT i18n( "&Cancelar" )  ;
      ACTION (lRet := .f., oDlg:End())

   sysrefresh()

   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter(oDlg,oApp():oWndMain) )// , IIF(cChr!=NIL,oGet:SetPos(2),), oGet:Refresh() )

   if lSeek
      if ! lFecha
         cGet := rtrim(Upper(cGet))
      else
         cGet := DtoS(cGet)
      endif
      if ! CL->(DbSeek( cGet, .t. ))
         MsgAlert( i18n( "No encuentro esa clave." ) )
         CL->(DbGoTo(nRecno))
      endif
   endif
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
return NIL

//_____________________________________________________________________________//

function ClFchValida(dClFchAdq,dClFchCad,oGet)
   local lRet :=.f.
   if dClFchAdq == Ctod('')
      lRet := .t.
   elseif dClFchCad == CtoD('')
      lRet := .t.
   elseif dClFchAdq > dClFchCad
      MsgStop(i18n('La fecha de caducidad no puede ser anterior a la de obtención.'))
      lRet := .f.
   else
      lRet := .t.
   endif
return lRet

//_____________________________________________________________________________//