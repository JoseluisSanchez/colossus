// SayRef control by Ramón Avendaño
// 25-09-99

#include "FiveWin.ch"
#include "Constant.ch"

#define WM_NCHITTEST         132   // 0x84
#define WM_LBUTTONDBLCLK     515   // 0x203

//----------------------------------------------------------------------------//

CLASS TSayRef FROM TSay

   DATA   cHRef
   DATA   lMailTo

   DATA   lWantClick

   METHOD New( nRow, nCol, bText, oWnd, cHRef, lMailTo, oFont,;
               lCentered, lRight, lPixels, nClrText, nClrBack,;
               nWidth, nHeight, lDesign, lUpdate ) CONSTRUCTOR

   METHOD ReDefine( nId, bText, oWnd, cHRef, lMailTo, ;
                    nClrText, nClrBack, lUpdate, oFont )  CONSTRUCTOR

   METHOD HandleEvent( nMsg, nWParam, nLParam )

   METHOD LButtonDown( nRow, nCol, nKeyFlags )
   METHOD LButtonUp( nRow, nCol, nKeyFlags )

   METHOD LDblClick( nRow, nCol, nKeyFlags )

   METHOD RButtonDown( nRow, nCol, nKeyFlags )
   METHOD RButtonUp( nRow, nCol, nKeyFlags )

   METHOD MouseMove( nRow, nCol, nKeyFlags )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nRow, nCol, bText, oWnd, cHRef, lMailTo, oFont,;
            lCentered, lRight, lPixels, nClrText, nClrBack,;
            nWidth, nHeight, lDesign, lUpdate ) CLASS TSayRef

  DEFAULT cHRef := "", lMailTo := .f.

  ::cHRef   := cHRef
  ::lMailTo := lMailTo

  ::lWantClick := .f.


  Super:New( nRow, nCol, bText, oWnd, "", oFont,;
             lCentered, lRight, .f., lPixels, nClrText, nClrBack,;
             nWidth, nHeight, lDesign, lUpdate, .f., .f., .f. )


return Self

//----------------------------------------------------------------------------//

METHOD ReDefine( nId, bText, oWnd, cHRef, lMailTo, ;
                 nClrText, nClrBack, lUpdate, oFont ) CLASS TSayRef

  DEFAULT cHRef := "", lMailTo := .f.

  ::cHRef   := cHRef
  ::lMailTo := lMailTo

  ::lWantClick := .f.

  Super:ReDefine( nId, bText, oWnd, "",;
                  nClrText, nClrBack, lUpdate, oFont )

return Self

//----------------------------------------------------------------------------//

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TSayRef

   if ( !( ::lDrag .or. ::lWantClick ) .and.  nMsg == WM_MOUSEMOVE )
      return ::MouseMove( nHiWord( nLParam ), nLoWord( nLParam ),;
             nWParam )
   endif

   do case
      case nMsg == WM_LBUTTONDOWN
           return ::LButtonDown( nHiWord( nLParam ), nLoWord( nLParam ),;
                                 nWParam )
      case nMsg == WM_LBUTTONUP
           return ::LButtonUp( nHiWord( nLParam ), nLoWord( nLParam ),;
                               nWParam )
      case nMsg == WM_LBUTTONDBLCLK
           return ::LDblClick( nHiWord( nLParam ), nLoWord( nLParam ),;
                               nWParam )
      case nMsg == WM_RBUTTONDOWN
           return ::RButtonDown( nHiWord( nLParam ), nLoWord( nLParam ),;
                                 nWParam )
      case nMsg == WM_RBUTTONUP
           return ::RButtonUp( nHiWord( nLParam ), nLoWord( nLParam ),;
                               nWParam )
   endcase

            if ( ( ::lDrag .or. ::lWantClick ) .and. nMsg == WM_NCHITTEST )
      return DefWindowProc( ::hWnd, nMsg, nWParam, nLParam )
   else
      if ( nMsg == WM_NCHITTEST )
         return DefWindowProc( ::hWnd, nMsg, nWParam, nLParam )
      endif
   endif

return Super:HandleEvent( nMsg, nWParam, nLParam )

//----------------------------------------------------------------------------//

METHOD LButtonDown( nRow, nCol, nKeyFlags ) CLASS TSayRef

   if ::lDrag
      return Super:LButtonDown( nRow, nCol, nKeyFlags )
   else
      if ::bLClicked != nil
         return Eval( ::bLClicked, nRow, nCol, nKeyFlags )
      endif
   endif

   CursorHAND()

return 0

//----------------------------------------------------------------------------//

METHOD LButtonUp( nRow, nCol, nKeyFlags ) CLASS TSayRef

   if ::lDrag
      return Super:LButtonUp( nRow, nCol, nKeyFlags )
   else
      if ::bLButtonUp != nil
         return Eval( ::bLButtonUp, nRow, nCol, nKeyFlags )
      endif
   endif

   CursorHAND()

   // WinExec( "start " + if( ::lMailto, "MAILTO:", "" ) + ::cHRef, 0 )
   if ::lMailTo
   	IF ! IsWinNt()
			WinExec('start mailto: '+::cHRef,0)
		ELSE
   		WinExec("rundll32.exe url.dll,FileProtocolHandler mailto:" + ::cHRef)
		ENDIF
	Else
   	IF ! IsWinNt()
			WinExec('start urlto:'+::cHRef,0)
		ELSE
   		WinExec("rundll32.exe url.dll,FileProtocolHandler " + ::cHRef)
		ENDIF
	Endif
return 0

//----------------------------------------------------------------------------//

METHOD LDblClick( nRow, nCol, nKeyFlags ) CLASS TSayRef

   if ::bLDblClick != nil
      return Eval( ::bLDblClick, nRow, nCol, nKeyFlags )
   endif

   CursorHAND()

return nil

//----------------------------------------------------------------------------//

METHOD RButtonDown( nRow, nCol, nKeyFlags ) CLASS TSayRef

   if ::bRClicked != nil
      Eval( ::bRClicked, nRow, nCol, nKeyFlags, Self )
   endif

   CursorHAND()

return nil

//----------------------------------------------------------------------------//

METHOD RButtonUp( nRow, nCol, nKeyFlags ) CLASS TSayRef

   if ::bRButtonUp != nil
      Eval( ::bRButtonUp, nRow, nCol, nKeyFlags )
   endif

   CursorHAND()

return nil

//----------------------------------------------------------------------------//

METHOD MouseMove( nRow, nCol, nKeyFlags ) CLASS TSayRef

   ::SetMsg( ::cMsg )

   ::CheckToolTip()

   if ::lDrag
      return Super:MouseMove( nRow, nCol, nKeyFlags )
   else
      if ::bMMoved != nil
         return Eval( ::bMMoved, nRow, nCol, nKeyFlags )
      endif
   endif

   CursorHAND()

return 0

//----------------------------------------------------------------------------//
// R.Avendaño. 1998, 1999








