//  ExplorerBar v1.0 -> 01-06-2004 @CanalFive - Francisco García Fernández
//  consulta@canalfive.com
//  http://www.canalfive.com
//
//  v1.01 - 02/07/2004 modifica medidas al abrir y cerrar en una ventana
//  v1.02 - 02/07/2004 Bug. Hay que evitar pintar ::hBmp nulos FWH lo perimite FWXH no
//  v1.03 - 03/07/2004 Implementación de la cláusula WHEN para los Items
//  v1.04 - 01/08/2004 Se corrige la forma de pintar de los items seleccionados y se añade nuevas formas de
//                     selección aunque todavía no se publican oficialmente
//  v1.05 - 29/08/2004 Se añaden las cláusulas VERTICALGRADIENT Y MIRROW a la creación del menú para poder
//                     indicar con la opción FILLED y especificando el tercer color en COLORSELECT que
//                     Se desea que el degradado sea horizontal o vertical y posible efecto espejo
//  v1.05 - 05/09/2004 Se añade la posibilidad de poner un segundo color de fondo en el control para que
//                     se pueda hacer un degradado del fondo total, para que no sea por items
//  v1.06 - 13/10/2004 Se elimina la necesidad de incluir en el lincado msimg32.lib porque en w95 y NT4 no viene
//                     incluida su correspondiente dll. Para ello creo una nueva función "DegradaSO" osea
//                     degrada dependiendo del Sistema Operativo donde se utiliza para w95 y nt4 una version
//                     "doméstica" de GradientFill que no tira de ninguna dll. Además ahora se carga la función
//                     "Gradientfill" de forma dinámica por lo que no hace falta la librería msimg32.lib
//  v1.07 - 15/06/2005 Se modifica Gradient95 por Gradient955 que causaba problemas en w98
//  v1.08 - 14/07/2005 Se añaden los temas de xp para el pintado del control.
//		       añado dos variables, 1º lGetThemes y lMain
//                     lGetThemes para que si puede se adapte a los temas por defecto .f.
//                     lMain para que pinte la cabecera de un color solido cuando esta variable sea .t.


#include "fivewin.ch"
#include "vmenu.ch"

#include "vmenudef.ch"


#define EBP_SPECIALGROUPHEAD  12
#define EBP_NORMALGROUPCOLLAPSE 6

#define EBNGC_HOT 2
#define EBNGC_NORMAL 1
#define EBNGC_PRESSED  3


#define EBP_NORMALGROUPEXPAND 7

#define EBNGE_HOT 2
#define EBNGE_NORMAL 1
#define EBNGE_PRESSED 3

#define EBP_SPECIALGROUPCOLLAPSE 10

#define EBSGC_HOT 2
#define EBSGC_NORMAL 1
#define EBSGC_PRESSED 3

#define EBP_SPECIALGROUPEXPAND 11

#define EBSGE_HOT 2
#define EBSGE_NORMAL 1
#define EBSGE_PRESSED 3

#define EBP_NORMALGROUPHEAD  8
#define EBP_SPECIALGROUPBACKGROUND  9


CLASS TVMenu FROM TControl

      CLASSDATA lRegistered AS LOGICAL

      DATA aBmps
      DATA aBtn
      DATA aItems

      DATA bAction
      DATA bChange
      DATA cWaterMark

      DATA cTitle


      DATA hBmpDown
      DATA hBmpUp
      DATA hDCMem
      DATA hIconTitle
      DATA hImageTitle
      DATA hFondo
      DATA hWater

      DATA lBorder
      DATA lInsetSel
      DATA lOpenClose
      DATA lOpened
      DATA lxRndSquare
      DATA lVGrad
      DATA lMirGrad
      DATA lVGradSel
      DATA lMGradSel
      DATA lGetThemes
      DATA lMain


      DATA nClrBorder
      DATA nClrBox
      DATA nClrCaption
      DATA nClrPOver
      DATA nClrPOver2
      DATA nClrPSel
      DATA nClrPSel2
      DATA nClrPT2
      DATA nClrPaneT
      DATA nClrPane2
      DATA nClrTOver
      DATA nClrTSel
      DATA nClrTextT

      DATA nHBig
      DATA nHBig
      DATA nHBtn
      DATA nHImage
      DATA nHItem
      DATA nHSmall
      DATA nHTitle
      DATA nHTitleAux
      DATA nImageAlign
      DATA nLeftMargen
      DATA nLeftTText
      DATA nLeftTImg

      DATA nMCol
      DATA nMRow

      DATA nMargen
      DATA nMargenGroup
      DATA nModeSel

      DATA nOption
      DATA nOverOption
      DATA nSpeed
      DATA nSteps
      DATA nTextAlign
      DATA nTAlign
      DATA nTipoSel
      DATA nWBig
      DATA nWBig
      DATA nWImage
      DATA nWSmall

      DATA oFontTitle
      DATA oImageList
      DATA oAttach, oRef, nDifH, oAux

      DATA nRadSqr

      DATA oWatMark
      DATA nWMAlign
      DATA nWMLeft
      DATA nWMTop



      METHOD lRndSquare SETGET


      METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, bAction, nClrText, nClrPane, oFont,;
                  lBorder, nClrBorder, nHItem, cTextAlign, under, nMargen, nClrPSel, nSpeed,;
                  selmode, bChange, nClrTSel, oAttach, nClrTxtOver, nClrPOver, nClrPOver2,;
                  nClrPSel2, lVGradSel, lMGradSel, nClrPane2, cWaterMark ) CONSTRUCTOR

      METHOD Redefine( oWnd, id, bAction, nClrText, nClrPane, oFont,;
                       lBorder, nClrBorder, nHItem, cTextAlign, under, nMargen, nClrPSel, nSpeed,;
                       selmode, bChange, nClrTSel, oAttach, nClrTxtOver, nClrPOver, nClrPOver2,;
                       nClrPSel2, lVGradSel, lMGradSel, nClrPane2 ) CONSTRUCTOR

      METHOD Default()

      METHOD Initiate( hDlg ) INLINE  ::Super:Initiate( hDlg ), ::Default()

      METHOD Display() INLINE ::BeginPaint(), ::Paint(), ::EndPaint(), 0
      METHOD Paint()
      METHOD PaintTitle( hDC )
      METHOD PaintItem( nItem )

      //METHOD End()        INLINE MsgInfo("eo"), ::Super:End()
      METHOD Destroy()

      METHOD LButtonUp( nRow, nCol, nKeyFlags )
      METHOD LButtonDown( nRow, nCol, nKeyFlags )
      METHOD MouseMove( nRow, nCol, nKeyFlags )

      METHOD nGetBmp( cBitmap )
      METHOD nGetLastBottom()
      METHOD GetBold( oFont )
      METHOD GetUnderline( oFont )

      METHOD HandleEvent( nMsg, nWParam, nLParam )

      METHOD GetOption( nRow, nCol)
      METHOD lTitle()           INLINE !empty( ::cTitle ) .or. ::hImageTitle != 0
      METHOD LoadBmp( cBmp )
      METHOD lCaption()         INLINE ::lTitle()
      METHOD Switch()

      METHOD SetTitle( cCaption, nHTitle, oFont, nClrText, nClrPane, nClrPane2, nSteps, lVGrad,;
                       cImage, nAlign, cIcon, cBtnUp, cBtnDown, lOpenClose, nRadio, lRndSquare, ;
                       lMirGrad, nRadSqr, nLeftTText, nLeftTImg  )

      METHOD KeyDown( nKey, nFlags )
      METHOD NextItem()
      METHOD PrevItem()
      METHOD RefreshSel( nItem )
      METHOD EvalAction( nItem )
      METHOD MouseWheel( nKeys, nDelta, nXPos, nYPos )
      METHOD ResizeItems()
      METHOD GetaBtn()
      METHOD SetAttach( oAchoice )
      METHOD AdjustAttach()
      METHOD LostFocus()
      METHOD GotFocus() INLINE ::Super:GotFocus() , ::Refresh()
      METHOD ShowToolTip()
      // METHOD ResetColorsTxt()  INLINE aeval( ::aItems, {|x| x:nClrPane := nil } )
      // METHOD ResetColorsPane() INLINE aeval( ::aItems, {|x| x:nClrText := nil } )
      METHOD ResetColorsTxt()  INLINE aeval( ::aItems, {|x| x:nClrPane := nil } )
      METHOD ResetColorsPane() INLINE aeval( ::aItems, {|x| x:nClrtext := nil } )
      METHOD SetTitleAlign( cAlign )
      METHOD SetHTitle( nHTitle )

      METHOD MakeFondo()
      METHOD WaterMark()

ENDCLASS


//****************************************************************************************************************//
     METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, bAction, nClrText, nClrPane, oFont,;
                 lBorder, nClrBorder, nHItem, cTextAlign, under, nMargen, nClrPSel, nSpeed,;
                 selmode, bChange, nClrTSel, oAttach, nClrTOver, nClrPOver, nClrPOver2, nClrPSel2,;
                 lVGradSel, lMGradSel, nClrPane2, cWaterMark ) CLASS TVMenu
//****************************************************************************************************************//

   DEFAULT nClrText      := RGB( 255,255,255) //RGB( 0, 49, 156 )
   DEFAULT nClrPane      := RGB( 239, 243, 255) //CLR_WHITE
   DEFAULT nClrBorder    := CLR_WHITE //RGB( 206,  99,  49 )
   DEFAULT nClrPSel      := nClrPane // GetSysColor( COLOR_HIGHLIGHT )// RGB( 231, 198, 173 )
   DEFAULT nClrTSel      := nClrText // GetSysColor( COLOR_HIGHLIGHTTEXT )// RGB( 231, 198, 173 )
   DEFAULT lBorder       := .f.
   DEFAULT nHItem        := 0
   DEFAULT bAction       := {|| .t.}
   DEFAULT nMargen       := 5
   DEFAULT nSpeed        := 1
   DEFAULT nClrTOver     := nClrText //GetSysColor( COLOR_HIGHLIGHT )
   DEFAULT nClrPOver     := nClrPane //GetSysColor( COLOR_HIGHLIGHTTEXT )
   DEFAULT lVGradSel     := .f.
   DEFAULT lMGradSel     := .f.


     ::lVGradSel := lVGradSel
     ::lMGradSel := lMGradSel


     if cTextAlign == "CENTER"
        ::nTextAlign := 37
     elseif cTextAlign == "RIGHT"
        ::nTextAlign := 38
     elseif cTextAlign == "MULTILINE"
        ::nTextAlign := 20
     else
        ::nTextAlign := 36
     endif

     ::nTAlign := ::nTextAlign

     do case
        case under == "UNDERLINE"
             ::nTipoSel := SUBRAYADO

        case under  == "INSET"
           ::nTipoSel := INSET

        case under  == "SOLID"
           ::nTipoSel := SOLID

        case under  == "XBOX"
           ::nTipoSel := XBOX

        case under  == "SOLIDUNDERLINE"
           ::nTipoSel := SOLIDUNDERLINE

        case under  == "BUMP"
           ::nTipoSel := BUMP

        case under  == "ETCHED"
           ::nTipoSel := ETCHED

        case under  == "RAISED"
           ::nTipoSel := RAISED

        otherwise
           ::nTipoSel := SINSELECCION

     endcase

     if selmode == "NONE"
        ::nModeSel := NONE
     elseif selmode == "LFILLED"
        ::nModeSel := LFILLED
     elseif selmode == "RFILLED"
        ::nModeSel := RFILLED
     elseif selmode == "FILLED"
        ::nModeSel := FILLED
     elseif selmode == "LFOLDER"
        ::nModeSel := LFOLDER
     elseif selmode == "RFOLDER"
        ::nModeSel := RFOLDER
     else
        ::nModeSel := DOTS
     endif

     ::oWnd         := oWnd

     ::nHItem       := nHItem

     ::nTop         := nTop
     ::nLeft        := nLeft
     ::nBottom      := nTop + nHeight
     ::nRight       := nLeft + nWidth

     ::aBmps        := {}
     ::aBtn         := {0,0,0,0}
     ::aItems       := {}
     ::bAction      := bAction
     ::bChange      := bChange
     ::cTitle       := ""
     ::hBmpDown     :=  0
     ::hBmpUp       :=  0
     ::hIconTitle   :=  0
     ::hImageTitle  :=  0
     ::lBorder      := lBorder
     ::lInsetSel    := .f.
     ::lOpenClose   := .F.
     ::lOpened      := .T.
     ::lRndSquare   := .f.
     ::lVGrad       := .f.
     ::lxRndSquare  := .F.
     ::hFondo       := nil

     ::nClrBorder   := nClrBorder

     ::nClrPT2      := nClrPane

     ::nClrText     := nClrText
     ::nClrPane     := nClrPane
     ::nClrPane2    := nClrPane2

     ::nClrTextT    := nClrText
     ::nClrPaneT    := nClrPane

     ::nClrTSel     := nClrTSel
     ::nClrPSel     := nClrPSel
     ::nClrPSel2    := nClrPSel2

     ::nClrTOver    := nClrTOver
     ::nClrPOver    := nClrPOver
     ::nClrPOver2   := nClrPOver2

     ::nHBig        :=  0
     ::nHBtn        := 17
     ::nHImage      :=  0
     ::nHSmall      :=  0
     ::nHTitle      :=  0
     ::nHTitleAux   :=  0
     ::nImageAlign  :=  0
     ::nLeftMargen  := nMargen
     ::nMargen      :=  0
     ::nMargenGroup := 20
     ::nOption      :=  0
     ::nOverOption  :=  0
     ::nRadSqr      :=  2
     ::nSpeed       := nSpeed / 100
     ::nSteps       := 50
     ::nWBig        :=  0
     ::nWImage      :=  0
     ::nWSmall      :=  0
     ::oFont        := oFont
     ::oFontTitle   := oFont
     ::lGetThemes   := .f. // .f. en el original
     ::lMain        := .f.

     ::oImageList  := TC5ImgList():New()

     ::nStyle      := nOR( WS_CHILD, WS_VISIBLE, WS_TABSTOP, WS_CLIPSIBLINGS, WS_CLIPCHILDREN )
     ::nId         := ::GetNewId()

     ::SetColor( ::nClrText, ::nClrPane )

     ::Register(nOr( CS_VREDRAW, CS_HREDRAW ) )

     if ! Empty( oWnd:hWnd )
        ::Create()
        ::lVisible = .t.
        oWnd:AddControl( Self )

        // Arreglado 03-06-2004
        // hacía que no guardara las medidas para abrirse y cerrarse
        // cuando se añade un control en una ventana
        ::nHSmall        := nHeight
        ::nWSmall        := nWidth
        ::nHBig          := nHeight
        ::nWBig          := nWidth
     else
        oWnd:DefControl( Self )
        ::lVisible  = .f.
     endif



     if oAttach != nil
        if ::lVisible
           oAttach:SetAttach( Self )
        else
           ::oAux = oAttach
        endif

     endif

     ::cToolTip := "Vmenu"
     ::CheckToolTip()

     ::cWaterMark := cWaterMark


return self

//****************************************************************************************************************//
     METHOD Redefine( oWnd, id, bAction, nClrText, nClrPane, oFont,;
                 lBorder, nClrBorder, nHItem, cTextAlign, under, nMargen, nClrPSel, nSpeed,;
                 selmode, bChange, nClrTSel, oAttach, nClrTOver, nClrPOver, nClrPOver2, nClrPSel2,;
                 lVGradSel, lMGradSel, nClrPane2 ) CLASS TVMenu
//****************************************************************************************************************//


   DEFAULT nClrText      := RGB( 255,255,255) //RGB( 0, 49, 156 )
   DEFAULT nClrPane      := RGB( 239, 243, 255) //CLR_WHITE
   DEFAULT nClrBorder    := CLR_WHITE //RGB( 206,  99,  49 )
   DEFAULT nClrPSel      := nClrPane // GetSysColor( COLOR_HIGHLIGHT )// RGB( 231, 198, 173 )
   DEFAULT nClrTSel      := nClrText // GetSysColor( COLOR_HIGHLIGHTTEXT )// RGB( 231, 198, 173 )
   DEFAULT lBorder       := .f.
   DEFAULT nHItem        := 0
   DEFAULT bAction       := {|| .t.}
   DEFAULT nMargen       := 5
   DEFAULT nSpeed        := 1
   DEFAULT nClrTOver     := nClrText //GetSysColor( COLOR_HIGHLIGHT )
   DEFAULT nClrPOver     := nClrPane //GetSysColor( COLOR_HIGHLIGHTTEXT )
   DEFAULT lVGradSel     := .f.
   DEFAULT lMGradSel     := .f.


     ::lVGradSel := lVGradSel
     ::lMGradSel := lMGradSel

     if cTextAlign == "CENTER"
        ::nTextAlign := 37
     elseif cTextAlign == "RIGHT"
        ::nTextAlign := 38
     elseif cTextAlign == "MULTILINE"
        ::nTextAlign := 20
     else
        ::nTextAlign := 36
     endif

     ::nTAlign := ::nTextAlign

     if under == "UNDERLINE"
        ::nTipoSel := SUBRAYADO
     elseif under == "INSET"
        ::nTipoSel := INSET
     elseif under == "SOLID"
        ::nTipoSel := SOLID
     elseif under == "SOLIDUNDERLINE"
        ::nTipoSel := SOLIDUNDERLINE
     elseif under == "XBOX"
        ::nTipoSel := XBOX
     else
        ::nTipoSel := SINSELECCION
     endif


     if selmode == "NONE"
        ::nModeSel := NONE
     elseif selmode == "LFILLED"
        ::nModeSel := LFILLED
     elseif selmode == "RFILLED"
        ::nModeSel := RFILLED
     elseif selmode == "FILLED"
        ::nModeSel := FILLED
     elseif selmode == "LFOLDER"
        ::nModeSel := LFOLDER
     elseif selmode == "RFOLDER"
        ::nModeSel := RFOLDER
     else
        ::nModeSel := DOTS
     endif

     ::oWnd           := oWnd
     ::nId            := id

     ::aBmps        := {}
     ::aBtn         := {0,0,0,0}
     ::aItems       := {}
     ::bAction      := bAction
     ::bChange      := bChange
     ::cTitle       := ""
     ::hBmpDown     :=  0
     ::hBmpUp       :=  0
     ::hIconTitle   :=  0
     ::hImageTitle  :=  0
     ::lBorder      := lBorder
     ::lInsetSel    := .f.
     ::lMirGrad     := .f.
     ::lOpenClose   := .F.
     ::lOpened      := .T.
     ::lRndSquare   := .f.
     ::lVGrad       := .f.
     ::lxRndSquare  := .F.

     ::nClrBorder   := nClrBorder

     ::nClrPT2      := nClrPane

     ::nClrText     := nClrText
     ::nClrPane     := nClrPane
     ::nClrPane2    := nClrPane2

     ::nClrTextT    := nClrText
     ::nClrPaneT    := nClrPane

     ::nClrTSel     := nClrTSel
     ::nClrPSel     := nClrPSel
     ::nClrPSel2    := nClrPSel2

     ::nClrTOver    := nClrTOver
     ::nClrPOver    := nClrPOver
     ::nClrPOver2   := nClrPOver2

     ::nHBig        :=  0
     ::nHBtn        := 17
     ::nHImage      :=  0
     ::nHItem       := nHItem
     ::nHSmall      :=  0
     ::nHTitle      :=  0
     ::nHTitleAux   :=  0
     ::nImageAlign  :=  0
     ::nLeftMargen  := nMargen
     ::nMargen      :=  0
     ::nMargenGroup := 20
     ::nOption      :=  0
     ::nOverOption  :=  0
     ::nRadSqr      :=  2
     ::nSpeed       := nSpeed / 100
     ::nSteps       := 50
     ::nWBig        :=  0
     ::nWImage      :=  0
     ::nWSmall      :=  0
     ::oFont        := oFont
     ::oFontTitle   := oFont
     ::lGetThemes   := .f. // .f. en el original
     ::lMain        := .f.

     ::oImageList  := TC5ImgList():New( )

     ::SetColor( ::nClrText, ::nClrPane )
     ::Register(nOr( CS_VREDRAW, CS_HREDRAW ) )

     if oWnd != nil
        oWnd:DefControl( Self )
     endif

     ::oAux = oAttach

     ::cToolTip := "Vmenu"
     ::CheckToolTip()

return self

***********************************************
  METHOD Default() CLASS TVMenu
***********************************************

local n
local oDlg


     ::nHBig          := ::nHeight
     ::nWBig          := ::nWidth
     ::nHSmall        := ::nHTitle + if( ::lBorder, 1, 0 )
     ::nWSmall        := ::nWBig
     ::ResizeItems()

     if ::oAux != nil
        ::oAux:SetAttach( self )
     endif


return nil

//****************************************************************************************************************//
      METHOD SetHTitle( nHTitle ) CLASS TVMenu
//****************************************************************************************************************//

   ::nHTitle    := max( ::nHImage, nHTitle )
   ::nHTitleAux := nHTitle

return nil

//****************************************************************************************************************//
      METHOD SetTitleAlign( cAlign ) CLASS TVMenu
//****************************************************************************************************************//


   if cAlign == "CENTER"
      ::nTAlign := 37
   elseif cAlign == "RIGHT"
      ::nTAlign := 38
   elseif cAlign == "MULTILINE"
      ::nTAlign := 20
   else
      ::nTAlign := 36
   endif

return nil

//****************************************************************************************************************//
    METHOD SetTitle( cCaption, nHTitle, oFont, nClrText, nClrPane, nClrPane2, nSteps, lVGrad,;
                       cImage, cAlign, cIcon, cBtnUp, cBtnDown, lOpenClose, nRadio, lRndSquare,;
                       lMirGrad, nRadSqr,;
                       nLeftTText, nLeftTImg ) CLASS TVMenu
//****************************************************************************************************************//


   DEFAULT nClrText     := CLR_WHITE //RGB( 231, 198, 173 ) //RGB( 29, 87, 199 )
   DEFAULT nClrPane     := RGB( 29, 87, 199 )   //RGB( 231, 198, 173 )
   DEFAULT oFont        := ::oFont
   DEFAULT nSteps       := 50
   DEFAULT nHTitle      := 22
   DEFAULT lVGrad       := .f.
   DEFAULT lOpenClose   := .f.
   DEFAULT nRadio       := 17
   DEFAULT lRndSquare   := .f.
   DEFAULT lMirGrad     := .f.
   DEFAULT nRadSqr      := 2
   DEFAULT cCaption     := ""
   DEFAULT cAlign       := ""

   ::cTitle := rtrim( cCaption )

   if empty( ::cTitle ) .and. empty(cImage)
      ::nHTitle := 0
      ::nHTitleAux := 0
      ::ResizeItems()
      return nil
   endif

   ::SetTitleAlign( cALign )

   ::nHImage     := 0
   ::nWImage     := 0
   if cImage != nil
      ::hImageTitle := ::LoadBmp( cImage )
      if ::hImageTitle != 0
         ::nHImage     := bmpheight( ::hImageTitle )
         ::nWImage     := bmpWidth ( ::hImageTitle )
      endif
   else
      if cIcon != nil
         if "." $ cIcon
            ::hIconTitle := ExtractIcon( cIcon )
         else
            ::hIconTitle := LoadIcon( GetResources(), cIcon )
         endif
         if ::hIconTitle != 0
            ::nHImage := 32
            ::nWImage := 32
         endif
      endif
   endif

   ::lOpenClose := lOpenClose

   ::SetHTitle( nHTitle )

   ::hBmpDown   := ::LoadBmp( cBtnDown )
   ::hBmpUp     := ::LoadBmp( cBtnUp )


   ::nHBtn   := 0

   if ::hBmpUp != 0
      ::nHBtn   := BmpHeight( ::hBmpUp )
   else
      if ::hBmpDown != 0
         ::nHBtn   := BmpHeight( ::hBmpDown )
      else
         ::nHBtn   := nRadio
      endif
   endif

   //::nHBig          := ::nHeight
   //::nWBig          := ::nWidth
   ::nHSmall        := ::nHTitle + if( ::lBorder, 1, 0 )
   ::nWSmall        := ::nWBig
   ::oFontTitle     := oFont
   ::nClrTextT      := nClrText
   ::nClrPaneT      := nClrPane
   ::nClrPT2        := nClrPane2
   ::lVGrad         := lVGrad
   ::lMirGrad       := lMirGrad
   ::nSteps         := nSteps
   ::lRndSquare     := lRndSquare
   ::nRadSqr        := nRadSqr
   ::nLeftTText     := nLeftTText
   ::nLeftTImg      := nLeftTImg


   if ::hWnd != nil
      ::ResizeItems()
   endif

return nil

//****************************************************************************************************************//
   METHOD GetaBtn() CLASS TVMenu
//****************************************************************************************************************//

   ::aBtn[1] := ::nHTitle - ::nHTitleAux  + (::nHTitleAux/2) - (::nHBtn/2) + 1
   ::aBtn[2] := ::nWidth  - ::nHBtn - 4
   ::aBtn[3] := ::aBtn[1] + ::nHBtn
   ::aBtn[4] := ::aBtn[2] + ::nHBtn

return ::aBtn


//****************************************************************************************************************//
    METHOD Destroy() CLASS TVMenu
//****************************************************************************************************************//

local n

if !empty( ::oImageList )
   ::oImageList:End()
endif

if !empty( ::hImageTitle )
    DeleteObject( ::hImageTitle )
    ::hImageTitle := 0
endif

if !empty( ::hIconTitle )
   DestroyIcon( ::hIconTitle )
   ::hIconTitle := 0
endif

if !empty( ::hBmpDown )
   DeleteObject( ::hBmpDown )
   ::hBmpDown := 0
endif

if !empty( ::hBmpUp )
   DeleteObject( ::hBmpUp )
   ::hBmpUp := 0
endif

for n := 1 to len( ::aItems )
    if ::aItems[n]:oPopup != nil
       ::aItems[n]:oPopup:End()
    endif
    if ::aItems[n]:hBmp != nil .and. !::aItems[n]:lReused
       DeleteObject(::aItems[n]:hBmp)
    endif
    if ::aItems[n]:oDlgChild != nil
       ::aItems[n]:oDlgChild:bValid := {||.t.}
       ::aItems[n]:oDlgChild:End()
    endif
next

if ::hWater != nil
   DeleteObject( ::hWater )
endif

if ::hFondo != nil
   DeleteObject( ::hFondo )
endif

return ::Super:Destroy()

//****************************************************************************************************************//
      METHOD nGetBmp( cBitmap ) CLASS TVMenu
//****************************************************************************************************************//

local n
local  nReturn := -1

for n := 1 to len( ::aBmps )

    if cBitmap == ::aBmps[n] .and. len( cBitmap ) == len( ::aBmps[n] )
       nReturn := n
       exit
    endif

next n

return nReturn



//****************************************************************************************************************//
   METHOD nGetLastBottom() CLASS TVMenu
//****************************************************************************************************************//

Local nReturn := 0
local nLen

nLen :=  len( ::aItems )

if nLen > 0
   nReturn := ::aItems[nLen]:nBottom
endif

return nReturn

//***************************************************************************************************
  METHOD GetBold( oFont, lUnder ) CLASS TVMenu
//***************************************************************************************************

DEFAULT oFont := ::oFont
DEFAULT lUnder := .f.

if valtype( oFont ) == "N"
   return CreaFBold( oFont )
endif


// la tiene que matar quien la pida

Return CreateFont( { oFont:nInpHeight, oFont:nInpWidth, oFont:nEscapement,;
                     oFont:nOrientation, 700, oFont:lItalic,;
                     lUnder, oFont:lStrikeOut, oFont:nCharSet,;
                     oFont:nOutPrecision, oFont:nClipPrecision,;
                     oFont:nQuality, oFont:nPitchFamily, oFont:cFaceName } )

//***************************************************************************************************
  METHOD GetUnderline( oFont, lUnder ) CLASS TVMenu
//***************************************************************************************************

DEFAULT lUnder := .t.
DEFAULT oFont := ::oFont


if valtype( oFont ) == "N"
   return CreaFunder( oFont )
endif
// la tiene que matar quien la pida


Return CreateFont( { oFont:nInpHeight, oFont:nInpWidth, oFont:nEscapement,;
                     oFont:nOrientation, if(oFont:lBold,700,400), oFont:lItalic,;
                     lUnder, oFont:lStrikeOut, oFont:nCharSet,;
                     oFont:nOutPrecision, oFont:nClipPrecision,;
                     oFont:nQuality, oFont:nPitchFamily, oFont:cFaceName } )




//***************************************************************************************************
   METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TVMenu
//***************************************************************************************************
Local hBrush

if nMsg == WM_ERASEBKGND
   return 1
else
   //if nMsg == WM_SIZE
   //   ::ResizeItems()
   //endif
endif


return ::Super:HandleEvent( nMsg, nWParam, nLParam )



************************************************************************************************************************
      METHOD GetOption( nRow, nCol )CLASS TVMenu
************************************************************************************************************************
local nRet := 0 //::nOption
local nItem
local lFind := .f.

if nRow <= ::nHTitleAux
   return -1
endif

if nRow > ::nGetLastBottom()
   return -1
endif

for nItem := 1 to len( ::aItems )

    if PtInRect( nRow, nCol, ::aItems[nItem]:xGetRect() )
       if !::aItems[nItem]:lGroup .and. ::aItems[nItem]:nSeparator == 0
          nRet := nItem
          exit
       endif
    else
       ::nOverOption := -1
    endif

next



return nRet



************************************************************************************************************************
  METHOD PaintTitle( hDC ) CLASS TVMenu
************************************************************************************************************************

local hFont, hOldFont
local lDestroyFont := .f.
local aRect
local aRect2
local hBmpMem
local hOldBmp
local hPen2, hOldPen, hOldBrush, hBrush
local nTop
local nH := ::nHTitle + if( !::lBorder,0,0)
local nAlign := 0
local nHText
local nLeft
local nOldB, nOldR
local hTheme


hBmpMem := CompatBmp( ::hDC, ::nWidth, nH )
hOldBmp := SelectObject( hDC, hBmpMem )

aRect2  := {           0, 0, nH - ::nHTitleAux, ::nWidth }
aRect   := { aRect2[3], 0, nH  , ::nWidth }
nOldB    :=  aRect[3]
nOldR    :=  aRect[4]

::GetaBtn()

nTop := aRect[1]

   if ::lGetThemes .and. C5_IsAppThemed() .and. C5_IsThemeActive()
      hTheme := C5_OpenThemeData(::hWnd, "EXPLORERBAR")
   endif

   if hTheme != nil
      if ::lMain
         C5_DrawThemeBackground( hTheme, hDC, EBP_SPECIALGROUPHEAD, nil , aRect )
      else
         C5_DrawThemeBackground( hTheme, hDC, EBP_NORMALGROUPHEAD, nil , aRect )
      endif
   else

      if ::nHImage > 0
         FillSoliRc( hDC, aRect2, ::oWnd:nClrPane )
      endif

      if ::nClrPT2 != nil
          if ::lVGrad
             if ::lMirGrad
                aRect[3] := (( aRect[3]-aRect[1] ) / 2 )
                DegradaSO( hDC, aRect, ::nClrPaneT, ::nClrPT2, .t.)
                aRect[1] := aRect[3]
                aRect[3] := nOldB
                DegradaSO( hDC, aRect, ::nClrPT2, ::nClrPaneT, .t.)
             else
                DegradaSO( hDC, aRect, ::nClrPaneT, ::nClrPT2, .t.)
             endif
          else
             if ::lMirGrad
                aRect[4] := ( aRect[4]-aRect[2] ) / 2
                DegradaSO( hDC, aRect, ::nClrPaneT, ::nClrPT2, .f.)
                aRect[2] := aRect[4]
                aRect[4] := nOldR
                DegradaSO( hDC, aRect, ::nClrPT2, ::nClrPaneT, .f.)
             else
                DegradaSO( hDC, aRect, ::nClrPaneT, ::nClrPT2, .f.)
             endif
          endif
      else
          FillSoliRc( hDC, aRect, ::nClrPaneT )
      endif
   endif

   if ::lRndSquare
      hOldBrush := SelectObject( hDC, ::oWnd:oBrush:hBrush )
      hPen2      := CreatePen( 0, 1, ::oWnd:nClrPane )
      hOldPen    := SelectObject( hDC, hPen2 )
      PolyPolygon( hDC, { {0,nTop+::nRadSqr},{0,nTop+0},{::nRadSqr,nTop+0},{0,nTop+::nRadSqr}} )
      PolyPolygon( hDC, { {::nWidth-::nRadSqr-1,nTop+0},{::nWidth-1,nTop+0},{::nWidth-1,nTop+::nRadSqr},{::nWidth-::nRadSqr-1,nTop+0}} )
      SelectObject( hDC, hOldPen )
      DeleteObject( hPen2 )
      SelectObject( hDC, hOldBrush )
   endif

   if ::lBorder

      if ::lRndSquare
         hPen2      := CreatePen( 0, 1, ::nClrBorder )
         hOldPen    := SelectObject( hDC, hPen2 )
         hBrush     := GetStockObject( 5 )           // BRUSH_NULL
         hOldBrush  := SelectObject( hDC, hBrush )

         PolyPolygon( hDC, {{          0, aRect[3] },;
                            {          0, nTop+::nRadSqr   },;
                            {          ::nRadSqr, nTop     },;
                            { ::nWidth-::nRadSqr-1, nTop     },;
                            { ::nWidth-1, nTop +::nRadSqr  },;
                            { ::nWidth-1, aRect[3] },;
                            {          0, aRect[3] } } )
         SelectObject( hDC, hOldPen )
         DeleteObject( hPen2 )
         SelectObject( hDC, hOldBrush )
      else
         aRect[3] := aRect[3] + 1
         BoxEx( hDC, aRect, ::nClrBorder )
      endif


   endif


                          // 02-07-2004. NO pintar imagenes si no existen
   if ::hImageTitle != 0 .and. ::hImageTitle != nil
      DrawMasked( hDC, ::hImageTitle, 0, if( ::nLeftTImg != nil, ::nLeftTImg,0) )
   else
      if ::hIconTitle != 0
         DrawIcon( hDC, if( ::nLeftTImg != nil, ::nLeftTImg,0), 0, ::hIconTitle )
      endif
   endif


   SetTextColor( hDC, ::nClrTextT )

   if ::oFontTitle == nil
      hFont := CreaFCapt()
      lDestroyFont := .t.
   else
      hFont := ::oFontTitle:hFont
   endif
   hOldFont   := SelectObject(  hDC, hFont )

   nLeft := ::nWImage + 5
   if ::nLeftTText != nil
      nLeft := ::nLeftTText
   endif

   if ::nTAlign == 20
      nAlign := 20
      nHText := DrawText( hDC, ::cTitle, { nTop, ::nWImage + 5  ,aRect[3],if( ::lOpenClose,::aBtn[2] - 4, ::nWidth )}, 1024 + 20 )
      nTop :=  nTop + (aRect[3]-nTop ) / 2 - nHText/2

      DrawText( hDC, ::cTitle, { nTop, nLeft  ,nTop+nHText,if( ::lOpenClose,::aBtn[2] - 4, ::nWidth )}, nAlign  )
   else
      nAlign := 36//::nTAlign
      DrawText( hDC, ::cTitle, { nTop, nLeft  ,aRect[3],if( ::lOpenClose,::aBtn[2] - 4, ::nWidth )}, nAlign  )
   endif


   SelectObject(  hDC, hOldFont )
   if lDestroyFont
      DeleteObject( hFont )
   endif

   if ::lOpenClose
      if hTheme != nil
         if !::lOPened
            if ::lMain
               c5_DrawThemeBackground( hTheme, hDC, EBP_SPECIALGROUPCOLLAPSE, EBSGC_HOT, { ::aBtn[1], ::aBtn[2], ::aBtn[1]+ 20, ::aBtn[2]+20 } )
            else
               c5_DrawThemeBackground( hTheme, hDC, EBP_NORMALGROUPCOLLAPSE, EBNGC_HOT, { ::aBtn[1], ::aBtn[2], ::aBtn[1]+ 20, ::aBtn[2]+20 } )
            endif
         else
            if ::lMain
               C5_DrawThemeBackground( hTheme, hDC, EBP_SPECIALGROUPEXPAND,   EBSGE_HOT, { ::aBtn[1], ::aBtn[2], ::aBtn[1]+ 20, ::aBtn[2]+20 } )
            else
               C5_DrawThemeBackground( hTheme, hDC, EBP_NORMALGROUPEXPAND,   EBNGE_HOT, { ::aBtn[1], ::aBtn[2], ::aBtn[1]+ 20, ::aBtn[2]+20 } )
            endif
         endif
      else
         if !::lOpened
            if ::hBmpDown != 0
               DrawBitmap( hDC, ::hBmpDown, ::aBtn[1], ::aBtn[2] )
            else
               ArrowDown( hDC, ::aBtn[1], ::aBtn[2], ::aBtn[1]+ ::nHBtn, ::aBtn[2]+::nHBtn,min(if( ::nClrPT2 != nil, ::nClrPT2, ::nCLrBorder ), ::nClrBorder ), CLR_WHITE )
            endif
         else
            if ::hBmpUp != 0
               DrawBitmap( hDC, ::hBmpUp, ::aBtn[1], ::aBtn[2] )
            else
               ArrowUp( hDC, ::aBtn[1], ::aBtn[2], ::aBtn[1]+ ::nHBtn, ::aBtn[2]+::nHBtn,min(if( ::nClrPT2 != nil, ::nClrPT2, ::nCLrBorder ), ::nClrBorder ), CLR_WHITE )
            endif
         endif
      endif
   endif
   BitBlt( ::hDC, 0, 0, ::nWidth, nH, hDC, 0, 0, SRCCOPY )
   SelectObject( hDC, hOldBmp )
   DeleteObject( hBmpMem )

   if hTheme != nil
      C5_CloseThemeData( hTheme )
   endif

return nil

************************************************************************************************************************
  METHOD Paint() CLASS TVMenu
************************************************************************************************************************

local hBmpMem, hOldBmp
local n, nItem, oItem
local nItems
local aSize := {0,0}
local hFont, hOldFont
local nColor
local aRect
local lKillFont := .t.
local hDCMem2
local nBottom

if ::nClrPane2 != nil
   if ::hFondo == nil
      ::MakeFondo()
   else
      if BmpWidth( ::hFondo ) != ::nWidth
         ::MakeFondo()
      endif
   endif
endif

if ::oFont == nil
   hFont := GetStockObject(DEFAULT_GUI_FONT)
else
   hFont := ::oFont:hFont
endif

hBmpMem := nil

nItems := len( ::aItems )

::hDCMem  := CompatDC( ::hDC )

SetBkMode   ( ::hDCMem, 1 )

if ::lTitle()
   ::PaintTitle( ::hDCMem )
endif


SetTextColor( ::hDCMem, ::nClrText )

hOldFont := SelectObject( ::hDCMem, hFont )


for n := 1 to len( ::aItems )

    oItem := ::aItems[ n ]

    hBmpMem := CompatBmp( ::hDC, ::nWidth, oItem:aSize[2] )

    hOldBmp := SelectObject( ::hDCMem, hBmpMem )

    aSize := oItem:aSize()

    ::PaintItem( n  )

    SelectObject( ::hDCMem, hOldBmp )
    DeleteObject( hBmpMem )

next


aRect := GetClientRect( ::hWnd )


aRect[1] = max( ::nHTitle, ::nGetLastBottom() )

if ::hFondo != nil
   hDCMem2  := CompatDC( ::hDC )
   hOldBmp := SelectObject( hDCMem2, ::hFondo )

   if len( ::aItems ) > 0
      nBottom := ::aItems[len(::aItems)]:nBottom
   else
      nBottom := ::nHItem
   endif

   BitBlt( ::hDC, 0, nBottom, ::nWidth, ::nHeight, hDCMem2, 0, nBottom, SRCCOPY )

   SelectObject( hDCMem2, hOldBmp )
   DeleteDC( hDCMem2 )
else
   FillSoliRc( ::hDC, aRect , ::nClrPane )
endif

if ::lBorder
   aRect := GetClientRect( ::hWnd )
   if ::lBorder
      aRect[1] := ::nHTitle
   endif
   BoxEx( ::hDC, aRect, ::nClrBorder )
endif

SelectObject( ::hDCMem, hOldFont )
DeleteDC( ::hDCMem )


::hDCMem := nil

return nil

************************************************************************************************************************
   METHOD PaintItem( nItem ) CLASS TVMenu
************************************************************************************************************************

local oItem
local lHDC := .f.
local hBmpMem, hOldBmp, hOldFont
local hFont

if nItem < 1
   return nil
endif

oItem := ::aItems[nItem]


if ::oFont == nil
   hFont := GetStockObject(DEFAULT_GUI_FONT)
else
   hFont := ::oFont:hFont
endif

if ::hDCMem == nil
   lHDC := .t.
   ::hDCMem  := CompatDC( ::GetDC() )

   hBmpMem := CompatBmp( ::hDC, ::nWidth-if(::lBorder,2,0), oItem:aSize[2] ) //nHeight )

   hOldBmp  := SelectObject( ::hDCMem, hBmpMem )
   SetBkMode   ( ::hDCMem, 1 )
   SetTextColor( ::hDCMem, ::nClrText )
   hOldFont := SelectObject( ::hDCMem, hFont )

endif


   oItem:Paint( ::hDCMem, ::nOverOption == nItem )
   //BitBlt( ::hDC, oItem:nLeft, oItem:nTop, ::nWidth-if(::lBorder,2,0), oItem:nHeight, ::hDCMem, 0, 0, SRCCOPY )
   BitBlt( ::hDC, oItem:nLeft, oItem:nTop, ::nWidth-if(::lBorder,2,0), oItem:aSize[2], ::hDCMem, 0, 0, SRCCOPY )


if lHDC

   SelectObject( ::hDCMem, hOldFont )
   SelectObject( ::hDCMem, hOldBmp )
   DeleteObject( hBmpMem )
   DeleteDC( ::hDCMem )
   ::hDCMem := nil
   ::ReleaseDC()

endif


return nil


//*****************************************************************//
    METHOD LButtonDown( nRow, nCol, nKeyFlags ) CLASS TVMenu
//*****************************************************************//

local nOption


if ::lOpenClose .and. PtInRect( nRow, nCol, ::aBtn ) .and. ::lTitle()
   ::Switch()
   return 0
endif

nOpTion := ::GetOption( nRow, nCol )

 SetFocus( ::hWnd )
 ::lCaptured := .t.
 ::Capture()

return ::Super: LButtonDown( nRow, nCol, nKeyFlags )


//*****************************************************************//
   METHOD LButtonUp( nRow, nCol, nKeyFlags ) CLASS TVMenu
//*****************************************************************//

local nOption
local nOldOption := ::nOption
local oItem

nOpTion := ::GetOption( nRow, nCol )

::lCaptured := .f.
ReleaseCapture()

if ::lOpenClose .and. PtInRect( nRow, nCol, ::aBtn ) .and. ::lTitle()
   return 0
endif

   if nOption < 0
      return 0
   endif

   if nOption > 0 .and. nOption <= len( ::aItems )

      if ::aItems[nOption]:lDisable .or. ::aItems[nOption]:lGroup .or. ::aItems[nOption]:nSeparator != 0
         return nil
      endif

   endif

   ::nOption := nOption

   ::RefreshSel(nOldOption)

   if ::nOption > 0 .and. nOldOption != ::nOption
      if ::bChange != nil
         eval( ::bChange, self )
      endif
   endif

   ::EvalAction( nOldOption )

//   if ::bAction != nil
//      return Eval( ::bAction, self )
//   endif


//endif

return ::Super: LButtonUp( nRow, nCol, nKeyFlags )


//*******************************************************************************//
  METHOD MouseMove( nRow, nCol, nKeyFlags ) CLASS TVMenu
//*******************************************************************************//

  local nOldOver := -1
  local nAux
  local aPoint := {nRow, nCol}


  if ::lOpenClose .and. PtInRect( nRow, nCol, ::aBtn ) .and. ::lTitle()
     CursorHand()
     return 0
  endif

  nOldOver := ::nOverOption

  ::nMRow := nRow
  ::nMCol := nCol

  ::nOverOption := ::GetOption( nRow, nCol )

  /*if  ::nOverOption < 0 .or. ( ::nOverOption > 0 .and. ( ::aItems[::nOverOption]:lDisable  .or. ::aItems[::nOverOption]:lGroup .or. ::aItems[::nOverOption]:nSeparator != 0 ))
     CursorArrow()
     return nil
  endif*/


  aPoint = ClientToScreen( ::hWnd, aPoint )

  if WindowFromPoint( aPoint[2], aPoint[1] ) == ::hWnd
     ::Capture()
  else
     ReleaseCapture()
     ::nOverOption := -1
     ::PaintItem( nOldOver )
     return 0
  endif


  if nOldOver != ::nOverOption

     ::PaintItem( nOldOver )
     if ::nOverOption > 0
        ::PaintItem( ::nOverOption )
     endif

     ::DestroyToolTip()

  endif

  if ::nOverOption <= 0 .or. ::aItems[::nOverOption]:lGroup
     CursorArrow()
  else
     ::CheckToolTip()
     CursorHand()
  endif


return nil


*************************************************************************************
   METHOD LoadBmp( cBitmap ) CLASS TVMenu
*************************************************************************************

local hBitmap := 0

if !empty( cBitmap )


   if valtype( cBitmap ) == "N"

      hBitmap  := LoadBitmap( GetResources(), cBitmap )

   else

      if "." $ cBitmap

        hBitmap  := ReadBitmap( 0, cBitmap )

      else

        hBitmap  := LoadBitmap( GetResources(), cBitmap )

      endif

   endif

endif

return hBitmap


*****************************************************************************************************************
    METHOD Switch() CLASS TVMenu
*****************************************************************************************************************
local i
local nInc := (::nHBig-::nHSmall) / 4
local nH

if !::lOpenClose
   return nil
endif

::lOpened := !::lOpened

for i := 1 to 4


    if !::lOpened
       nH = ::nHBig - nInc*i
       ::SetSize( ::nWidth, nH, .t. )
    else
       nH = ::nHSmall + nInc*i
       ::SetSize(  ::nWidth, nH, .t. )
    endif
    //inkey(::nSpeed )

next

if ::oAttach != nil
   ::oAttach:AdjustAttach()
endif

return nil

*****************************************************************************************************************
    METHOD KeyDown( nKey, nFlags ) CLASS TVMenu
*****************************************************************************************************************
local nOption := ::nOption


if GetFocus() != ::hWnd
   return 0
endif


if ::lOpened

/*   do case
      case nKey == VK_UP .or. nKey == VK_LEFT

           ::PrevItem()

           if nOption > 0
              ::PaintItem( nOption )
           endif

           if ::nOption > 0
           ::PaintItem( ::nOption )
           endif

           if nOption != ::nOption .and. ::bChange != nil
              eval( ::bChange, self )
           endif

      case nKey == VK_DOWN .or. nKey == VK_RIGHT

           if nOption > 0 .and. nKey == VK_RIGHT .and. ::aItems[nOption]:oPopup != nil
              return ::EvalAction()
           endif

           ::NextItem()

           if nOption > 0
              ::PaintItem( nOption )
           endif
           if ::nOption > 0
           ::PaintItem( ::nOption )
           endif

           if nOption != ::nOption .and. ::bChange != nil
              eval( ::bChange, self )
           endif

      // case nKey == VK_SPACE
      //
      //    ::Switch()
      //
      //    if ::lOpenClose .and. !::lOpened
      //       ::oWnd:GoNextCtrl(::hWnd)
      //    endif

      //
      case nKey == VK_RETURN

           ::EvalAction()
   endcase*/
else
endif


return 0

*****************************************************************************************************************
    METHOD NextItem( nItem ) CLASS TVMenu
*****************************************************************************************************************

local nOption := ::nOption
local nAux    := ::nOption

if len( ::aItems ) <= 1
   return nil
endif

nOption++

if nOption > len( ::aItems )
   nOption := 1
endif

::nOption := nOption

if ::nOption > 0 .and. ( ::aItems[::nOption]:nSeparator != 0 .or. ::aItems[::nOption]:lGroup .or. ;
   if( ::aItems[::nOption]:bWhen != nil, !::aItems[::nOption]:EvalWhen(),.t.) )
   ::NextItem()
endif

return nil

*****************************************************************************************************************
    METHOD PrevItem() CLASS TVMenu
*****************************************************************************************************************
local nOption := ::nOption
local nAux    := ::nOption

if len( ::aItems ) <= 1
   return nil
endif

nOption--

if nOption < 1
   nOption := len( ::aItems )
endif

::nOption := nOption

if ::nOption > 0 .and. (::aItems[::nOption]:nSeparator != 0 .or. ::aItems[::nOption]:lGroup  .or. ;
   if( ::aItems[::nOption]:bWhen != nil, !::aItems[::nOption]:EvalWhen(),.t.) )
   ::PrevItem()
endif

return nil


**********************************************************************************************************
    METHOD RefreshSel( nOldItem ) CLASS TVMenu
**********************************************************************************************************

   if ::nOption > 0 //.and. GetFocus() == ::hWnd

      if !empty( nOldItem )
         ::PaintItem(nOldItem )
      endif

      ::PaintItem(::nOption )

   endif

return nil

**********************************************************************************************************
    METHOD EvalAction( nOldItem ) CLASS TVMenu
**********************************************************************************************************

local oItem
local aPoint

   if ::nOption > 0 //.and. GetFocus() == ::hWnd

      ::RefreshSel( nOldItem )

      oItem := ::aItems[::nOption]

      if oItem:oPopup != nil

         aPoint := {oItem:nTop , oItem:nWidth}
         aPoint := ClientToScreen( ::hWnd, aPoint )
         aPoint := ScreenToClient( ::oWnd:hWnd, aPoint )

         ::oWnd:oPopup := oItem:oPopup
         oItem:oPopup:Activate( aPoint[1] , aPoint[2], ::oWnd, .f. )
         ::oWnd:oPopup := nil
      else
         if oItem:bAction != nil
            eval( oItem:bAction, self )
         else
            if ::bAction != nil
               eval( ::bAction, self )
            endif
         endif
      endif

   endif


return nil

******************************************************************************************************
  METHOD MouseWheel( nKeys, nDelta, nXPos, nYPos ) CLASS TVMenu
******************************************************************************************************

   if ::lOpened
      if nDelta > 0
         ::KeyDown( VK_UP, 0 )
      else
         ::KeyDown( VK_DOWN, 0 )
      endif
    endif

return 0

******************************************************************************************************
      METHOD ResizeItems() CLASS TVMenu
******************************************************************************************************

local n
local oItem

for n := 1 to len( ::aItems )

    oItem := ::aItems[n]

    oItem:nCalcSize()

     if  n == 1
        oItem:aPos  := {0,0}
        if ::lTitle()
           oItem:aPos[1] += ::nHTitle + 1
        endif
     else
        oItem:aPos  := {::aItems[n-1]:aPos[1]+::aItems[n-1]:aSize[2], 0 }
     endif

next
return nil

*****************************************************************************************************************
   METHOD SetAttach( oAchoice ) CLASS TVMenu
*****************************************************************************************************************

      ::oAttach := oAchoice
      ::oAttach:oRef := self
      ::nDifH := ::oAttach:nTop - ::nTop - ::nHeight


return nil

*****************************************************************************************************************
    METHOD AdjustAttach() CLASS TVMenu
*****************************************************************************************************************

   ::nTop := ::oRef:nTop + ::oRef:nHeight + ::oRef:nDifH

   if ::oAttach != nil
      ::oAttach:AdjustAttach()
   endif

return nil

*****************************************************************************************************************
METHOD LostFocus() CLASS TVMenu
*****************************************************************************************************************

::Refresh()

return ::Super:LostFocus()


***************************************************************************
  METHOD ShowToolTip() CLASS TVMenu
***************************************************************************

   local oItem, nTop, nLeft, aPoint

   if ::nOverOption > 0
      oItem := ::aItems[ ::nOverOption ]
      if ! Empty( oItem:cToolTip )
         ::cToolTip = oItem:cToolTip
         ::Super:ShowToolTip( oItem:aPos[1], ::nWidth + 3 )
      endif
   endif

return nil

***************************************************************************
   METHOD lRndSquare( lValue ) CLASS TVmenu
***************************************************************************

if pcount() > 0
   ::lxRndSquare := lValue
endif

return ::lxRndSquare


***************************************************************************
   METHOD MakeFondo() CLASS TVmenu
***************************************************************************
Local hDC, hDCMem, hOldBmp
Local aRect
Local nOldB
Local nOldR


if ::nClrPane2 != nil

   ::hFondo := CompatBmp( ::hDC, ::nWidth, ::nHeight-if(::lBorder,1,0)  )
   hDCMem  := CompatDC( ::hDC )

   hOldBmp := SelectObject( hDCMem, ::hFondo )

   aRect := {::nHTitle, 0, ::nHeight-if(::lBorder,1,0)  , ::nWidth }

   nOldB    :=  aRect[3]
   nOldR    :=  aRect[4]


   if ::lVGrad
      /*if ::lMirGrad
         aRect[3] := (( aRect[3]-aRect[1] ) / 2 )
         DegradaSO( hDCMem, aRect, ::nClrPane, ::nClrPane2, .t.)
         aRect[1] := aRect[3]
         aRect[3] := nOldB
         DegradaSO( hDCMem, aRect, ::nClrPane, ::nClrPane2, .t.)
      else*/
         DegradaSO( hDCMem, aRect, ::nClrPane, ::nClrPane2, .t.)
      //endif
   else
      /*if ::lMirGrad
         aRect[4] := ( aRect[4]-aRect[2] ) / 2
         DegradaSO( hDCMem, aRect, ::nClrPane, ::nClrPane2, .f.)
         aRect[2] := aRect[4]
         aRect[4] := nOldR
         DegradaSO( hDCMem, aRect, ::nClrPane, ::nClrPane2, .f.)
      else*/
         DegradaSO( hDCMem, aRect, ::nClrPane, ::nClrPane2, .f.)
      //endif
   endif

   if ::cWaterMark != nil .and. ::hWater == nil
      ::WaterMark()
      DrawMasked( hDCMem, ::hWater, ::nHeight - BmpHeight( ::hWater )-1, ::nWidth - BmpWidth( ::hWater )-1)
   endif

   SelectObject( hDCMem, hOldBmp )

endif



return nil


***************************************************************************
      METHOD WaterMark() CLASS TVmenu
***************************************************************************

if ::hWater != nil
   DeleteObject( ::hWater )
endif

::hWater := ::LoadBmp( ::cWaterMark )


Return nil


function DegradaSO( hDC, aRect, nClr1, nClr2, lVertical )


//if IsWin95() .or. IsWinNT()
//   Degrada9( hDC, aRect, nClr1, nClr2, lVertical )
//else
   c5Degrada( hDC, aRect, nClr1, nClr2, lVertical )
//endif

return nil



