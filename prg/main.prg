#include "FiveWin.ch"
#include "SayRef.ch"

REQUEST ADS

REQUEST HB_LANG_ES
REQUEST HB_CODEPAGE_ESWIN

memvar oApp
// memvar oAGet

function Main()
   public oApp
	RddRegister("ADS",1)
	RddSetDefault("ADS")
	AdsSetServerType(1) //SET SERVER LOCAL
	AdsSetFileType(3)	  //SET FILETYPE TO CDX

   HB_LangSelect( 'ES' )
   HB_SetCodePage( 'ESWIN' )

   SetHandleCount(100)

   SET DATE FORMAT   'dd-mm-yyyy'
   SET DELETED       ON
   SET CENTURY ON
   SET EPOCH         TO YEAR(DATE()) - 20
   SET MULTIPLE OFF
	
	Ut_Override()
   oApp := TApplication():New()
   oApp:Activate()
return Nil

/*_____________________________________________________________________________*/
function oApp()
return oApp
/*_____________________________________________________________________________*/
//function oAGet()
//return oAGet
/*_____________________________________________________________________________*/
CLASS TApplication

   DATA  nCLOrder
	DATA  cAppName
   DATA  cVersion
   DATA  cIniFile
   DATA  oClp

   DATA  oWndMain
   DATA  oIcon
   DATA  oFont
	DATA	cMsgBar
   DATA  oMsgItem1, oMsgItem2, oMsgItem3
	DATA  oToolBar, oImgList, oReBar
   DATA  oDlg
   DATA  oGrid
   DATA  oVMenu
   DATA  oSplit
	DATA  nEdit
	DATA  aMaterias
   DATA  lGridHided
	DATA	nClrHL
	DATA  nClrBar

   DATA  cLanguage
   DATA  cDbfPath
	DATA  cDbfFile
	DATA  cDbfPwd

   METHOD New() CONSTRUCTOR
   METHOD END()
	METHOD Activate()
	METHOD BuildBtnBar()
	METHOD SetWinCoors()
	METHOD GetWinCoors()
	METHOD ResizeWndmain()
	METHOD AppAcercade()
	METHOD AppConfig()

ENDCLASS
/*_____________________________________________________________________________*/

METHOD NEW() CLASS TApplication
	local aInfo := GetFontInfo(GetFontMenu())
   ::oIcon     := TIcon():New( ,, "ICON1",, )

   ::cAppName  := "Colossus "
	::cVersion  := "6.10.c"
   ::cIniFile  := TakeOffExt(GetModuleFileName(GetInstance()))+".ini"
   ::cDbfPath  := cFilePath(GetModuleFileName(GetInstance()))
	::cDbfFile  := GetPvProfString("Browse", "DbfFile", NIL, ::cIniFile)
	::cDbfPwd   := space(30)
   ::cLanguage := 'ES'
   ::lGridHided:= .f.
	::nEdit		:= 0
	::aMaterias := {}
	::nClrHL		:= RGB(204,232,255)
	::nClrbar	:= RGB(165,186,204) 
   
	DEFINE FONT ::oFont NAME "Segoe UI" SIZE 0, -12

   DEFINE WINDOW ::oWndMain ;
      TITLE ::cAppName+::cVersion ;
      COLOR CLR_BLACK, GetSysColor(15)-RGB(30,30,30) ;
      ICON ::oIcon

	::oWndMain:SetFont(::oFont)
   
	SET MESSAGE OF ::oWndMain TO ::cMsgBar CENTER NOINSET
	::oWndMain:oMsgBar:SetFont(::oFont)

	DEFINE MSGITEM ::oMsgItem2;
	   OF ::oWndMain:oMsgBar;
	   PROMPT "acerca de Colossus" SIZE 152 ;
	   BITMAPS "MSG_LOTUS", "MSG_LOTUS";
	   TOOLTIP " " + i18n("Acerca de...") + " "
	::oMsgItem2:bAction := { || ::AppAcercade( .f. ) }

   DEFINE MSGITEM ::oMsgItem3 OF ::oWndMain:oMsgBar ;
      SIZE 152 PROMPT "www.alanit.com" ;
      COLOR RGB(3,95,156), GetSysColor(15)    ;
		BITMAPS "MSG_ALANIT", "MSG_ALANIT";
      TOOLTIP i18n("visitar la web de alanit");
      ACTION WinExec('start '+'.\alanit.url', 0)

   ::oWndmain:oMsgBar:DateOn()

   ::BuildBtnBar()

return SELF
/*_____________________________________________________________________________*/
METHOD End() CLASS TApplication
	if ::oDlg != nil
		if ::nEdit > 0
			return nil
		elseif MsgYesNo(" ¿ Desea finalizar el programa ?")
			::oDlg:End()
			::oWndMain:End()
		endif
	else
		if MsgYesNo(" ¿ Desea finalizar el programa ?")
			::oWndMain:End()
		endif
	endif	
return ( Self )

/*_____________________________________________________________________________*/
METHOD Activate() CLASS TApplication
	local n  := Val(GetPvProfString("Config", "nInicio", "1", oApp():cIniFile))
   ::GetWinCoors()
   ::oWndMain:bResized := {|| ::ResizeWndMain() }
	::oWndMain:bInit    := {|| iif(n==1 .and. oApp():cDbfFile != NIL, Claves(oApp():cDbfFile), ) }
   ACTIVATE WINDOW ::oWndMain ;
		VALID ::SetWinCoors()

	Do While ::oFont:nCount > 0
		::oFont:End()
	Enddo

return nil
/*_____________________________________________________________________________*/
METHOD BuildBtnBar() CLASS TApplication
   ::oImgList := TImageList():New( 36, 36 ) // width and height of bitmaps
   ::oImgList:AddMasked( TBitmap():Define( "BB_FILE_NEW"      ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_FILE_OPEN"     ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_FILE_CLOSE"    ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_APP_CONFIG"    ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_GRID_CONFIG"   ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_ALANIT"        ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_ACERCADE"      ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_DOOR_IN"       ,, ::oWndMain ), nRGB( 240, 240, 240 ) )

   ::oReBar := TReBar():New( ::oWndMain )
   ::oToolBar := TToolBar():New( ::oReBar, 38, 40, ::oImgList, .t. )
   ::oReBar:InsertBand( ::oToolBar )

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  ClNewFile() ;
      TOOLTIP i18n("crear fichero de claves")

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  Claves() ;
      TOOLTIP i18n("abrir un fichero de claves")

	DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  iif(oApp():oDlg != NIL, oApp():oDlg:End(),) ;
      TOOLTIP i18n("cerrar un fichero de claves")

	DEFINE TBSEPARATOR OF ::oToolbar

	DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  ::AppConfig() ;
      TOOLTIP i18n("configurar arranque de la aplicación")

	DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  iif(oApp():oGrid!=NIL, Ut_BrwColConfig(oApp():oGrid, "State"), MsgStop("Para configurar las columnas primero debe abrir un fichero de claves.") ) ;
      TOOLTIP i18n("configurar la rejilla de datos")

	DEFINE TBSEPARATOR OF ::oToolbar

	DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  WinExec('start '+'.\alanit.url', 0) ;
      TOOLTIP i18n("visitar la web de alanit")

	DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  ::AppAcercade(.f.) ;
      TOOLTIP i18n("acerca de Colossus")

	DEFINE TBSEPARATOR OF ::oToolbar

   DEFINE TBBUTTON OF ::oToolBar ;
      TOOLTIP  "Finalizar el programa"   ;
      ACTION   ::End() ;
      MESSAGE  "Salida"

   //::oExit:nLeft := ::oBar:nWidth - 60
   //::oBar:bResized:={ || ::oExit:nLeft := ::oBar:nWidth - 60 }

return ( Self )
/*_____________________________________________________________________________*/
/*_____________________________________________________________________________*/
/*___ OZScript ________________________________________________________________*/

#define ST_NORMAL        0
#define ST_ICONIZED      1
#define ST_ZOOMED        2

METHOD GetWinCoors()  CLASS TApplication
   LOCAL oIni
   LOCAL nRow, nCol, nWidth, nHeight, nState

   nRow    := VAL(GetPvProfString("Config", "nTop", "10", ::cIniFile))
	nCol    := VAL(GetPvProfString("Config", "nLeft", "10", ::cIniFile))
	nWidth  := VAL(GetPvProfString("Config", "nRight", "800", ::cIniFile))
	nHeight := VAL(GetPvProfString("Config", "nBottom", "600", ::cIniFile))
	nState  := VAL(GetPvProfString("Config", "Mode", nState, ::cIniFile))

   IF nRow == 0 .AND. nCol == 0
      WndCenter(::oWndMain:hWnd)
   ELSE
      ::oWndMain:Move(nRow, nCol, nWidth, nHeight)
   ENDIF

   IF nState == ST_ICONIZED
      ::oWndMain:Minimize()
   ELSEIF nState == ST_ZOOMED
      ::oWndMain:Maximize()
   ENDIF
   UpdateWindow( ::oWndMain:hWnd )
   ::oWndMain:CoorsUpdate()
   SysRefresh()

RETURN NIL

//-------------------------------------------------------------------------//

METHOD SetWinCoors() CLASS TApplication
   LOCAL oIni
   LOCAL nRow, nCol, nWidth, nHeight, nState

   ::oWndMain:CoorsUpdate()

   nRow    := ::oWndMain:nTop
   nCol    := ::oWndMain:nLeft
   nWidth  := ::oWndMain:nRight-::oWndMain:nLeft
   nHeight := ::oWndMain:nBottom-::oWndMain:nTop

   IF IsIconic( ::oWndMain:hWnd )
      nState := ST_ICONIZED
   ELSEIF IsZoomed(::oWndMain:hWnd)
      nState := ST_ZOOMED
   ELSE
      nState := ST_NORMAL
   ENDIF

	WritePProString("Config","nTop",Ltrim(Str(nrow)),::cIniFile)
	WritePProString("Config","nLeft",Ltrim(Str(ncol)),::cIniFile)
	WritePProString("Config","nRight",Ltrim(Str(nwidth)),::cIniFile)
	WritePProString("Config","nBottom",Ltrim(Str(nheight)),::cIniFile)
	WritePProString("Config","Mode",Ltrim(Str(nstate)),::cIniFile)

	DbCloseAll()
	ResAllFree()
   ::oFont:End()
	::oImgList:End()

RETURN .t.
//_____________________________________________________________________________//

METHOD ResizeWndMain()  CLASS TApplication
   local aClient
   if ::oDlg != nil
      aClient := GetClientRect( ::oWndMain:hWnd )
      ::oDlg:SetSize( aClient[4], aClient[3] - ::oToolBar:nHeight - 4 - ::oWndMain:oMsgBar:nHeight )
      oApp():oDlg:Refresh()
      if oApp():oGrid != nil
         oApp():oGrid:SetSize( aClient[4]-oApp():oGrid:nLeft, oApp():oDlg:nHeight )
         oApp():oGrid:Refresh()
      endif
      oApp():oWndMain:oMsgBar:Refresh()
   endif
return NIL
//_____________________________________________________________________________//

METHOD AppAcercade() CLASS TApplication
   local oDlg, aGet[9], cPrompt, oTmr
   local oMs10Under := TFont():New("Ms Sans Serif",0,-12,,.f.,,,,,.t.)

   define dialog oDlg title i18n("Acerca de")  ;
      FROM  0, 0 TO 200, 330 PIXEL             ;
      COLOR CLR_BLACK, CLR_WHITE			  	  	  ;
		FONT ::oFont

   @ 00,08 BITMAP aGet[1] RESOURCE 'acercade2' ;
      SIZE 34, 54 OF oDlg PIXEL NOBORDER // TRANSPAREN

   @ 10,44 BITMAP aGet[2] RESOURCE 'acercade1' ;
      SIZE 94, 20 OF oDlg PIXEL NOBORDER // TRANSPAREN
   @ 32,10 SAYREF aGet[4] PROMPT "http://www.alanit.com" ;
      SIZE 146,10 PIXEL CENTERED OF oDlg                 ;
      HREF "http://www.alanit.com"                       ;
      COLOR RGB(3,95,156), CLR_WHITE // FONT oMs10Under
   aGet[4]:cTooltip  := i18n("visita mi web para descargar gratis más programas")

   @ 42,10 SAY aGet[5] PROMPT i18n("José Luis Sánchez Navarro") ;
      SIZE 146,9 PIXEL CENTERED OF oDlg ;
      COLOR CLR_GRAY, CLR_WHITE
	@ 54,10 SAY aGet[5] PROMPT i18n("Este programa se distribuye bajo licencia:") ;
		SIZE 146,9 PIXEL CENTERED OF oDlg ;
		COLOR CLR_BLACK, CLR_WHITE
   @ 64,10 SAY aGet[6] PROMPT i18n("Licencia Pública General de GNU v. 3") ;
      SIZE 146,19 PIXEL CENTERED OF oDlg ;
      COLOR CLR_BLACK, CLR_WHITE
   @ 74,10 SAYREF aGet[7] PROMPT "http://es.wikipedia.org/wiki/GNU_General_Public_License" ;
      SIZE 146,10 PIXEL OF oDlg     ;
      HREF "http://es.wikipedia.org/wiki/GNU_General_Public_License" ;
      COLOR RGB(3,95,156), CLR_WHITE // FONT oMs10Under

   activate dialog oDlg ;
		ON INIT oDlg:Center( oApp():oWndMain ) ;
      ON CLICK oDlg:end()
   oMs10Under:End()
return nil
/*_____________________________________________________________________________*/
METHOD AppConfig() CLASS TApplication
	local oDlg, aSay[2], oRadio, oGet
	local nPwdLen := Val(GetPvProfString("Config", "nLong", "12", oApp():cIniFile))
	local nRadio  := Val(GetPvProfString("Config", "nInicio", "1", oApp():cIniFile))
	local lOk := .f.
	DEFINE DIALOG oDlg RESOURCE 'CONFIG_'+oApp():cLanguage;
      TITLE 'Configuración del programa'	 
	oDlg:SetFont(oApp():oFont)

   REDEFINE SAY aSay[1] ID 10 OF oDlg
   REDEFINE SAY aSay[2] ID 11 OF oDlg

	REDEFINE RADIO oRadio VAR nRadio ID 21, 22 OF oDlg
	REDEFINE GET oGet      ;
				VAR  nPwdLen  ;
            ID       23   ;
            OF       oDlg ;
            PICTURE  '99' ;
            SPINNER  MIN 1 MAX 20

	REDEFINE BUTTON ID 400 OF oDlg       ;
      ACTION (lOk := .t., oDlg:End())
   REDEFINE BUTTOn ID 401 OF oDlg CANCEL;
      ACTION (lOk := .f., oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter(oDlg,oApp():oWndMain))

   if lOk
		WritePProString("Config","nLong",Str(nPwdLen),oApp():cIniFile)
		WritePProString("Config","nInicio",Str(nRadio),oApp():cIniFile)
	endif

return nil
/*_____________________________________________________________________________*/

FUNCTION ClpView(oClp)
   LOCAL oDlgClip
   LOCAL oIcon, oBmp

   DEFINE DIALOG oDlgClip RESOURCE 'DlgClipb' ;
      TITLE oApp():cVersion 
	oDlgClip:SetFont(oApp():oFont)

   oDlgClip:nStyle := nOr( oDlgClip:nStyle, 4 )

   REDEFINE SAY PROMPT i18n("Contenido del portapapeles") ID 10 OF oDlgClip
   REDEFINE SAY PROMPT oClp:GetText id 11 COLOR CLR_BLUE, CLR_WHITE OF oDlgClip
   REDEFINE BITMAP oBmp ID 111 OF oDlgClip RESOURCE 'clipb' TRANSPARENT

   REDEFINE BUTTON ID 400 OF oDlgClip ;
      PROMPT i18n( "&Aceptar" )       ;
      ACTION oDlgClip:End()

   ACTIVATE DIALOG oDlgClip ON INIT DlgCenter(oDlgClip,oApp():oWndMain)
RETURN NIL

/*_____________________________________________________________________________*/

Function CambiaOrden( nOrden )
   LOCAL nRecno := CL->(Recno())
   LOCAL nLen   := Len( oApp():oGrid:aCols )
	local n

   FOR n := 1 TO nLen
		IF oApp():oGrid:aCols[ n ]:nHeadBmpNo != NIL .and. oApp():oGrid:aCols[ n ]:nHeadBmpNo > 0
         IF oApp():oGrid:aCols[ n ]:nCreationOrder == nOrden
            oApp():oGrid:aCols[ n ]:nHeadBmpNo := 1
         ELSE
            oApp():oGrid:aCols[ n ]:nHeadBmpNo := 2
         ENDIF
      ENDIF
   NEXT

   CL->(DbSetOrder(nOrden))
   CL->(DbGoTop())
   oApp():oGrid:Refresh(.t.)
   CL->(DbGoTo(nRecno))
   oApp():oGrid:Refresh(.t.)
   oApp():oGrid:SetFocus(.t.)
return NIL

/*______________________________________________________________________________*/

function i18n(cadena)
return cadena