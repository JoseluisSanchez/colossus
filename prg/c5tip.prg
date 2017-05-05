/*
ÚÄ Programa ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   Aplication: class TC5Tip                                               ³
³         File: C5TIP.PRG                                                  ³
³       Author: Francisco Garc¡a Fern ndez                                 ³
³     Internet: http://www.arrakis.es/~canal_five/                         ³
³       E-Mail: canalfive@solution4u.com                                   ³
³         Date: 01-ENE-1998                                                ³
³         Time: 17:00:00                                                   ³
³      Version: 1.00                                                       ³
³    Copyright: 1998 by Francisco Garc¡a Fern ndez                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "fivewin.ch"

extern GetTextWidth

CLASS TC5Tip FROM TWindow

      DATA lMakeFont
      DATA nHRow
      DATA oTimer, nTimer
      DATA cPrompt

      CLASSDATA lRegistered AS LOGICAL

      METHOD New( oWnd, nClrText, nClrPane, oFont ) CONSTRUCTOR

      METHOD Hide() INLINE ::lVisible := .f., ::Super:Hide()
      METHOD Show( nRow, nCol, cPrompt, oWnd )
      METHOD Paint()
      METHOD MaxLen( cPrompt )

ENDCLASS


******************************************************
 METHOD New( oWnd, nClrText, nClrPane, oFont, nTips )
******************************************************
      Local amarillo := RGB( 255,255,128)

       DEFAULT nClrText := CLR_BLACK, nClrPane := amarillo,;
               nTips := 1


       ::nTimer        := 2000
       ::lVisible      := .f.
       ::oWnd          := oWnd
       ::oWnd:oToolTip := Self

       if oFont == nil
          DEFINE FONT ::oFont NAME "Ms Sans Serif" SIZE 6,12
          ::lMakeFont := .t.
       else
          ::lMakeFont := .f.
          ::oFont := oFont
       endif

       ::nHRow     := ::oFont:nHeight + 3

       ::nStyle    := nOR( WS_POPUP, WS_BORDER )


       ::SetColor( nClrText, nClrPane )

       ::Register()
       ::Create()
       ::Hide()

Return Self


***************************
 METHOD Paint()
***************************

Local hDC := ::GetDC()
Local oThis := self
Local hOldFont



IF ::oTimer != nil
   ::oTimer:Deactivate()
endif

DEFINE   TIMER ::oTimer INTERVAL ::nTimer ACTION oThis:Hide() OF Self
ACTIVATE TIMER ::oTimer


   SetBkMode( ::hDC, 1 )
   hOldFont  := SelectObject( ::hDC,  ::oFont:hFont  )
   SetTextColor( ::hDC, ::nClrText )

   DrawText  ( ::hDC, ::cPrompt, { 1, 1  , ::nHeight, ::nWidth }, 16  )

   SetBkMode   ( ::hDC, 0 )
   SelectObject( ::hDC, hOldFont )



::ReleaseDC()

return nil








******************************************
 METHOD Show( nRow, nCol, cPrompt, oWnd )
******************************************

Local n
Local aPoint := { nRow, nCol }
Local aAux, nMaxLen
Local nHeight
Local nWidth
Local nHScreen := GetSysMetrics(  1  )
Local nWScreen := GetSysMetrics(  0  )
Local nLines

if ::lVisible
   ::Hide()
endif

  if cPrompt != nil
     ::cPrompt := cPrompt
     aAux :=  ::MaxLen( cPrompt )
     nMaxLen  := aAux[1]
     nLines   := aAux[2]
     nWidth   := nMaxLen + 4
     nHeight  := ( nLines * ::nHRow ) + 2
  endif

  ClientToScreen( oWnd:hWnd, aPoint )
  if aPoint[ 1 ] == nRow
     aPoint := ClientToScreen( oWnd:hWnd, aPoint )
  endif

  nRow := aPoint[ 1 ]
  nCol := aPoint[ 2 ]

  if nRow + nHeight > nHScreen
     nRow := nHScreen - nHeight - 10
  endif

  if nCol + nWidth > nWScreen
     nCol := nWScreen - nWidth - 10
  endif

  ::Move( nRow, nCol, nWidth, nHeight , .t. )

  ::Super:Show()

  ::lVisible := .t.

Return nil


***************************************
 METHOD MaxLen( cPrompt )
***************************************
 Local n, cLine
 Local nLines  := mlcount( cPrompt )
 Local nMaxLen := 0

  For n := 1 to nLines
      cLine := rtrim( memoline( cPrompt,, n))
      nMaxLen := max( nMaxLen, ::GetWidth( cLine, ::oFont ) + 8 )
  next n

return { nMaxLen, nLines }







