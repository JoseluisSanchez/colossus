/*
ÚÄ Programa ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   Aplication: class TC5Bitmap                                            ³
³         File: C5BMP.PRG                                                  ³
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

#define SRCPAINT   15597702
#define SRCAND     8913094
#define SRCCOPY    13369376

extern GetTextWidth

CLASS TC5Bitmap

      DATA cBitmap

      DATA hBmp
      DATA hBmp2
      DATA hPal
      DATA hPal2

      DATA hDC
      DATA hDCMem
      DATA hOldBmp

      DATA lMem
      DATA lMask

      DATA nClrPane
      DATA nHeight
      DATA nTop
      DATA nLeft
      DATA nMedH
      DATA nMedW
      DATA nWidth
      DATA nMrgAlign

      DATA oWnd

      METHOD New        ( cBitmap, oWnd, lMask, nTop, nLef,;
                          nMrgAlign) CONSTRUCTOR
      METHOD MakeMem    ( nWidth, nHeight, nColor, oWnd, lMask,;
                          nMrgAlign ) CONSTRUCTOR

      METHOD Destroy()


      METHOD LoadBmp( cBitmap )

      METHOD MakeMask()

      METHOD Paint( hDC, nTop, nLeft )
      METHOD PaintAlign( hDC, aRect, cAlign )
      METHOD FastPaint( hDC, nTop, nLeft )

      METHOD BeginPaint( hDC )
      METHOD EndPaint()

      METHOD SaveScreen( hDC, nTop, nLeft )


ENDCLASS

************************************************************************
  METHOD New ( cBitmap, oWnd, lMask, nTop, nLeft, nMrgAlign )
************************************************************************

       DEFAULT cBitmap := "", lMask := .t., nTop := 0, nLeft := 0,;
               nMrgAlign := 3

       ::nTop     := nTop
       ::nLeft    := nLeft

       ::hBmp     := 0
       ::hBmp2    := 0

       ::lMem     := .f.
       ::oWnd     := oWnd
       ::nMrgAlign := nMrgAlign

       if ::oWnd == nil
          ? "debe especificar oWnd al crear un bitmap "
       endif

       ::lMask    := lMask

       ::LoadBmp( cBitmap )

       if lMask
          ::MakeMask()
       endif

       ::nMedW     := ::nWidth/2
       ::nMedH     := ::nHeight/2

Return self

*******************************************************************
 METHOD MakeMem( nWidth, nHeight, nColor, oWnd, lMask, nMrgAlign )
*******************************************************************

   Local hDCMem, hOldBmp, hBrush, hDC

   DEFAULT nColor := CLR_WHITE, lMask := .f., nMrgAlign := 3

   ::hBmp      := 0
   ::hBmp2     := 0
   ::oWnd      := oWnd
   ::lMem      := .t.
   ::nMrgAlign := nMrgAlign

   if ::oWnd == nil
      ? "debe especificar oWnd al crear un bitmap "
   endif

   if oWnd != nil
      hDC := oWnd:GetDC()
   else
      ? "getdc( 0 ) 99 "
      hDC := GetDC( 0 )
   endif

   hDCMem  := CompatDC    ( hDC )

   ::hBmp  := CompatBmp   ( hDC, nWidth, nHeight )

   hOldBmp := SelectObject( hDCMem, ::hBmp )

   hBrush  := CreateSolidBrush( nColor )

   fillrect( hDCMem, { 0, 0, nHeight, nWidth }, hBrush )

   SelectObject( hDCMem, hOldBmp )

   DeleteObject( hBrush )

   hBrush := 0

   if lMask


      ::hBmp2 := CompatBmp    ( hDC, nWidth, nHeight )

      hOldBmp := SelectObject( hDCMem, ::hBmp )

      hBrush := GetStockObject( 4 )

      fillrect( hDCMem, { 0, 0, nHeight, nWidth }, hBrush )

      SelectObject( hDCMem, hOldBmp )

   endif

   DeleteDC( hDCMem )

   if oWnd != nil
      oWnd:ReleaseDC()
   else
      DeleteDC( hDC )
   endif

  ::nMedW     := nWidth/2
  ::nMedH     := nHeight/2

  ::nHeight   := nHeight
  ::nWIdth    := nWidth

Return Self



**************************************
 METHOD LoadBmp( cBitmap )
**************************************

Local hDC, ainfo

DEFAULT cBitmap := ""

if ::oWnd == nil
   ? "getdc( 0 ) 144"
   hDC := GetDC( 0 )
else
   hDC := ::oWnd:GetDC()
endif


::hBmp    := 0

::nWidth  := 0
::nHeight := 0

if !empty( cBitmap )

   if "." $ cBitmap
      ::cBitmap := cBitmap
      aInfo := PalBmpRead( hDC, cBitmap )
      ::hBmp := aInfo[1]
      ::hPal := aInfo[2]
   else
      aInfo := PalBmpLoad( cBitmap )
      ::hBmp := aInfo[1]
      ::hPal := aInfo[2]
   endif

   if ::hBmp != 0
      ::nWidth  := nBmpWidth ( ::hBmp )
      ::nHeight := nBmpHeight( ::hBmp )
   endif

endif

//if ::hBmp != 0
//   PalBmpNew( ::hBmp )
//endif

if ::oWnd == nil
   DeleteDC( hDC )
else
   ::oWnd:ReleaseDC()
endif

return nil







***********************************
  METHOD Destroy()
***********************************

if ::lMem
   DeleteObject( ::hBmp )
else
   //DeleteObject( nHiWord( ::hBmp ) )
   DeleteObject( ::hBmp  )
endif


if ::hBmp2 > 0
   DeleteObject( ::hBmp2 )
endif

sysrefresh()


Return nil





***********************
 METHOD MakeMask()
***********************

Local hdcDst
Local hdcMask,  hBmpMask,  hBmpMaskOld

Local hdcImage           , hBmpImageOld
Local hdcAux,              hOldBmp
Local nHBmp, nWBmp

nHBmp := ::nHeight
nWBmp := ::nWidth

if ::oWnd == nil
   ? "getdc( 0 ) 236"
   hdcDst := GetDC( 0 )
else
   hdcDst := ::oWnd:GetDC()
endif


hDCImage     := CompatDC( hdcDst )
::hBmp2      := CompatBmp( hdcDst, nWBmp, nHBmp )
hBmpImageOld := SelectObject( hDCImage, ::hBmp2        )

hdcAux  := CompatDC( hdcDst )
hOldBmp := SelectObject( hdcAux, ::hBmp )

bitblt( hdcImage, 0, 0, nWBmp, nHBmp, hdcAux, 0, 0, SRCCOPY )

SelectObject( hdcAux, hOldBmp )
DeleteDC( hdcAux )

hdcMask     := CompatDC    ( hdcDst )
hBmpMask    := CompatBmp   ( hdcMask, nWBmp, nHBmp )
hBmpMaskOld := SelectObject( hdcMask, hBmpMask )

   *copia mapa de bits en color al dc monocromo para crear m scara monocroma
   bitblt( hdcMask, 0, 0, nWBmp, nHBmp, hDCImage, 0, 0, SRCCOPY )

   *invierte fondo del dibujo para crear m scara AND
   SetBkColor  ( hdcImage, CLR_BLACK )
   SetTextColor( hdcImage, CLR_WHITE )
   bitblt( hdcImage , 0, 0, nWBmp, nHBmp, hdcMask , 0, 0, SRCAND )


SelectObject( hDCImage, hBmpImageOld )
SelectObject( hdcMask,  hBmpMaskOld  )

DeleteObject( hBmpMask )

DeleteDC( hdcImage )
DeleteDC( hdcMask  )

if ::oWnd == nil
   DeleteDC( hdcDst )
else
   ::oWnd:ReleaseDC()
endif

return nil

*********************************************
 METHOD PaintAlign( hDC, aRect, cAlign )
*********************************************
Local nTop, nLeft, nBottom, nRight
Local nCol, nRow
Local nWidth, nHeight


nTop    := aRect[ 1 ]
nLeft   := aRect[ 2 ]
nBottom := aRect[ 3 ]
nRight  := aRect[ 4 ]


  do case
     case cAlign == "TOP_LEFT"

          nCol := nLeft + ::nMrgAlign
          nRow := nTop  + ::nMrgAlign

     case cAlign == "TOP_CENTER"
          nCol := nLeft + int( ( nRight - nLeft ) / 2 ) - ::nMedW
          nRow := nTop + ::nMrgAlign

     case cAlign == "TOP_RIGHT"
          nCol := nRight - ::nWidth - ::nMrgAlign
          nRow := nTop + ::nMrgAlign

     case cAlign == "LEFT"
          nCol := nLeft + ::nMrgAlign
          nRow := nTop  + int( ( nBottom - nTop ) / 2 ) - ::nMedH

     case cAlign == "CENTER"
          nCol := nLeft + int( ( nRight - nLeft ) / 2 ) - ::nMedW
          nRow := nTop  + int( ( nBottom - nTop ) / 2 ) - ::nMedH

     case cAlign == "RIGHT"
          nCol := nRight -  ::nWidth - ::nMrgAlign
          nRow := nTop  + int( ( nBottom - nTop ) / 2 ) - ::nMedH

     case cAlign == "BOTTOM_LEFT"
          nCol := nLeft + ::nMrgAlign
          nRow := nBottom - ::nHeight - ::nMrgAlign

     case cAlign == "BOTTOM_CENTER"
          nCol := nLeft + int( ( nRight - nLeft ) / 2 ) - ::nMedW
          nRow := nBottom - ::nHeight - ::nMrgAlign

     case cAlign == "BOTTOM_RIGHT"
          nCol := nRight - ::nWidth - ::nMrgAlign
          nRow := nBottom - ::nHeight - ::nMrgAlign

     otherwise

          nCol := nLeft + int( ( nRight - nLeft ) / 2 ) - ::nMedW
          nRow := nTop  + int( ( nBottom - nTop ) / 2 ) - ::nMedH
  endcase

*::Paint( hDC, nRow, nCol )
::FastPaint( hDC, nCol, nRow )

return nil




*********************************************
 METHOD Paint( hDC, nTop, nLeft )
*********************************************

Local hdcCache, hBmpCache, hBmpCacheOld
Local hdcFore            , hBmpForeOld
Local hDcImage           , hBmpImageOld
Local hdcMask            , hBmpMaskOld
Local clrBack, clrFore
Local hBmp, hBmp2

DEFAULT nTop := ::nTop, nLeft := ::nLeft

if ::hBmp2 == 0

      PalBmpDraw( hDC, nTop, nLeft, ::hBmp, ::hPal , ::nWidth, ::nHeight, SRCCOPY )

else

   * ES MASK
   if !::lMem
      * ES MASK CON DOS BMPS DE FIVEWIN

      //hBmp  := nLoWord( ::hBmp  )
      //hBmp2 := nLoWord( ::hBmp2 )

      hBmp  := ::hBmp
      hBmp2 := ::hBmp2
   else
      * ES MASK DE C5
      hBmp  :=  ::hBmp
      hBmp2 :=  ::hBmp2
   endif

   hdcCache     := CompatDC( hDC )
   hbmpCache    := CompatBmp( hdc   , ::nWidth, ::nHeight )
   hBmpCacheOld := SelectObject( hdcCache, hbmpCache )

   hdcImage     := CompatDC( hDC )
   hBmpImageOld := SelectObject( hdcImage, hBmp )

   SetBkColor  ( hdcImage, CLR_BLACK )
   SetTextColor( hdcImage, CLR_WHITE )

   hdcMask      := CompatDC( hdC )
   hBmpMaskOld  := SelectObject( hdcMask , hBmp2 )

   bitblt( hdcCache, 0, 0, ::nWidth, ::nHeight, hdc, nLeft, nTop, SRCCOPY )

   clrBack := GetBkColor  ( hdcCache )
   clrFore := GetTextColor( hdcCache )

   SetBkColor  ( hdcCache, CLR_WHITE )
   SetTextColor( hdcCache, CLR_BLACK )

   * m scara de fondo
   bitblt( hdcCache, 0, 0, ::nWidth, ::nHeight,;
           hdcImage,  0, 0, SRCAND )

   * pone imagen en el agujero que ha creado la m scara
   bitblt( hdcCache, 0, 0, ::nWidth, ::nHeight,;
           hdcMask, 0, 0, SRCPAINT )

   *restablece color
   SetBkColor  ( hdcCache, clrBack )
   SetTextColor( hdcCache, clrFore )

   * pone cache terminado en la pantalla
   bitblt( hdc   , nLeft, nTop, ::nWidth, ::nHeight,;
           hdcCache, 0, 0, SRCCOPY )

   SelectObject( hdcImage, hBmpImageOld )
   SelectObject( hdcMask , hBmpMaskOld  )
   SelectObject( hdcCache, hbmpCacheOld )

   DeleteObject( hbmpCache )

   DeleteDC( hdcCache )
   DeleteDC( hdcMask  )
   DeleteDC( hdcImage )

endif

return nil


************************************
      METHOD BeginPaint( hDC )
************************************

::hDCMem  := CompatDC( hDC )
::hOldBmp := SelectObject( ::hDCMem, ::hBmp )

Return nil


************************************
      METHOD EndPaint( lMask )
************************************

SelectObject( ::hDCMem, ::hOldBmp )
DeleteDC( ::hDCMem )

::hDCMem  := nil


Return nil

************************************************
      METHOD SaveScreen( hDC, nTop, nLeft )
************************************************

::BeginPaint()

StretchBlt( ::hDCMem, nLeft, nTop, ::nWidth, ::nHeight,;
            hDC, nLeft, nTop, ::nWidth, ::nHeight, SRCCOPY )


::EndPaint()

Return nil

************************************************
  METHOD FastPaint( hDC, nTop, nLeft )
************************************************

  if ::hBmp2 == 0
     PalBmpDraw( hDC, nLeft, nTop, ::hBmp, ::hPal, ::nWidth, ::nHeight, SRCCOPY )
  else
     PalBmpDraw( hDC, nLeft, nTop, ::hBmp2, ::hPal2, ::nWidth, ::nHeight, SRCPAINT )
     PalBmpDraw( hDC, nLeft, nTop, ::hBmp , ::hPal, ::nWidth, ::nHeight, SRCAND   )
  endif

return nil

function pBmpWidth( hbitmap )
return nBmpWidth( hbitmap )

function pBmpHeight( hbitmap )
return nBmpHeight( hbitmap )
