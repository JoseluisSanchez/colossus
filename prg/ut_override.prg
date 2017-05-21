#include "FiveWin.ch"

#xcommand OVERRIDE METHOD <!Message!> [IN] CLASS <!Class!> ;
                             WITH [METHOD] <!Method!> [SCOPE <Scope>] => ;
            __clsModMsg( <Class>():classH, #<Message>, @<Method>() )

function Ut_override()
	OVERRIDE METHOD BuildButtonBar IN CLASS TPreview WITH PreviewBuildButtonBar 
	OVERRIDE METHOD BuildListView  IN CLASS TPreview WITH PreviewBuildListView
return nil

Function PreviewBuildButtonBar() 

   local oImageList, oReBar, oBar, oHand, uRet, oBtn
	local Self := HB_QSelf()
	local lRebar := .t.

   DEFINE CURSOR ::oHand HAND

   if lRebar
      DEFINE IMAGELIST oImageList SIZE 16, 16
      oImageList:AddMasked( TBitmap():Define( "16_TOP",, ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_PREVIOUS",, ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_NEXT",, ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_BOTTOM",, ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_ZOOM",, ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_DOS_PAGINAS",, ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_IMPRIMIR",, ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_GUARDAR",,  ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_PDF",,  ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_EMAIL",, ), nRGB( 204, 204, 204 ) )
      oImageList:AddMasked( TBitmap():Define( "16_WORD",,  ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_EXCEL",, ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_SALIR",, ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_NUEVO",, ), nRGB( 240, 240, 240 ) )
      oImageList:AddMasked( TBitmap():Define( "16_NUEVO",, ), nRGB( 240, 240, 240 ) )
      ::oImageList = oImageList

      oReBar = TReBar():New( ::oWnd )

      DEFINE TOOLBAR oBar OF oReBar SIZE 25, 25 IMAGELIST oImageList

      ::oBar = oBar
      oReBar:InsertBand( oBar )

      oBar:nHeight -= 2

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::TopPage() ;
         TOOLTIP FWString( "First" ) ;
         MESSAGE FWString( "Go to first page" )

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::PrevPage() ;
         TOOLTIP FWString( "Previous" ) ;
         MESSAGE FWString( "Go to previous page" )

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::NextPage() ;
         TOOLTIP FWString( "Next" ) ;
         MESSAGE FWString( "Go to next page" )

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::BottomPage() ;
         TOOLTIP FWString( "Last" ) ;
         MESSAGE FWString( "Go to last page" )

      DEFINE TBSEPARATOR OF oBar

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::Zoom() ;
         TOOLTIP FWString( "Zoom" ) ;
         MESSAGE FWString( "Page zoom" )

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::TwoPages() ;
         TOOLTIP FWString( "Two pages" ) ;
         MESSAGE FWString( "Preview on two pages" )

      DEFINE TBSEPARATOR OF oBar

      DEFINE TBMENU OF oBar ;
         ACTION  If( ValType( ::bPrint ) == 'B', Eval( ::bPrint, Self ), ::PrintPage() ) ;
         TOOLTIP FWString( "Print" ) ;
         MESSAGE FWString( "Print actual page" ) ;
         MENU    ::PrintersMenu()

      DEFINE TBMENU OF oBar ;
         ACTION  ::SaveAs( .f. ) ;
         TOOLTIP FWString( "Save as" ) ;
         MESSAGE FWString( "Save to DOC/PDF" ) ;
         MENU ::SaveAsMenu()

     DEFINE TBBUTTON OF oBar ;
        ACTION ::SaveAs( .t. ) ; //If( ::bSaveAsPDF == nil, FWSavePreviewToPDF( Self ), Eval( ::bSaveAsPDF, Self ) ) ;
        TOOLTIP FWString( "Export to PDF" ) ;
        MESSAGE FWString( "Export to PDF" )

     DEFINE TBBUTTON OF oBar ;
        ACTION ::SendEmail() ;
        TOOLTIP FWString( "Send by email as PDF" ) ;
        MESSAGE FWString( "Send by email as PDF" )

     DEFINE TBBUTTON OF oBar ;
        ACTION ::ExportToMSWord() ;
        TOOLTIP FWString( "Export to MS Word" ) ;
        MESSAGE FWString( "Export to MS Word" )

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::ExportToMSExcel() ;
         TOOLTIP FWString( "Export to Excel" ) ;
         MESSAGE FWString( "Export to Excel" ) ;
         WHEN ::CanExportToExcel

      DEFINE TBSEPARATOR OF oBar

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::oWnd:End() ;
         TOOLTIP FWString( "Exit" ) ;
         MESSAGE FWString( "Exit from preview" )

   else
		/*
      if nStyle == 2010
         DEFINE BUTTONBAR oBar OF ::oWnd 2010 ;
            SIZE IfNil( nBtnW, 26 ), IfNil( nBtnH, If( LargeFonts(), 30, 26 ) )
      else
         DEFINE BUTTONBAR oBar OF ::oWnd ;
            SIZE IfNil( nBtnW, 26 ), IfNil( nBtnH, If( LargeFonts(), 30, 26 ) )
      endif

      ::oBar = oBar
      oBar:l2007     := ( nStyle == 2007 )
      oBar:l2010     := ( nStyle == 2010 )
      oBar:l97Look   := ( nStyle == 97 )
      oBar:bRClicked := { || nil }  // to retain the bar on top only

      DEFINE BUTTON oBtn OF oBar ;
         MESSAGE FWString( "Go to first page" ) ;
         ACTION  ::TopPage() ;
         TOOLTIP FWString( "First" )
      oBtn:hBitmap1 = FWBitmap2( "16_TOP",, )

      DEFINE BUTTON oBtn OF oBar ;
         MESSAGE FWString( "Go to previous page" ) ;
         ACTION  ::PrevPage() ;
         TOOLTIP FWString( "Previous" )

      oBtn:hBitmap1 = FWBitmap2( "16_PREVIOUS" )

      DEFINE BUTTON oBtn OF oBar ;
         MESSAGE FWString( "Go to next page" ) ;
         ACTION  ::NextPage() ;
         TOOLTIP FWString( "Next" )

      oBtn:hBitmap1 = FWBitmap2( "16_NEXT" )

      DEFINE BUTTON oBtn OF oBar ;
         MESSAGE FWString( "Go to last page" ) ;
         ACTION  ::BottomPage() ;
         TOOLTIP FWString( "Last" )

      oBtn:hBitmap1 = FWBitmap2( "16_BOTTOM" )

      DEFINE BUTTON ::oZoom OF oBar GROUP ;
         MESSAGE FWString( "Page zoom" ) ;
         ACTION  ::Zoom() ;
         TOOLTIP FWString( "Zoom" )

      ::oZoom:hBitmap1 = FWBitmap2( "16_ZOOM" )

      DEFINE BUTTON ::oTwoPages OF oBar ;
         MESSAGE FWString( "Preview on two pages" ) ;
         ACTION  ::TwoPages() ;
         TOOLTIP FWString( "Two pages" )

      ::oTwoPages:hBitmap1 = FWBitmap2( "16_DOS_PAGINAS" )

      DEFINE BUTTON oBtn OF oBar GROUP ;
         MENU    ::PrintersMenu() ;
         MESSAGE FWString( "Print actual page" )            ;
         ACTION  If( ValType( ::bPrint ) == 'B', Eval( ::bPrint, Self ), ::PrintPage() ) ;
         TOOLTIP FWString( "Print" )

      oBtn:hBitmap1 = FWBitmap2( "16_IMPRIMIR" )

      if ! Empty( bUserBtns )
         uRet = Eval( bUserBtns, Self, oBar )
      endif

      if ! ( ValType( uRet ) == 'L' .and. uRet == .f. )

         DEFINE BUTTON oBtn OF oBar ;
            MENU ::SaveAsMenu() ;
            MESSAGE FWString( "Save to DOC/PDF" ) ;
            ACTION This:ShowPopUp() ;
            TOOLTIP FWString( "Save to DOC/PDF" )

         oBtn:hBitmap1 = FWBitmap2( "16_GUARDAR" )

         DEFINE BUTTON oBtn OF oBar ;
            MESSAGE FWString( "Export to PDF" ) ;
            ACTION  ::SaveAs( .t. ) ;
            TOOLTIP FWString( "Export to PDF" )

         oBtn:hBitmap1 = FWBitmap2( "16_PDF" )

         DEFINE BUTTON oBtn OF oBar ;
            MESSAGE FWString( "Send by email as PDF" ) ;
            ACTION  ::SendEmail() ;
            TOOLTIP FWString( "Send by email as PDF" )

         oBtn:hBitmap1 = FWBitmap2( "16_EMAIL" )

         DEFINE BUTTON oBtn OF oBar ;
            MESSAGE FWString( "Export to MS Word" ) ;
            ACTION  ::ExportToMSWord() ;
            TOOLTIP FWString( "Export to MS Word" ) ;
            WHEN ::CanExportToWord

         oBtn:hBitmap1 = FWBitmap2( "16_WORD" )

         DEFINE BUTTON oBtn OF oBar ;
            MESSAGE FWString( "Export to Excel" ) ;
            ACTION ::ExportToMSExcel() ;
            TOOLTIP FWString( "Export to Excel" ) ;
            WHEN ::CanExportToExcel

         oBtn:hBitmap1 = FWBitmap2( "16_EXCEL" )

      endif

      DEFINE BUTTON oBtn OF oBar GROUP ;
         MESSAGE FWString( "Exit from preview" )               ;
         ACTION  ::oWnd:End()                   ;
         TOOLTIP FWString( "Exit" )

      oBtn:hBitmap1 = FWBitmap2( "16_SALIR" )

      AEval( oBar:aControls, { | o | o:oCursor := ::oHand } )
		*/
   endif

return nil

Function PreviewBuildListView() 
   local nSizeH, nSizeV, oBmp, n, aPrompts := {}
	local Self := HB_QSelf()

   if ::oDevice:nHorzRes() > ::oDevice:nVertRes()
     nSizeH = 100
     nSizeV = 80
   else
     nSizeH = 80
     nSizeV = 100
   endif

   oBmp = TBitmap():Define()
   ::oImageListPages = TImageList():New( nSizeH, nSizeV )

   for n := 1 to Len( ::oDevice:aMeta )
      oBmp:hBitmap := PageBitmap( ::oDevice:aMeta[ n ], nSizeH, nSizeV )
      ::oImageListPages:Add( oBmp )
      Aadd( aPrompts, AllTrim( Str( n ) ) )
   NEXT

   ::oLvw = TListView():New( 33 - If( ::oWnd:oTop:IsKindOf( "TBAR" ), 6, 0 ),;
                             0, aPrompts, { | nPage | ::GoPage( nPage ) }, ::oWnd,;
                             ,, .T.,, nSizeH + 65, ScreenHeight() - ;
                             If( ::oWnd:oBar != nil, ::oWnd:oBar:nHeight() - 2,;
                             ::oWnd:oTop:nHeight() ) - ;
                             If( ::oWnd:oMsgBar != nil, ::oWnd:oMsgBar:nHeight(),;
                             ::oWnd:oBottom:nHeight() ) - 38 )
   ::oLvw:SetImageList( ::oImageListPages )
   ::oLvw:bRClicked = { || If( ::oLvw:nLeft == 0,;
                               ::oLvw:nLeft := ::oWnd:nWidth - ::oLvw:nWidth - 30,;
                               ::oLvw:nLeft := 0 ) }

return nil

static function PageBitmap( cEMF, nWidth, nHeight )

   local hDC1 := GetDC( GetDesktopWindow() )
   local hDC2 := CreateCompatibleDC( hDC1 )
   local hBmp := CreateCompatibleBitmap( hDC1, nWidth, nHeight )
   local hOldBmp := SelectObject( hDC2, hBmp )
   local hEMF := GetEnhMetaFile( cEmf )

   Rectangle( hDC2, 0, 0, nHeight, nWidth )
   XPlayEnhMetaFile( hDC2, hEMF, 0, 0, nHeight, nWidth )
   CloseEnhMetafile( hEMF )

   SelectObject( hDC2, hOldBmp )
   DeleteDC( hDC2 )
   ReleaseDC( hDC1 )

return hBmp

