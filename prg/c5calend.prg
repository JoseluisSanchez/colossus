/*
ÚÄ Programa ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   Aplication: class TCalendar                                            ³
³         File: CALENDAR.PRG                                               ³
³       Author: Francisco Garc¡a Fern ndez                                 ³
³     Internet: http://www.arrakis.es/~canal_five/                         ³
³     Internet: http://come.to/canalfive                                   ³
³       E-Mail: canalfive@solution4u.com                                   ³
³         Date: 10-MAR-1998                                                ³
³         Time: 23:52:00                                                   ³
³      Version: 1.0c                                                       ³
³    Copyright: 1998 by Francisco Garc¡a Fern ndez                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "fivewin.ch"
#include "c5bmp.ch"

#define SRCCOPY    13369376

#define AENGLISHHDR  {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"}
#define ASPANISHHDR  {"Lunes","Martes","Miercoles","Jueves","Viernes","Sabado","Domingo"}

#define COLOR_ACTIVECAPTION        2
#define COLOR_INACTIVECAPTION      3
#define COLOR_INACTIVECAPTIONTEXT 19


#define FILAS    6
#define COLUMNAS 7
#define TRANSPARENT  1
*#define CLR_WHITE nRGB( 255, 255, 254)

#define SEGUNDOS 1000


#define ALINEACION {32,33,34,36,37,38,40,41,42,0,16,17}
#define CALIGN {"TOP_LEFT","TOP_CENTER","TOP_RIGHT",;
                "LEFT","CENTER","RIGHT",;
                "BOTTOM_LEFT","BOTTOM_CENTER","BOTTOM_RIGHT",;
                "PLAIN","MULTILINE","MULTICENTER"}


#define GW_HWNDNEXT        2
#define GW_CHILD           5
#define GWW_INSTANCE      -6

static nToolTip := 0
static cOldMsg  := ""

extern GetTextWidth


CLASS TCalendar FROM TControl

      // Register the colors and leave in your site the index in the aColors array

      CLASSDATA lTooltips
      CLASSDATA oToolTip

      DATA aClrDays
      DATA aColors
      DATA aHeader
      DATA aPrompts

      CLASSDATA aBmps
      DATA cInfo

      DATA acTooltips
      DATA acMsg

      DATA bAction

      DATA dDate

      DATA l3D
      DATA lBold
      DATA lBorder
      DATA lClrSundays
      DATA lDesignable
      DATA lEurop
      DATA lGrid
      DATA lHeader
      DATA lKillFont
      DATA lHdrOwn
      DATA lChange

      DATA nAjuste
      DATA cAlignBmp
      DATA nAlignPro
      DATA nMrgAlign
      DATA nChars

      DATA nClrDer                     // Color for l3D
      DATA nClrDerO                    // Color for l3D for option
      DATA nClrIzq                     // Color for l3D
      DATA nClrIzqO                    // Color for l3D for option
      DATA nClrLines                   // Color for grid lines
      DATA nClrP                       // Default Colors for text and pane
      DATA nClrPHeader                 // text and pane for headers
      DATA nClrPNoOp
      DATA nClrPOption                 // Text and pane for option
      DATA nClrT                       // Default Colors for text and pane
      DATA nClrTHeader                 // text and pane for headers
      DATA nClrTNoOp
      DATA nClrTOption                 // Text and pane for option
      DATA nEditKey

      DATA nCols
      DATA nDays
      DATA nHItem
      DATA nIni
      DATA nLen
      DATA nMaxLen
      DATA nOption
      DATA nRCol
      DATA nRFila
      DATA nRows
      DATA nWItem

      DATA oCanvas
      DATA oFont2
      DATA oSmallFont

      DATA nOldOption

      CLASSDATA oMainOfGroup

      CLASSDATA lEditing    AS LOGICAL INIT .F.
      CLASSDATA lRegistered AS LOGICAL
      CLASSDATA lPaintOpFoc

      DATA oGet

      DATA oOut  READONLY
      DATA nTime READONLY AS NUMERIC INIT 0


      METHOD New( nTop, nLeft, nWidth, nHeight, oWnd,;
                  dDate,;
                  oFont, nClrText, nClrPane, nClrLines,;
                  nClrTOption, nClrPOption, ;
                  bAction, lBorder, lBold, lEurop, lGrid,;
                  cAjuste,  lHeader, aHeader,;
                  nClrPHeader, nClrTHeader, lClrSundays,;
                  aPrompts, bChange, cAlignBmp, cAlignPro ) CONSTRUCTOR

      METHOD Redefine( oWnd, nId, dDate,;
                  oFont, nClrText, nClrPane, nClrLines,;
                  nClrTOption, nClrPOption, ;
                  bAction, lBorder, lBold, lEurop, lGrid,;
                  cAjuste,  lHeader, aHeader,;
                  nClrPHeader, nClrTHeader, lClrSundays,;
                  aPrompts, bChange, cAlignBmp, cAlignPro   ) CONSTRUCTOR




      METHOD AdjClient  ()
      METHOD Adjust     ( lClient )

      METHOD Build      ()

      METHOD Change     ( dDate, lRefresh )
      METHOD CurrentDay ()

      METHOD Default    ()
      METHOD Destroy    ()
      METHOD Display    () INLINE ::BeginPaint(),::Paint(),::EndPaint(),0

      METHOD GetCellDay ( nCell )
      METHOD GetDayCell ( nDay  )
      METHOD GetCoors   ( nCell )
      METHOD GetDay     ( nRow, nCol )
      METHOD GetDlgCode ( nLastKey )
      METHOD GetOption  ( nRow, nCol )
      METHOD GetPColor  ( nItem )
      METHOD GetTColor  ( nItem )
      METHOD GetValue   ( nDay )
      METHOD SetValue   ( nDay, nBmp )
      METHOD GotFocus   () INLINE Super:GotFocus(),;
                  ::lFocused := .t. ,;
                  ::GetDC(),;
                  ::PaintOption(),;
                  ::ReleaseDC()

      METHOD IncDate    ( dDate, nDia, nMes, nYear )

      METHOD Init    ( hDlg ) INLINE Super:Init    ( hDlg ), ::Default()
      METHOD Initiate( hDlg ) INLINE Super:Initiate( hDlg ), ::Default()

      METHOD KeyDown    ( nKey, nFlags )

      METHOD LButtonDown( nRow, nCol, nKeyFlags )
      METHOD LDblClick  ( nRow, nCol, nKeyFlags, nItem )
      METHOD LostFocus( hWndGetFocus )

      METHOD MouseMove  ( nRow, nCol, nKeyFlags )

      METHOD Paint      ( lRefresh )
      METHOD PaintItem  ( nItem, hDC, lPaintOp )
      METHOD PaintOption()

      METHOD RButtonDown( nRow, nCol, nKeyFlags )
      *METHOD Refresh    () INLINE ::Paint( .t. )
      METHOD RegisBmp   ( cBmp )
      METHOD RegisColor ( nColor, lBrush, lPen )

      METHOD Set2Date   ( dDay, nDia, nMes, nYear )
      METHOD Set2Day    ( nDay, cBmp, cTooltip, cMsg )
      METHOD Add2Day    ( nDay, cTooltip, lNewLine )
      METHOD SetClr2Day ( nDay, nClrText, nClrPane )
      METHOD SetOption  ( nOption, lAction )
      METHOD SetSundays ( nClrText, nClrPane )
      METHOD SpDow      ( nDay ) INLINE if( nDay == 1, 7, nDay - 1 )

      METHOD ToMes  ( nMes )
      METHOD ToYear ( nYear )
      METHOD ProcesKey( nKey )


ENDCLASS

*******************************************************
 METHOD New( nTop, nLeft, nWidth, nHeight, oWnd,;
            dDate,;
            oFont, nClrText, nClrPane, nClrLines,;
            nClrTOption, nClrPOption, ;
            bAction, lBorder, lBold, lEurop, lGrid,;
            cAjuste,  lHeader, aHeader,;
            nClrPHeader, nClrTHeader, lClrSundays,;
            aPrompts, bChange, cAlignBmp, cAlignPro )
********************************************************

       Local n, cFormat

       DEFAULT nClrText    := CLR_BLACK        ,;
               nClrPane    := RGB( 255,255,254),;
               nClrLines   := CLR_HGRAY        ,;
               nClrTOption := CLR_YELLOW       ,;
               nClrPOption := GetSysColor( COLOR_ACTIVECAPTION  ) ,;
               lBorder     := .t.              ,;
               lBold       := .f.              ,;
               lEurop      := .t.              ,;
               lGrid       := .f.              ,;
               cAjuste     := "CENTER"         ,;
               lHeader     := .f.              ,;
               nClrPHeader := CLR_GRAY         ,;
               nClrTHeader := CLR_WHITE        ,;
               lClrSundays := .f.              ,;
               cAlignBmp   := "BOTTOM_RIGHT"   ,;
               cAlignPro   := "BOTTOM_LEFT"    ,;
               dDate       := date()



       ::nTop         := nTop
       ::nLeft        := nLeft
       ::nBottom      := nTop  + nHeight - 1
       ::nRight       := nLeft + nWidth  - 1
       ::oWnd         := oWnd

       ::aColors      := {}

       if lHeader
          if empty( aHeader )
             ::lHdrOwn  := .f.
             ::aHeader     := if( !lEurop, AENGLISHHDR, ASPANISHHDR)
          else
             ::lHdrOwn  := .t.
             ::aHeader      := aHeader
          endif
       endif

       ::aPrompts := afill( array( 31 ), nil )

       if aPrompts != nil
          for n := 1 to len( aPrompts )
              if aPrompts[ n ] != nil
                 ::aPrompts[ n ] := aPrompts[ n ]
              endif
          next n
       endif

       if ::aBmps == nil
          ::aBmps        := {}
       endif

       ::cInfo        := space( 31 )

       ::acTooltips   := array( 31 )
       ::acMsg        := array( 31 )
       ::cAlignBmp    := cAlignBmp
       ::nMrgAlign    := 3

       ::bAction      := bAction
       ::bChange      := bChange
       ::dDate        := dDate

       ::nDays   := nDaysMonth( ::dDate )

       ::aClrDays := array( ::nDays )

       for n := 1 to ::nDays

           ::aClrDays[ n ] := { nClrText, nClrPane, .f. }

       next n

       ::l3D          := .f.
       ::lBold        := lBold
       ::lBorder      := lBorder
       ::lClrSundays  := lClrSundays
       ::lDesignable  := .f.
       ::lEurop       := lEurop
       ::lGrid        := lGrid
       ::lHeader      := lHeader
       ::lTooltips    := .t.
       ::lChange      := .t.

       if ::lPaintOpFoc == nil
          ::lPaintOpFoc  := .t.
       endif

       ::nAjuste      := ALINEACION[ ascan( CALIGN, cAjuste ) ]
       ::nAlignPro    := ALINEACION[ ascan( CALIGN, cAlignPro ) ]
       ::nClrDer      := CLR_GRAY
       ::nClrIzq      := CLR_WHITE
       ::nClrIzqO     := ::nClrDer
       ::nClrDerO     := ::nClrIzq
       ::nClrP        := nClrPane
       ::nClrPHeader  := nClrPHeader
       ::nClrPOption  := nClrPOption
       ::nClrT        := nClrText
       ::nClrTHeader  := nClrTHeader
       ::nClrTOption  := nClrTOption
       ::nCols        := COLUMNAS
       ::nId          := ::GetNewId()
       ::nOption      := day( dDate )
       ::nRows        := if( lHeader, FILAS + 1, FILAS )
       ::nOldOption   := 0

       if ::lGrid
          ::nClrLines := nClrLines
       else
          ::nClrLines := ::nClrP
       endif

       cOldMsg        := ::cMsg

       ::SetColor( nClrText, nClrPane )

       if oFont == nil
          DEFINE FONT ::oFont  NAME "Ms Sans Serif" SIZE 5, 13
          ::lKillFont    := .t.
       else
          ::oFont := oFont
          ::lKillFont    := .f.
       endif

       //DEFINE FONT ::oFont2 NAME ::oFont:cFaceName SIZE ::oFont:nWidth, ::oFont:nHeight ;
       //       BOLD
		 ::oFont2 := TFont():New(GetDefaultFontName(),0,GetDefaultFontHeight(),,.t.,,,,)

       DEFINE FONT ::oSmallFont NAME "Small Fonts" SIZE 0, -9

       ::nStyle    = nOR( WS_CHILD, WS_VISIBLE, WS_CLIPSIBLINGS,;
                          WS_CLIPCHILDREN, WS_TABSTOP )

       ::Register( nOR( CS_VREDRAW, CS_HREDRAW ) )

       if ! Empty( oWnd:hWnd )
          ::Create()
          ::Default()
          oWnd:AddControl( Self )
       else
          oWnd:DefControl( Self )
       endif

return self

**************************************************************
METHOD Redefine( oWnd, nId, dDate,;
                  oFont, nClrText, nClrPane, nClrLines,;
                  nClrTOption, nClrPOption, ;
                  bAction, lBorder, lBold, lEurop, lGrid,;
                  cAjuste,  lHeader, aHeader,;
                  nClrPHeader, nClrTHeader, lClrSundays,;
                  aPrompts, bChange, cAlignBmp, cAlignPro  )
**************************************************************

       Local n, cFormat

       DEFAULT cAjuste     := "CENTER"               ,;
               dDate       := Date()                 ,;
               lBold       := .f.                    ,;
               lBorder     := .t.                    ,;
               lClrSundays := .f.                    ,;
               lEurop      := .t.                    ,;
               lGrid       := .f.                    ,;
               lHeader     := .f.                    ,;
               nClrLines   := CLR_HGRAY              ,;
               nClrPHeader := CLR_GRAY               ,;
               nClrPOption := GetSysColor( COLOR_ACTIVECAPTION  )       ,;
               nClrPane    := RGB( 255,255,254)      ,;
               nClrTHeader := CLR_WHITE              ,;
               nClrTOption := CLR_YELLOW             ,;
               cAlignBmp   := "BOTTOM_RIGHT"         ,;
               cAlignPro   := "BOTTOM_LEFT"          ,;
               nClrText    := CLR_BLACK


       ::aColors     := {}

       if lHeader
          if empty(aHeader)
             ::lHDrOwn  := .f.
             ::aHeader     := if( !lEurop, AENGLISHHDR, ASPANISHHDR)
          else
             ::lHdrOwn  := .t.
             ::aHeader      := aHeader
          endif
       endif

       ::aPrompts := afill( array( 31 ), nil )

       if aPrompts != nil
          for n := 1 to len( aPrompts )
              if aPrompts[ n ] != nil
                 ::aPrompts[ n ] := aPrompts[ n ]
              endif
          next n
       endif

       ::bAction     := bAction
       ::bChange     := bChange
       ::dDate       := dDate

       ::nDays   := nDaysMonth( ::dDate )
       ::aClrDays := array( ::nDays )

       if ::aBmps == nil
          ::aBmps := {}
       endif

       ::cInfo        := space( 31 )

       ::acTooltips   := array( 31 )
       ::acMsg        := array( 31 )
       ::cAlignBmp    := cAlignBmp
       ::nMrgAlign    := 3

       for n := 1 to ::nDays

           ::aClrDays[ n ] := { nClrText, nClrPane, .f. }

       next n

       ::l3D         := .f.
       ::lBold       := lBold
       ::lBorder     := lBorder
       ::lClrSundays := lClrSundays
       ::lDesignable := .f.
       ::lEurop      := lEurop
       ::lGrid       := lGrid
       ::lHeader     := lHeader
       ::lTooltips   := .t.
       ::lChange      := .t.

       if ::lPaintOpFoc == nil
          ::lPaintOpFoc  := .t.
       endif

       ::nAjuste     := ALINEACION[ ascan( CALIGN, cAjuste ) ]
       ::nAlignPro   := ALINEACION[ ascan( CALIGN, cAlignPro ) ]
       ::nClrDer     := CLR_GRAY
       ::nClrIzq     := CLR_WHITE
       ::nClrIzqO    := ::nClrDer
       ::nClrDerO    := ::nClrIzq
       ::nClrP       := nClrPane
       ::nClrPHeader := nClrPHeader
       ::nClrPOption := nClrPOption
       ::nClrT       := nClrText
       ::nClrTHeader := nClrTHeader
       ::nClrTOption := nClrTOption
       ::nCols       := COLUMNAS
       ::nId         := nId
       ::nOption     := day( dDate )
       ::nRows       := if( lHeader, FILAS + 1, FILAS )
       ::oWnd        := oWnd
       ::nOldOption   := 0

       if ::lGrid
          ::nClrLines := nClrLines
       else
          ::nClrLines := ::nClrP
       endif

       ::SetColor( nClrText, nClrPane )

       if oFont == nil
          DEFINE FONT ::oFont  NAME "Ms Sans Serif" SIZE 5, 13
          ::lKillFont := .t.
       else
          ::oFont := oFont
          ::lKillFont := .f.
       endif

       //DEFINE FONT ::oFont2 NAME ::oFont:cFaceName SIZE ::oFont:nWidth, ::oFont:nHeight ;
       //       BOLD
		 ::oFont2 := TFont():New(GetDefaultFontName(),0,GetDefaultFontHeight(),,.t.,,,,)

       DEFINE FONT ::oSmallFont NAME "Small Fonts" SIZE 0, -9

       ::Register( nOR( CS_VREDRAW, CS_HREDRAW ) )

       oWnd:DefControl( Self )

return self

**************************************
   METHOD Build()
**************************************
Local hDC
Local nCell
Local nFila, nCol
Local nTop, nLeft, nBottom, nRight
Local nHeight, nWidth
Local hOldPen
Local hBlack

nHeight := ::nHeight
nWidth  := ::nWidth


if ::oCanvas != nil
   ::oCanvas:Destroy()
endif

::GetDC()

DEFINE MEMORY BITMAP ::oCanvas SIZE nWidth, nHeight ;
              COLOR ::nClrPane OF Self

DRAWBEGIN ::oCanvas IN ::hDC

   hDC := ::oCanvas:hDCMem


   For nCell := 1 to ( ( FILAS + 1 ) * COLUMNAS )

       ::PaintItem( nCell, hDC, .f. )

   next


   hOldPen   := SelectObject( hDC, ::aColors[ ::nClrLines, 3 ] )

   If ::lGrid

      For nFila :=  0 to FILAS + 1

          Moveto( hDC,      0, ( nFila * ::nHItem )  )
          Lineto( hDC, nWidth, ( nFila * ::nHItem )  )

      next nFila


      For nCol := 0 to COLUMNAS + 1

          Moveto( hDC, ( nCol * ::nWItem ),  0       )
          Lineto( hDC, ( nCol * ::nWItem ), nHeight  )

      next nCol

   endif


   SelectObject ( hDC, hOldPen   )

   hOldPen := SelectObject( hDC, GetStockObject( 7 ) )

   if ::lBorder

      Moveto( hDC,            0,             0)
      Lineto( hDC, ::nWidth - 1,             0)
      Lineto( hDC, ::nWIdth - 1, ::nHeight - 1)
      Lineto( hDC,            0, ::nHeight - 1)
      Lineto( hDC,            0,             0)

   endif

   SelectObject ( hDC, hOldPen   )

DRAWEND ::oCanvas

::ReleaseDC()

return nil


*******************************
 METHOD CurrentDay()
*******************************
Local dateformat := set( _SET_DATEFORMAT, "dd-mm-yyyy" )

*::dDate :=  ctod( strtran( str( ::nOption, 2 )," ","0") +;
*                  substr( dtoc(::dDate),3))
::dDate :=  ctod( str( ::nOption, 2 ) +;
                  substr( dtoc(::dDate),3))

 set( _SET_DATEFORMAT, dateformat )
return ::dDate


*************************
 METHOD Default()
*************************

  if ::oTooltip == nil
     ::oToolTip := TC5Tip():New( Self )
  endif

  ::nHItem :=  int(  ( ::nHeight ) / ::nRows )
  ::nWItem :=  int(  ( ::nWidth  ) / ::nCols )


  if ::lHeader .and. !::lHdrOwn
     if ::GetWidth( "MMMMMMMMM", ::oFont2 ) > ::nWItem
        if ::GetWidth( "MMM", ::oFont2 ) > ::nWItem
           ::nChars := 1
        else
           ::nChars := 3
        endif
     else
        ::nChars := -1
     endif
  else
     ::nChars := -1
  endif

 ::nClrTNoOp  := GetSysColor( COLOR_INACTIVECAPTIONTEXT )
 ::nClrPNoOp  := GetSysColor( COLOR_INACTIVECAPTION )

 ::nClrP       := ::RegisColor( ::nClrP,       .t.     )  // index for Pane Brush
 ::nClrPOption := ::RegisColor( ::nClrPOption, .t.     )  // index for Pane Brush Option
 ::nClrLines   := ::RegisColor( ::nClrLines,   .f., .t.)  // index for Pen Lines
 ::nClrPHeader := ::RegisColor( ::nClrPHeader, .t.     )  // index for Pane Headers
 ::nClrIzq     := ::RegisColor( ::nClrIzq,     .f., .t.) // index for Left  Pen Option 3D
 ::nClrDer     := ::RegisColor( ::nClrDer,     .f., .t.) // index for Right Pen Option 3D
 ::nClrIzqO    := ::RegisColor( ::nClrIzqO,    .f., .t.) // index for Left  Pen Option 3D
 ::nClrDerO    := ::RegisColor( ::nClrDerO,    .f., .t.) // index for Right Pen Option 3D
 ::nClrPNoOp   := ::RegisColor( ::nClrPNoOp,   .t.    )


 ::Change( ::dDate , .f. )

 ::Adjust()

       #ifdef DEMO
          DEFINE TIMER ::oOut INTERVAL  60000 OF ::oWnd ;
                 ACTION (  ::nTime ++, if ( ::nTime == 4,( MsgInfo( OemToAnsi("Version 1.0 Calendar ( Demostration )." + CRLF + "CanalFive-97" + CRLF + "C4Calend.lib" + CRLF +"End of demostration") ),::Destroy()),))
          ACTIVATE TIMER ::oOut
       #endif

return nil



***************************
 METHOD Paint()
***************************

::nLen := ::nRows * ::nCols

::GetDC()

 @ 0, 0 DRAW ::oCanvas IN ::hDC

if ::lFocused .or. ::lPaintOpFoc
   ::PaintOption()
endif


::ReleaseDC()


return nil

**************************************************
 METHOD PaintOption()
**************************************************
Local nItem := ::nIni - 1 + day( ::dDate )
Local nTop, nLeft, nBottom, nRight
Local aCoor

if ::lFocused .or. ::lPaintOpFoc

   ::PaintItem( nItem, ::hDC, .t. )

   if ::nOldOption != 0 .and. nItem != ::nOldOption

        DRAWBEGIN ::oCanvas IN ::hDC

        aCoor := ::GetCoors( ::nOldOption )
        nTop    := aCoor[ 1 ]       //
        nLeft   := aCoor[ 2 ]       //

           StretchBlt( ::hDC, nLeft, nTop, ::nWItem , ::nHItem ,;
                 ::oCanvas:hDCMem, nLeft, nTop, ::nWItem , ::nHItem , SRCCOPY )

        DRAWEND   ::oCanvas

   endif

   ::nOldOption := nItem

endif

Return .t.

*****************************************************
 METHOD PaintItem( nCell, hDC, lPaintOp )
*****************************************************

local hOldPen
local nOldColor, nOldMode
local nTop, nLeft, nRight, nBottom
local hOldFont
local hBrush, hOldBrush
local cText
local hIzqPen, hDerPen
local nAjuste
local lEsHdr := .f.
local nBitmap, nX, nY
Local aCoor
Local hOldBmp
Local n
Local nDia := 0
Local nBmp
Local oBmp

DEFAULT lPaintOp := .f.


if !lPaintOp

   nOldMode  := SetBkMode   ( hDC, TRANSPARENT )
   *hOldPen   := SelectObject( hDC, ::aColors[ ::nClrLines, 3 ] )

   nAjuste := ::nAjuste


   if nCell < ::nIni .or. nCell > ::nDays + ::nIni - 1

      // pintamos la cabecera

      IF ::lHeader .and. nCell <= COLUMNAS

         lEsHdr := .t.

         cText  := ::aHeader [ nCell ]

         nAjuste := 37

         if ::nChars > 0
            cText := substr( cText,1,::nChars )
         endif

         nOldColor := SetTextColor( hDC, ::nClrTHeader )
         hBrush    := ::aColors[ ::nClrPHeader, 2]

      else


         cText := ""

         nOldColor := SetTextColor( hDC, ::nClrT )
         hBrush := ::aColors[ ::nClrP, 2 ]

      endif

   else

      // pintamos los dias

      nDia  := ::GetCellDay( nCell )

      cText := ltrim( str( nDia, 2 ) )

      hBrush := ::aColors[ ::GetPColor( nDia ), 2 ]

      nOldColor := SetTextColor    ( hDC, ::GetTColor( nDia )  )

   endif


   hOldFont  := SelectObject( hDC, ::oFont:hFont )
   hOldBrush := SelectObject( hDC, hBrush )

   aCoor := ::GetCoors( nCell )

   if lEsHdr

      nTop    := aCoor[ 1 ]
      nLeft   := aCoor[ 2 ]       - 1
      nBottom := nTop  + ::nHItem - 1
      nRight  := nLeft + ::nWItem + 1

   else

      nTop    := aCoor[ 1 ]
      nLeft   := aCoor[ 2 ]
      nBottom := nTop  + ::nHItem - 1
      nRight  := nLeft + ::nWItem - 1

   endif


   if lEsHdr
      FillRect   ( hDC, { nTop, nLeft, nBottom, nRight }, hBrush )
   else
      FillRect   ( hDC, { nTop, nLeft, nBottom, nRight }, hBrush )
   endif

   DrawText( hDC, cText , { nTop +1, nLeft +1 , nBottom - 1, nRight - 1 }, nAjuste )

   if ::l3D
      hOldPen := SelectObject( hDC, ::aColors[ ::nClrIzq, 3] )
      Moveto( hDC, nLeft     , nBottom     )
      Lineto( hDC, nLeft     , nTop        )
      Lineto( hDC, nRight    , nTop        )
      SelectObject( hDC, hOldPen )
      hOldPen := SelectObject( hDC, ::aColors[ ::nClrDer , 3 ] )
      Moveto( hDC, nRight -1, nTop    + 2 )
      Lineto( hDC, nRight -1, nBottom - 1 )
      Lineto( hDC, nLeft + 1, nBottom - 1 )
      SelectObject( hDC, hOldPen )
   endif

   if nDia != 0

      nBmp := ::GetValue( nDia )

      if nBmp != 0

         oBmp := ::aBmps[ nBmp ]

         oBmp:PaintAlign( hDC, { nTop, nLeft, nBottom, nRight}, ::cAlignBmp )

      endif

      if nDia != 0 .and. ::aPrompts[ nDia ] != nil

         SelectObject ( hDC, hOldFont  )
         hOldFont := SelectObject( hDC, ::oSmallFont:hFont )

         DrawText( hDC, ::aPrompts[ nDia ] , { nTop + 1, nLeft +1 , nBottom - 1, nRight - 1 }, ::nAlignPro )

      endif

   endif

   SetBkMode    ( hDC, nOldMode  )
   SelectObject ( hDC, hOldBrush )
   SelectObject ( hDC, hOldFont  )

else
   * ESTAMOS PINTANDO LA OPCION

   nOldMode  := SetBkMode   ( hDC, TRANSPARENT )

   nAjuste := ::nAjuste

   nDia  := ::GetCellDay( ncell )

   cText :=  ltrim(str( ndia, 2 ))

   hBrush := ::aColors [ if( ::lFocused,::nClrpOption,::nClrPnOop ), 2 ]

   nOldColor := SetTextColor    ( hDC, if( ::lFocused,::nClrtOption,::nClrTnOop ) )

   if ::lBold
       hOldFont  := SelectObject( hDC, ::oFont2:hFont )
   else
       hOldFont  := SelectObject( hDC, ::oFont:hFont )
   endif

   hOldBrush := SelectObject( hDC, hBrush )

   aCoor := ::GetCoors( nCell )

   nTop    := aCoor[ 1 ]
   nLeft   := aCoor[ 2 ]
   nBottom := nTop  + ::nHItem - 1
   nRight  := nLeft + ::nWItem - 1

   //FillRect   ( hDC, { nTop    ,;
   //                    nLeft   ,;
   //                    nBottom  ,;
   //                    nRight    }, hBrush )
	GradientFill( hDC, nTop, nLeft, nBottom, nRight, { { 1, RGB( 220, 235, 252 ), RGB (194, 219, 252) } }, .T. )
	// RoundBox( hDC, 1, aRect[1], aRect[4]-aRect[1]-1, aRect[ 3 ], 2, 2, nColor, 1 )
	RoundBox( hDC, nLeft, nTop-1, nRight, nBottom+1, 2, 2, RGB( 125, 162, 206 ), 1 )

   if ::l3D
      DrawText( hDC, cText , { nTop + 2, nLeft +2 , nBottom , nRight }, nAjuste )
   else
      DrawText( hDC, cText , { nTop +1, nLeft +1 , nBottom - 1, nRight - 1 }, nAjuste )
   endif


   if ::l3D

      hOldPen := SelectObject( hDC, ::aColors[ ::nClrIzqO, 3] )

      Moveto( hDC, nLeft     , nBottom     )
      Lineto( hDC, nLeft     , nTop        )
      Lineto( hDC, nRight    , nTop        )

      SelectObject( hDC, hOldPen )

      *hOldPen := SelectObject( hDC, ::aColors[ if( lPaintOp, ::nClrDerO,::nClrDer ), 3] )

   endif

   if nDia != 0

      nBmp := ::GetValue( nDia )

      if nBmp != 0

         oBmp := ::aBmps[ nBmp ]

         oBmp:PaintAlign( hDC, { nTop, nLeft, nBottom, nRight}, ::cAlignBmp )

      endif

      if nDia != 0 .and. ::aPrompts[ nDia ] != nil

         SelectObject ( hDC, hOldFont  )
         hOldFont := SelectObject( hDC, ::oSmallFont:hFont )

         DrawText( hDC, ::aPrompts[ nDia ] , { nTop + 1, nLeft +1 , nBottom - 1, nRight - 1 }, ::nAlignPro )

      endif

   endif

   SetBkMode    ( hDC, nOldMode  )
   SelectObject ( hDC, hOldBrush )
   SelectObject ( hDC, hOldFont  )



endif
Sysrefresh()

return nil




*********************************************
 METHOD LButtonDown( nRow, nCol, nKeyFlags )
*********************************************

Local nItem := ::nOption
Local nCell, nDia

Local aCoor

if ::lEditing
   return super: lButtonDown( nRow, nCol, nKeyFlags )
endif


SetFocus( ::hWnd )

aCoor  := ::GetDay( nRow, nCol )

nDia   := aCoor[ 1 ]
nCell  := aCoor[ 2 ]


* nItem es el dia
* nCell es la celdilla

if nCell     > ::nDays         + ::nIni - 1 .or. ;
   nCell     < ::nIni                       .or. ;
   nItem == nCell - ::nIni + 1

   Return nil

endif

::SetOption( nDia )

Return nil
***********************************************
 METHOD RButtonDown( nRow, nCol, nKeyFlags )
***********************************************
Local oMenu
Local oThis := Self

if ::lEditing
   return super: RButtonUp( nRow, nCol, nKeyFlags )
endif

MENU oMenu POPUP
  MENUITEM if ( oThis:lTooltips, "No Tooltips","Tooltips") ;
           ACTION ( oThis:lTooltips := if( oThis:lTooltips,.f.,.t.) ,;
                    oThis:Refresh() )
ENDMENU
ACTIVATE MENU oMenu AT nRow, nCol OF oThis

return nil



****************************************************
   METHOD LDblClick( nRow, nCol, nKeyFlags, nEn )
****************************************************
local dDate
local lEnDia
Local cVar, nTop, nLeft, nWidth, nHeight
Local oThis := Self
Local aCoor
Local bOldValid := ::oWnd:bValid
Local cOldVar


if nEn == nil
   nEn := ::GetOption ( int ( nRow / ( (::nHeight ) / ::nRows ) ) + 1 ,;
                           int ( nCol / ( (::nWidth  ) / ::nCols ) ) + 1 )
endif


lEndia := if ( nEn < ::nIni .or. nEn > ::nIni + ::nDays - 1, .f.,.t.)


dDate := ::CurrentDay()

     if lEndia

        if ( GetKeyToggle( VK_SCROLL ) .AND. ::lDesignable ) .or.;
           ( ::nEditKey != nil .and. ::lEditing == .t. )

           aCoor := ::GetCoors( nEn )

           ::lEditing := .t.

           nTop     := aCoor[1]
           nLeft    := aCoor[2]
           nWidth   := ::nWItem - 2
           nHeight  := ::nHItem - 2

           cVar     := padr( if( empty( ::aPrompts[ ::nOption ] ) , space(255), ::aPrompts[ ::nOption ] ),255)
           cOldVar  := cVar


           if ::oGet != nil .AND. ! Empty( ::oGet:hWnd )
              ::oGet:End()
           endif

           ::oWnd:bValid := {||.f.}

           ::oSmallFont:nCount ++

           @ nTop, nLeft GET ::oGet VAR cVar OF Self    ;
                  FONT ::oSmallFont                     ;
                  MULTILINE                             ;
                  SIZE nWidth  , nHeight NOBORDER ;
                  COLOR ::nClrText, ::nClrPane - 200 PIXEL

           ::nLastKey := 0
           ::oGet:SetFocus()

   ::oGet:bLostFocus := {|| ::aPrompts[ ::nOption ] := ::oGet:cText,;
                            ::Build(),;
                            ::oGet:End(), ::oWnd:bValid := bOldValid }

   ::oGet:bKeyDown := { | nKey | If( ( nKey == VK_RETURN .and. ::nAlignPro > 17 ) .or. ;
                                     nKey == VK_ESCAPE,;
                        ( Self:nLastKey := nKey, ::oGet:End() ), ) }


        ::lEditing := .f.


        else
           if ::bAction != nil
              return Eval( ::bAction,  dDate, nRow, nCol )
           endif
        endif
     endif

return nil

********************************
 METHOD KeyDown( nKey, nFlags )
*********************************

local nItem := ::nOption

Local nDia, nMes, nYear, dDia

Local nAux

nAux := nItem

do case
   case nKey == VK_DOWN

        nItem += 7


   case nKey == VK_RIGHT

        nItem ++


   case nKey == VK_UP

        nItem -= 7


   case nKey == VK_LEFT

        nItem --

   case nKey == VK_HOME


        nItem := 1


   case nKey == VK_END

        nItem := ::nDays

   case ::nEditKey != nil .and. nKey == ::nEditKey

        ::lEditing := .t.
        * 14-01-1998 hay que sumarle el d¡a de inicio de la semana
        *::lDblClick( ,,, nItem + if( ::lHeader,7,0)+ if(::lEurop,0,1) )
        ::lDblClick( ,,, nItem + ::nIni - 1   )

   case nKey == VK_RETURN

        if  GetKeyToggle( VK_SCROLL ) .AND. ::lDesignable
           * 14-01-1998 hay que sumarle el d¡a de inicio de la semana
           *::lDblClick( ,,, nItem + if( ::lHeader,7,0)+ if(::lEurop,0,1)  )
            ::lDblClick( ,,, nItem + ::nIni - 1   )

        else
           ::SetOption( nItem, .t. )
        endif

   otherwise

        Return Super:KeyDown( nKey, nFlags )

endcase


if nItem < 1
   nItem := 1
endif

if nItem > ::nDays
   nItem := ::nDays
endif

if nItem == nAux
   Return 0
endif


::SetOption ( nItem )

Return 0

********************************
 METHOD GetCoors( nCell )
********************************
Local nTop  := (int( ( nCell - 1 ) / 7 ) * ::nHItem ) + if( ::lGrid, 1, 0)
Local nLeft := (( ( ( nCell - 1 ) % 7 ) * ::nWItem )) + if( ::lGrid, 1, 1)
* v 1.0c 10-03-98 )) + if( ::lGrid, 1, 0)  Se debe sumar uno de todas formas

return { nTop, nLeft }



**********************************
 METHOD GetDlgCode( nLastKey )
**********************************

   // This method is very similar to TControl:GetDlgCode() but it is
   // necessary to have WHEN working

   if .not. ::oWnd:lValidating
      if nLastKey == VK_UP .or. nLastKey == VK_DOWN ;
         .or. nLastKey == VK_RETURN .or. nLastKey == VK_TAB
         ::oWnd:nLastKey = nLastKey
      else
         ::oWnd:nLastKey = 0
      endif
   endif

return DLGC_WANTALLKEYS

**************************************
 METHOD SetOption( nOption, lAction )
**************************************

local nItem := ::nOption

DEFAULT lAction := .f.

::nOption := nOption

::CurrentDay()

::GetDC()
::PaintOption()
::ReleaseDC()

if ::acMsg[ ::nOption ] != nil
   ::SetMsg( ::acMsg[ ::nOption ] )
else
   ::SetMsg()
endif

if lAction
   if ::bAction != nil
      return eval( ::bAction, ::dDate )
   endif
endif

if ::bChange != nil
   return eval ( ::bChange, ::nOption, ::dDate )
endif


Return nil

************************************
 METHOD AdjClient  ()
************************************
Local aRectC, aRect
Local nWCli, nHCli
Local nTop, nLeft

 Super:AdjClient()

    ::Adjust( .t. )

    ::Refresh()

Return nil






**********************
 METHOD Adjust( lClient )
**********************

Local nFilas, nColumnas
Local nTop, nLeft, nBottom, nRight

Local nHeight, nWidth
Local aRect

DEFAULT lClient := .f.

nHeight := ::nHeight
nWidth  := ::nWidth

::nLen := ::nRows * ::nCols


if lClient

   aRect :=  GetClientRect( ::oWnd:hWnd )


   ::Move( 1 +(( ( aRect [ 3 ] - aRect[ 1 ] ) - nHeight ) / 2),;
           1 +(( ( aRect [ 4 ] - aRect[ 2 ] ) - nWidth  ) / 2),,,.t. )

   ::nHItem :=  int(  (::nHeight - 1) / ::nRows )
   ::nWItem :=  int(  (::nWidth  - 1) / ::nCols )

else

   ::nHItem :=  int(  ::nHeight  / ::nRows )
   ::nWItem :=  int(  ::nWidth   / ::nCols )

   ::SetSize( (::nCols * ::nWItem) + 1 , (::nRows * ::nHItem) + 1 , .t. )

endif

if ::lHeader .and. !::lHdrOwn
   if ::GetWidth( "MMMMMMMMM", ::oFont2 ) > ::nWItem
      if ::GetWidth( "MMM", ::oFont2 ) > ::nWItem
         ::nChars := 1
      else
         ::nChars := 3
      endif
   else
      ::nChars := -1
   endif
else
   ::nChars := -1
endif

::Build()



return nil


*******************************************
 METHOD MouseMove( nRow, nCol, nKeyFlags )
*******************************************

Local nItem := ::nOption
Local nCell
Local aPos, hOldFont
Local nDia, dDate
Local nRCol, nRFila
Local nReturn
Local nTop, nLeft, nBottom, nRight
Local aCoor, aCoor2
Local cFormat
Local cTooltip

  cFormat := set( _SET_DATEFORMAT, "dd-mm-yyyy" )

Super:MouseMove( nRow, nCol, nKeyFlags )

aCoor  := ::GetDay( nRow, nCol )

nDia   := aCoor[ 1 ]
nCell  := aCoor[ 2 ]

 if IsOverWnd( ::hWnd, nRow, nCol )
    if !::lCaptured
       ::Capture()
    endif
 else
    if !::lCaptured
       ReleaseCapture()
    endif
 endif



if nDia >= 1 .and. nDia <= ::nDays

   dDate :=  ctod( strzero ( nDia,2) + substr( dtoc(::dDate),3))

   *::oWnd:cTitle := dtoc( dDate )

   if ::acMsg[ nDia ] != nil
      ::cMsg := ::acMsg[ nDia ]
      ::SetMsg( ::acMsg[ nDia ] )
   else
      ::cMsg := ""
      ::SetMsg( "" )
   endif

   if nCell != nToolTip


       if ::acTooltips[ nDia ] != nil .and. IsOverWnd( ::hWnd, nRow, nCol )

         aCoor2 := ::GetCoors( nCell )

         nTop    := aCoor2[ 1 ]
         nLeft   := aCoor2[ 2 ]
         nBottom := aCoor2[ 1 ] + ::nHItem
         nRight  := aCoor2[ 2 ] + ::nWItem

         if ::lTooltips
            if ::oToolTip != nil
               ::oToolTip:Show( nBottom - 6, nRight - 6, ::acTooltips[ nDia ], Self )
            endif
         endif

       else

         If ::oToolTip != nil

            If ::oToolTip:lVisible
               ::oToolTip:Hide()
            endif

         endif

         if !::lCaptured
            ::lCaptured := .f.
            ReleaseCapture()
         endif

       endif

       nToolTip := nCell

   endif


endif

  set( _SET_DATEFORMAT, cFormat )

Return 0

********************************************************
  METHOD GetDay( nRow, nCol )
********************************************************
 Local nSemana, nDia
 Local nDay, nCell

 nSemana := int( nRow / ::nHItem ) + 1
 nDia    := int( nCol / ::nWItem ) + 1

 nCell   := ( ( nSemana - 1 ) * 7 ) + nDia


 nDay := nCell - ::nIni + 1

return { nDay, nCell }

********************************************************
  METHOD GetCellDay( nCell )
********************************************************
//devuelve dia de una celda

return nCell - ::nIni + 1

*************************************
   METHOD GetDayCell ( nDay  )
*************************************
// devuelve una celda de un dia

return ::nIni + nDay - 1


********************************************************
      METHOD GetOption( nRow, nCol )
********************************************************

 Return  (( nRow - 1 ) * ::nCols ) + nCol




******************************************
      METHOD GetPColor( nDay )
******************************************

Return ::RegisColor( ::aClrDays[ nDay, 2 ], .t. )


******************************************
      METHOD GetTColor( nDay )
******************************************

Return ::aClrDays[ nDay, 1 ]



**********************************************************
  METHOD SetClr2Day ( nDay, nClrText, nClrPane )
**********************************************************
Local nEn
Local hDC

if nDay == nil .or. nDay > ::nDays .or. nDay < 1
   return nil
endif

if nClrText != nil
   ::aClrDays [ nDay, 1 ] := nClrText
endif

if nClrPane != nil
   ::aClrDays [ nDay, 2 ] := nClrPane
endif



if ::oCanvas != nil

   ::GetDC()

   DRAWBEGIN ::oCanvas IN ::hDC

      hDC := ::oCanvas:hDCMem

      ::PaintItem( ::GetDayCell( nDay ), hDC, .f. )

   DRAWEND ::oCanvas

   ::ReleaseDC()

endif

Return nil

**********************************************
  METHOD SetSundays( nClrText, nClrPane )
**********************************************
Local n
Local nMes  := month( ::dDate )
Local nYear := year ( ::dDate )
Local cFormat := set( _SET_DATEFORMAT, "dd-mm-yyyy" )


for n := 1 to ::nDays

    if dow( ctod( strtran( str( n ,2)," ",0) +;
                  "-" + strtran( str( month( ::dDate ), 2)," ",0) +;
                  "-" + strtran( str( year ( ::dDate ), 4)," ",0) ) ) == 1

       ::SetClr2Day( n, nClrText, nClrPane )

    endif

next

set( _SET_DATEFORMAT, cFormat )

return nil




**********************************************
 METHOD Change( dDate, lRefresh ) CLASS TCalendar
**********************************************
Local n, n1, cFormat, nClrP
Local nOldMes, nOldYear
Local lBuild := .f.

DEFAULT lRefresh := .f., dDate := ::dDate


nOldMes  := month( ::dDate )
nOldYear := year( ::dDate )


  ::dDate   := dDate
  ::nDays   := nDaysMonth( ::dDate )

  cFormat := set( _SET_DATEFORMAT, "dd-mm-yyyy" )

  ::nIni    := dow( ctod( "01-" + strtran( str( month( ::dDate ),2)," ",0) +;
               "-" + strtran( str( year( ::dDate ),4 )," ",0) ) )

  set( _SET_DATEFORMAT, cFormat )

       if ::lEurop
          ::nIni := ::spDow( ::nIni )
       endif

       if ::lHeader
          ::nIni += COLUMNAS
       endif


       ::nOption   := day( ::dDate ) //+ ::nIni - 1

       if nOldMes != Month( ::dDate ) .or. nOldYear != Year( ::dDate)

          lBuild := .t.

          ::aClrDays := asize( ::aClrDays, 0 )

          ::aClrDays := array( ::nDays )

          for n := 1 to ::nDays

              ::aClrDays[ n ] := { ::nClrText, ::nClrPane, .f. }

          next n

       endif

       if ::lClrSundays
          ::SetSundays( CLR_HRED )
       endif

       if lBuild
          ::Build()
       endif


if lRefresh
   ::Paint()
endif

Return nil


********************************************
 METHOD IncDate( dDate, nDia, nMes, nYear )
********************************************

Local nXDia, nXMes, nXYear
Local cFormat
Local dDia

if !::lChange
   return nil
endif

::lChange := .f.

cFormat := set( _SET_DATEFORMAT, "dd-mm-yyyy" )
DEFAULT dDate := ::dDate



   nXDia  := day  ( dDate )
   nXMes  := month( dDate )
   nXYear := year ( dDate )


   if nDia != nil

      * 14-01-1998 error. no debe asignar una variable sino devolver una fecha
      * Return := dDate + ( nDia )

      // Return dDate + ( nDia )

      dDia:=dDate + nDia        // Vicente 5-4-98

      set( _SET_DATEFORMAT, cFormat )

      ::Change( dDia, .t.  )

      ::lChange := .t.


      Return dDia

   else

      if nMes != nil

         nXMes := nXMes + ( nMes )

         do case
            case nXMes < 1
                 nXmes := 12
                 nXYear --
            case nXMes > 12
                 nXMes := 1
                 nXYear ++
         endcase

      else

         if nYear != nil

            nXYear := nXYear + ( nYear )

         endif

      endif

   endif

    do while .t.

       dDia :=  ctod(  strtran( str( nXDia,  2)," ",0) +;
                 "-" + strtran( str( nXMes,  2)," ",0) +;
                 "-" + strtran( str( nXYear, 4)," ",0) )

       if empty( dDia )
          nXDia --
       else
          exit
       endif

       dDia := nil

    enddo


set( _SET_DATEFORMAT, cFormat )

::Change( dDia , .t. )

::lChange := .t.

Return dDia


*****************
 METHOD Destroy()
*****************

Local nLen, n

#ifdef DEMO
   ::oOut:Deactivate()
#endif

::oFont2    :End()
::oSmallFont:End()
::oCanvas   :Destroy()

if ::lKillFont
   ::oFont:End()
endif

if ::oToolTip != nil
   ::oToolTip:Destroy()
endif

for n := 1 to Len( ::aColors )

    if ::aColors[ n, 2 ] != nil
       DeleteObject( ::aColors[ n,2 ] )
    endif

    if ::aColors[ n, 3 ] != nil
       DeleteObject( ::aColors[ n,3 ] )
    endif

    sysrefresh()

next

for n := 1 to Len( ::aBmps )

    if ::aBmps[ n ] != nil

       ::aBmps[ n ] :Destroy()

    endif

next n


Return Super:Destroy()

*********************************************
 METHOD Set2Date( dDay, nDia, nMes, nYear )
*********************************************

if empty( dDay )
   dDay := Ns2Date( nDia, nMes, nYear )
   if empty( dDay )
      MsgAlert( "Invalid Date" )
      return nil
   endif
endif

::Change( dDay, .t. )

return nil



**********************************************
 METHOD ToMes( nMes )
**********************************************
Local nXDia, nXMes, nXYear
Local cFormat := set( _SET_DATEFORMAT, "dd-mm-yyyy" )
Local dDia


   nXDia  := day  ( ::dDate )
   nXMes  := nMes
   nXYear := Year( ::dDate )

       dDia :=  Ns2Date( nXDia, nXMes, nXYear )

       if empty( dDia )
          return .f.
       endif

 ::Change( dDia, .t. )

set( _SET_DATEFORMAT, cFormat )

Return .t.



**********************************************
 METHOD ToYear( nYear )
**********************************************

Local nXDia, nXMes, nXYear
Local cFormat := set( _SET_DATEFORMAT, "dd-mm-yyyy" )
Local dDia


   nXDia  := day  ( ::dDate )
   nXMes  := month( ::dDate )
   nXYear := nYear

       dDia :=  ctod(  strtran( str( nXDia,  2)," ",0) +;
                 "-" + strtran( str( nXMes,  2)," ",0) +;
                 "-" + strtran( str( nXYear, 4)," ",0) )

       if empty( dDia )
          return .f.
       endif

 ::dDate := dDia

set( _SET_DATEFORMAT, cFormat )

Return .t.

***********************************************************
 METHOD RegisBmp( cBmp )
***********************************************************
local nEn
local n
local nLen := Len ( ::aBmps )


for n := 1 to nLen
    if ::aBmps[ n ]:cBitmap == cBmp
       nEn := n
       exit
    endif
next

if nEn == nil

   aadd( ::aBmps, TC5Bitmap():New( cBmp, Self, .t.,,,::nMrgAlign ) )

   nEn := len( ::aBmps )

endif

Return nEn






***********************************************************
 METHOD RegisColor( nColor, lBrush, lPen ) CLASS TCalendar
***********************************************************

local nEn
local nReturn
local n
local nLen := Len ( ::aColors )

DEFAULT lBrush := .t., lPen := .f.

for n := 1 to nLen
    if ::aColors[ n, 1 ] == nColor
       nEn := n
       exit
    endif
next

if nEn == nil

   aadd( ::aColors, { nColor,  ,  ,  }  )

   nReturn := len( ::aColors )

   if lBrush
      ::aColors[ nReturn, 2 ] := CreateSolidBrush( nColor )
   endif

   if lPen
      ::aColors[ nReturn, 3 ] := CreatePen( PS_SOLID, 1, nColor )
   endif

else

   if lBrush
      if ::aColors[ nEn, 2 ] == nil
         ::aColors[ nEn, 2 ] := CreateSolidBrush( nColor )
      endif
   endif

   if lPen
      if ::aColors[ nEn, 3 ] == nil
         ::aColors[ nEn, 3 ] := CreatePen( PS_SOLID, 1, nColor )
      endif
   endif

   nReturn := nEn

endif

Return nReturn

**********************************
  METHOD LostFocus(hWndGetFocus )
**********************************

  ::lFocused := .f.

  Super:LostFocus ( hWndGetFocus )

  ::GetDC()

  ::Paint()

  ::ReleaseDC()

return nil


************************************************************
 METHOD Add2Day ( nDay, cTooltip, lNewLine )
************************************************************
Local nCell
Local aCoor, nTop, nLeft, nBottom, nRight
Local oBmp
Local cNewLine := CRLF

DEFAULT lNewLine := .T.

if !lNewLine
   cNewLine := ""
endif



::acTooltips[ nDay ] += cNewLine + cTooltip


   if ::oCanvas != nil


      ::GetDC()

      DRAWBEGIN ::oCanvas IN ::hDC

         nCell   := ::GetDayCell( nDay )

         ::PaintItem( nCell, ::oCanvas:hDCMem, .f. )


      DRAWEND   ::oCanvas

      ::ReleaseDC()

   endif






return nil




return nil
************************************************************
 METHOD Set2Day ( nDay, cBmp, cTooltip, cMsg )
************************************************************
Local nBmp := 0
Local nCell

if cBmp != nil

   nBmp := ::RegisBmp( cBmp )

   ::SetValue( nDay, nBmp )

   if ::oCanvas != nil

      ::GetDC()

      DRAWBEGIN ::oCanvas IN ::hDC

         nCell   := ::GetDayCell( nDay )

         ::PaintItem( nCell, ::oCanvas:hDCMem, .f. )


      DRAWEND   ::oCanvas

      ::ReleaseDC()

   endif

endif

if cTooltip != nil
   ::acTooltips[ nDay ] := cTooltip
endif

if cMsg != nil
   ::acMsg[ nDay ] := cMsg
endif




return nil




**************************************************
 METHOD ProcesKey( nKey )
**************************************************

*if ::nAlignPro > 17
   if nKey == VK_RETURN .or. nKey == VK_ESCAPE
      Self:nLastKey := nKey
      ::oGet:End()
   endif
*else
*   if nKey == VK_ESCAPE
*      oThis:nLastKey := nKey
*      oThis:oGet:End()
*   endif
*endif

return nil

**********************************************
 METHOD GetValue( nDay )
**********************************************
return asc( substr( ::cInfo, nDay, 1 ) ) - 32

**********************************************
 METHOD SetValue( nDay, nBmp )
**********************************************

::cInfo := left( ::cInfo, nDay - 1 ) + chr( nBmp + 32 ) + substr( ::cInfo, nDay + 1 )

return nil




