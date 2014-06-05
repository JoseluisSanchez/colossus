#include "fivewin.ch"

CLASS TApplication

   DATA  oIcon
   DATA  oTab
   DATA  oBmp
   DATA  oBrush
   DATA  oMenu
   DATA  oCursor

   DATA  nDemora
   DATA  oFont
   DATA  nCLOrder
   DATA  cCompra
   DATA  cUser
	DATA  cAppName
   DATA  cVersion
   DATA  cPath
   DATA  cIniFile
   DATA  oClp

   DATA  oWndMain
	DATA	cMsgBar
   DATA  oMsgItem1, oMsgItem2, oMsgItem3
	DATA  oToolBar, oImgList, oReBar
   DATA  oDlg
   DATA  oGrid
   DATA  oVMenu
   DATA  oSplit
	DATA  aMaterias
   DATA  lGridHided

   DATA  cLanguage
   DATA  cDbfPath
	DATA  cDbfFile
	DATA  cDbfPwd

   METHOD New() CONSTRUCTOR
   METHOD END()
	METHOD Activate()
	METHOD BuildBtnBar()
	METHOD Close()

ENDCLASS

METHOD NEW() CLASS TApplication

   ::oIcon     := TIcon():New( ,, "ICON1",, )
	::oFont 	 	:= TFont():New( GetDefaultFontName2(), 0, GetDefaultFontHeight2(),, )
   ::oBrush    := TBrush():New("NULL",,,)
   ::oCursor   := TCursor():New( , 'HAND' )

   ::cCompra   := "©ª¤˜¤§™¢Ÿ]KJIHGFEDCBA@?>=<;:9876543210/xs"
   ::cUser     := "‘‹‹Ž€‰„†E210/uz"
   ::cPath     := cFilePath(GetModuleFileName(GetInstance()))

   ::cAppName  := "Colossus "
	::cVersion  := "5.01"
   ::cIniFile  := TakeOffExt(GetModuleFileName(GetInstance()))+".ini"
   ::cDbfPath  := cFilePath(GetModuleFileName(GetInstance()))
	::cDbfFile  := GetPvProfString("Browse", "DbfFile", NIL, ::cIniFile)
	::cDbfPwd   := space(30)
   ::cLanguage := 'ES'
   ::lGridHided:= .f.
	::aMaterias := {}

   DEFINE WINDOW ::oWndMain ;
      TITLE ::cAppName+::cVersion ;
      COLOR CLR_BLACK, GetSysColor(15)-RGB(30,30,30) ;
      ICON ::oIcon

   SET MESSAGE OF ::oWndMain TO ::cMsgBar CENTER NOINSET
	::oWndMain:oMsgBar:oFont := ::oFont

	DEFINE MSGITEM ::oMsgItem2;
	   OF ::oWndMain:oMsgBar;
	   PROMPT iif(::cUser!=SPACE(15),::cUser,"acerca de Colossus");
	   SIZE len(::cUser)*12;
	   BITMAPS "MSG_LOTUS", "MSG_LOTUS";
	   TOOLTIP " " + i18n("Acerca de...") + " "
	#ifdef __REGISTRADA__
		::oMsgItem2:bAction := { || AppAcercade( .f. ) }
	#else
		::oMsgItem2:bAction := { || Registrame() }
	#endif

   DEFINE MSGITEM ::oMsgItem3 OF ::oWndMain:oMsgBar ;
      SIZE 152 FONT ::oFont;
      PROMPT "www.alanit.com" ;
      COLOR RGB(3,95,156), GetSysColor(15)    ;
		BITMAPS "MSG_ALANIT", "MSG_ALANIT";
      TOOLTIP i18n("visitar la web de alanit");
      ACTION WinExec('start '+'.\alanit.url', 0)

   ::oWndmain:oMsgBar:DateOn()

   ::BuildBtnBar()

	if ::cUser == space(15)
		::cUser := "Edición no registrada"
	endif

RETURN SELF

METHOD End()
	DbCloseAll()
	SetWinCoors(::oWndMain, ::cInifile)
   ::oFont:End()
	::oImgList:End()
	ResAllFree()
	::oWndMain:End()
RETURN .t.

METHOD Activate() CLASS TApplication
   GetWinCoors(::oWndMain, ::cInifile)
   ::oWndMain:bResized := {|| ResizeWndMain() }
   ACTIVATE WINDOW ::oWndMain
	::End()
return nil

METHOD BuildBtnBar() CLASS TApplication
   ::oImgList := TImageList():New( 36, 36 ) // width and height of bitmaps
   ::oImgList:AddMasked( TBitmap():Define( "BB_FOLDER_PAGE"   ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_FOLDER_USER"   ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
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

	DEFINE TBSEPARATOR OF ::oToolbar

   DEFINE TBBUTTON OF ::oToolBar ;
      TOOLTIP  "Finalizar el programa"   ;
      ACTION   ::End() ;
      MESSAGE  "Salida"

   //::oExit:nLeft := ::oBar:nWidth - 60
   //::oBar:bResized:={ || ::oExit:nLeft := ::oBar:nWidth - 60 }

return ( Self )

//----------------------------------------------------------------------------//

METHOD Close() CLASS TApplication

   ResAllFree()

return nil

