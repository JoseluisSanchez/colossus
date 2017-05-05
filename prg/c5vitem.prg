#include "fivewin.ch"
#include "vmenudef.ch"
#include "vmenu.ch"


#define NO_ES_GRUPO         !::lGroup
#define NO_ES_SEPARADOR    ::nSeparator == 0


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CLASS TVItem

      DATA oParent

      DATA aPos
      DATA aSize
      DATA bAction
      DATA bWhen
      DATA cCaption
      DATA cToolTip
      DATA hBmp
      DATA lDisable
      DATA lFixHeight
      DATA lGroup
      DATA lIcon
      DATA lLPopup
      DATA lMirGrad
      DATA lReused
      DATA lSetBold
      DATA lUnder
      DATA lVGrad

      DATA nClrPSel
      DATA nClrPSel2

      DATA nClrPane
      DATA nClrPane2

      DATA nClrTSel
      DATA nClrText
      DATA nColorSep
      DATA nHBmp
      DATA nHString
      DATA nImage
      DATA nImageOver
      DATA nImgAlign
      DATA nLString
      DATA nLeftImg
      DATA nSeparator
      DATA nSteps
      DATA nTString
      DATA nTextAlign
      DATA nWBmp
      DATA nWString
      DATA oPopup

      DATA oDlgChild
      DATA lDlgAct

      METHOD New( oParent, cText, nBmp1, nBmp2, lGroup, nClrText, nClrPane, nTxtAlign, nImgAlign, nHeight, nLeft,;
                  separator, nWidth, lUnder, nLeftImg, nClrPane2, lVGrad, bAction, oPopup,;
                  nClrPSel, nClrTSel, lMirGrad, nSteps, cToolTip, nColorSep, lIcon, nTop,;
                  bWhen, nClrPSel2 ) CONSTRUCTOR

      METHOD nTop               INLINE ::aPos[1]
      METHOD nLeft              INLINE ::aPos[2] + if( ::oParent:lBorder, 1, 0 )
      METHOD nBottom            INLINE ::aPos[1] + ::nHeight
      METHOD nRight             INLINE ::aPos[2] + ::nWidth
      METHOD nHeight 		INLINE ::aSize[2]
      METHOD nWidth		INLINE ::oParent:nWidth - if( ::oParent:lBorder, 2, 0 )
      METHOD xGetRect           INLINE {::nTop, ::nLeft, ::nBottom, ::nRight}
      METHOD nCalcSize()
      METHOD Paint( hDC, lOver )
      METHOD PaintSel( hDC, aRect, lOver )
      METHOD PaintFondo( hDC, aRect, lOver )
      METHOD ArrowPopup( hDC, aRect, nColor )
      METHOD lOption()
      METHOD SetBold( lBold )
      METHOD SetColor( nColor )
      METHOD SetImage( cBmp, lIcon )
      METHOD EvalWhen( lFromPaint )
      METHOD SetDialog( cResName )
      METHOD ActDlg()

ENDCLASS


//************************************************************************************************************************************************//
   METHOD New( oParent, cText, cBmp1, cBmp2, lGroup, nClrText, nClrPane, nTextAlign, nImgAlign, nHeight, nLeft,;
           separator, nWidth, lUnder, nLeftImg, nClrPane2, lVGrad, bAction, oPopup,;
           nClrPSel, nClrTSel, lMirGrad, nSteps, cToolTip, nColorSep, lIcon, nTop,;
           bWhen, nClrPSel2 )  CLASS TVItem
//************************************************************************************************************************************************//

     local n

     DEFAULT lGroup      := .f.
     DEFAULT nImgAlign   := ""
     DEFAULT nTextAlign  := ""
     DEFAULT separator   := ""
     DEFAULT nLeft       := 0
     DEFAULT nWidth      := 0
     DEFAULT lUnder  := .f.
     DEFAULT lMirGrad := .f.
     DEFAULT nSteps      := 50
     DEFAULT nColorSep   := 0
     DEFAULT lIcon       := .f.
     DEFAULT cText       := ""

     ::oParent    := oParent


     ::aPos        := {0,0}
     ::aSize       := {0,0}

     ::lGroup      := .F.
     ::lLPopup     := .F.
     ::lVGrad      := .F.
     ::lMirGrad    := .F.
     ::lFixHeight  := .F.
     ::lSetBold    := .F.
     ::lDlgAct     := .f.

     ::nClrText          := nClrText
     ::nClrPane          := nClrPane
     ::nClrPane2         := nClrPane2
     ::lVGrad            := lVGrad
     ::lMirGrad       := lMirGrad
     ::nSteps            := nSteps
     ::lSetBold          := .f.

     ::cCaption       := cText
     ::nImage         := -1
     ::nImageOver     := -1
     ::nLeftImg       := nLeftImg
     ::bAction        := bAction
     ::oPopup         := oPopup
     ::nClrPSel       := nClrPSel
     ::nClrPSel2      := nClrPSel2
     ::nClrTSel       := nClrTSel
     ::nColorSep      := nColorSep
     ::cToolTip       := cToolTip
     ::lIcon          := lIcon
     ::hBmp           := nil
     ::lReused        := .f.
//     ::aItems         := {}

              //[ <mode: TEXTCENTER, TEXTRIGHT, TEXTMULTILINE > ] ;
     if nTextAlign == "CENTER"
        ::nTextAlign := 37
     elseif nTextAlign == "RIGHT"
        ::nTextAlign := 38
     elseif nTextAlign == "MULTILINE"
        ::nTextAlign := 20
     else
        ::nTextAlign := 36
     endif

     if nImgAlign == "IMAGECENTER"
        ::nImgAlign := 1
     elseif nImgAlign == "IMAGERIGHT"
        ::nImgAlign := 2
     else
        ::nImgAlign := 0
     endif

     ::nSeparator := 0

     do case
        case separator == "SEPARADOR"
             ::nSeparator := 1
        case separator == "LINE"
             ::nSeparator := 2
        case separator == "INSET"
             ::nSeparator := 3
        case separator == "DOTDOT"
             ::nSeparator := 4
     endcase

     ::nLString := nLeft
     ::nTString := nTop
     ::nWString := nWidth

     ::lDisable   := .f.
     ::bWhen      := bWhen
     ::lUnder := lUnder

     ::SetImage( cBmp1, lIcon )


/*     if !empty( cBmp2 )
        n := ::oParent:nGetBmp( cBmp2 )
        if n < 0
           ::oParent:oImageList:Add( cBmp2, ".ico" $ lower( cBmp2 ) )
           n := ::oParent:oImageList:GetCount()
           if n > 0
              ::oParent:nMargen := ::oParent:oImageList:nWidth( n ) + 6
           endif

        endif
        ::nImageOver := n
     endif
*/
     ::lGroup     := lGroup

     ::nCalcSize()

     if nHeight != nil
        ::lFixHeight := .t.
        ::aSize[2] := nHeight
     endif

     n := len( ::oParent:aItems )

     if  n == 0
        ::aPos  := {0, 0 }
        if ::oParent:lTitle()
           ::aPos[1] += ::oParent:nHTitle + 1
        endif
     else
        ::aPos  := {::oParent:aItems[n]:aPos[1]+::oParent:aItems[n]:aSize[2], 0 }
     endif


     aadd( ::oParent:aItems, self )

 return self

//****************************************************************************************************************//
     METHOD SetImage( cBmp, lIcon ) CLASS TVItem
//****************************************************************************************************************//
local n

     if !empty( cBmp )
        if valtype( cBmp ) == "O"
           ::nImage := cBmp:nImage
           if ::nImage  == 0
              ::hBmp    := cBmp:hBmp
              ::nWBmp   := cBmp:nWBmp
              ::nHBmp   := cBmp:nHBmp
              ::lReused := .t.
              ::nImage  := 0
           else
              ::oParent:nMargen := ::oParent:oImageList:nWidth( ::nImage ) + 6
           endif
           return nil
        endif
        n := ::oParent:nGetBmp( cBmp )
        if n < 0     // no lo encuentro en el array
           n := ::oParent:oImageList:Add( cBmp, lIcon .or. ".ico" $ lower( cBmp ) )
           if valtype( n ) == "A"
              ::hBmp := n[1]
              ::nWBmp := n[2]
              ::nHBmp := n[3]
              n := 0
           else
              if n > 0
                 ::oParent:nMargen := ::oParent:oImageList:nWidth( n ) + 6
              endif
           endif
        endif
        ::nImage := n
//        ::oParent:nMargen := ::oParent:oImageList:nWidth(::nImage ) + 6
     endif

return nil

//****************************************************************************************************************//
    METHOD nCalcSize() CLASS TVItem
//****************************************************************************************************************//
    local nWidth
    local nHeight
    local hDC    := ::oParent:GetDC()
    local hFont, hOldFont
    local nLeft := ::nLString

    if ::lFixHeight
       ::oParent:ReleaseDC()
       return ::aSize[2]
    endif


    if empty (::oParent:hWnd )
       ::oParent:ReleaseDC()
       return nil
    endif

    nWidth := ::oParent:nWidth  - if( ::oPopup != nil, 14, 0 ) //::oParent:nMargen

    if nLeft == 0
       nLeft := ::oParent:nLeftMargen
    endif
    if ::nImage > 0
         nLeft += ::oParent:nMargen
    endif

    if ::oParent:oFont == nil
       hFont := GetStockObject(DEFAULT_GUI_FONT)
    else
       hFont := ::oParent:oFont:hFont
    endif

    if ::lSetBold
       hFont := ::oParent:GetBold( hFont )
    endif

    hOldFont := SelectObject( hDC, hFont )

    if ::lGroup
       ::nTextAlign := 36
    endif

    nHeight := DrawText( hDC, ::cCaption, { 0, nLeft , 10, nWidth }, 1024 + if( ::nTextAlign == nil, ::oParent:nTextAlign, ::nTextAlign ) )

    ::nHString := nHeight

    ::aSize[1] := nWidth
    ::aSize[2] := max( max( nHeight, ::oParent:nHItem ), if( ::nImage > 0, if(::hBmp ==nil, ::oParent:oImageList:nHeight( ::nImage ),::nHBmp),0 ) )

    SelectObject( hDC, hOldFont )

    if ::lSetBold
       DeleteObject( hFont )
    endif

    ::oParent:ReleaseDC()

 return ::aSize[2]


//****************************************************************************************************************//
    METHOD Paint( hDC, lOver ) CLASS TVItem
//****************************************************************************************************************//


   local nImagen
   local nLeft
   local nRight
   local nColor := nil
   local aRect, aAux
   local hFont, hOldFont
   local nTop := 0
   local nBottom := 0
   local hPen, hOldPen
   local lKillFont := .f.
   local nOldB, nOldR
   local hDCMem
   local hOldBmp

   if ::bWhen != nil
      ::EvalWhen(.t.)
   endif


   if ::oDlgChild != nil .and. !::lDlgAct
      ::ActDlg()
   endif

   if empty( ::oParent:oFont)
      hFont := GetStockObject(DEFAULT_GUI_FONT)
   else
      hFont := ::oParent:oFont:hFont
   endif

   do case
      case ::lUnder .and. !::lGroup

           lKillFont := .t.
           hFont := ::oParent:GetUnderline(hFont, ::lUnder)
           hOldFont := SelectObject( hDC, hFont )

      case ::lSetBold

           lKillFont := .t.
           hFont := ::oParent:GetBold( hFont,::lUnder )
           hOldFont := SelectObject( hDC, hFont )

      case  lOver .and. !::lGroup .and. ( ::oParent:nTipoSel == SUBRAYADO .or. ::oParent:nTipoSel == SOLIDUNDERLINE )

           lKillFont := .t.
           hFont := ::oParent:GetUnderline(hFont)
           hOldFont := SelectObject( hDC, hFont )

      case ::lGroup

           lKillFont := .t.
           hFont := ::oParent:GetBold( hFont,::lUnder )
           hOldFont := SelectObject( hDC, hFont )

      otherwise

           lKillFont := .f.
           if valtype( hFont ) == "0"
              hOldFont := SelectObject( hDC, hFont:hFont )
           else
              hOldFont := SelectObject( hDC, hFont )
           endif

   endcase


   aRect  := {0, 0, ::nHeight, ::nWidth}   // para pintar en memoria

   nOldB := aRect[3]
   nOldR := aRect[4]

   if ::nClrPane2 != nil
       if ::lVGrad
          if ::lMirGrad
             aRect[3] := (( aRect[3]-aRect[1] ) / 2 )
             DegradaSO( hDC, aRect, ::nClrPane, ::nClrPane2, .t.)
             aRect[1] := aRect[3]
             aRect[3] := nOldB
             DegradaSO( hDC, aRect, ::nClrPane2, ::nClrPane, .t.)
          else
             DegradaSO( hDC, aRect, ::nClrPane, ::nClrPane2, .t.)
          endif
       else
          if ::lMirGrad
             aRect[4] := ( aRect[4]-aRect[2] ) / 2
             DegradaSO( hDC, aRect, ::nClrPane, ::nClrPane2, .f.)
             aRect[2] := aRect[4]
             aRect[4] := nOldR
             DegradaSO( hDC, aRect, ::nClrPane2, ::nClrPane, .f.)
          else
             DegradaSO( hDC, aRect, ::nClrPane, ::nClrPane2, .f.)
          endif
       endif
   else
       if ::oParent:hFondo != nil
          #ifdef __HARBOUR__
              hDCMem  := CreateCompatibleDC( ::oParent:hDC )
          #else
             #ifdef __C3__
                 hDCMem  := CreateCompatibleDC( ::oParent:hDC )
             #else
                 hDCMem  := CompatDC( ::oParent:hDC )
             #endif
          #endif
          hOldBmp := SelectObject( hDCMem, ::oParent:hFondo )
          BitBlt( hDC, 0, 0, ::nWidth, ::nHeight, hDCMem, 0, ::nTop, SRCCOPY )
          SelectObject( hDCMem, hOldBmp )
          DeleteDC( hDCMem )
       else
         #ifdef __HARBOUR__
            FillSolidRect( hDC, aRect, if( ::nClrPane != nil,::nClrPane,::oParent:nClrPane ) )
         #else
            #ifdef __C3__
               FillSolidRect( hDC, aRect, if( ::nClrPane != nil,::nClrPane,::oParent:nClrPane ) )
            #else
               FillSoliRc( hDC, aRect, if( ::nClrPane != nil,::nClrPane,::oParent:nClrPane ) )
            #endif
         #endif
       endif

   endif

   if NO_ES_GRUPO .and. NO_ES_SEPARADOR

      if  ::oParent:nModeSel == FILLED
          if ::lOption()
             ::PaintFondo( hDC, aRect, .f. )
          endif
      endif

      if lOver //.and. ( ::oParent:nTipoSel == SOLID .or. ::oParent:nTipoSel == SOLIDUNDERLINE )
         ::PaintSel( hDC, aRect, .t. )
      endif

   endif

   if ::lOption() .or. lOver

      if ::oParent:nTipoSel == SOLID .or. ::oParent:nTipoSel == SOLIDUNDERLINE

         if lOver
            nColor := SetTextColor( hDC, ::oParent:nClrTOver )
         else
            if ::lOption
               if ::nClrTSel != nil
                  nColor := SetTextColor( hDC, ::nClrTSel )
               else
                  nColor := SetTextColor( hDC, ::oParent:nClrTSel )
               endif
            endif
         endif

      endif

   else

      if ::nClrText != nil
         nColor := SetTextColor( hDC, ::nClrText )
      else
         nColor := SetTextColor( hDC, ::oParent:nClrText )
      endif

   endif

   nLeft  := ::nLString

   if nLeft == 0
      nLeft := ::oParent:nLeftMargen
   endif

   nRight := ::nWidth

   if ::nImgAlign == 0

     if ::nTextAlign == 20
         nTop := aRect[1]
      else
         if empty( ::hBmp )
            if ::nImage > 0
               nTop := max( aRect[1]+::nHeight/2  - ::oParent:oImageList:nHeight( ::nImage ) /2, 1 )
            endif
         else
            nTop := aRect[1]+::nHeight/2  - ::nHBmp/2
         endif
      endif


      if ::nImage > 0

         if ::nLeftImg != nil
            ::oParent:oImageList:Draw( hDC, ::nImage, nTop, ::nLeftImg,::lDisable )
         else
            ::oParent:oImageList:Draw( hDC, ::nImage, nTop, nLeft,::lDisable )
         endif

         nLeft += ::oParent:nMargen
      else
         // 02-07-2004. NO pintar imagenes si no existen
         if ::hBmp != nil

            if ::lDisable
               #ifdef __HARBOUR__
                   DrawState ( hDC, nil, ::hBmp, , if(::nLeftImg != nil, ::nLeftImg,nLeft ), nTop, BmpWidth(::hBmp), nBmpHeight(::hBmp), nOr( 4, 32 ) )
               #else
                  #ifdef __C3__
                      DrawState ( hDC, nil, ::hBmp, , if(::nLeftImg != nil, ::nLeftImg,nLeft ), nTop, BmpWidth(::hBmp), nBmpHeight(::hBmp), nOr( 4, 32 ) )
                  #else
                      DrawMasked( hDC, ::hBmp, nTop, if(::nLeftImg != nil, ::nLeftImg, nLeft ))
                      DisableRec( hDC, {nTop,if(::nLeftImg != nil, ::nLeftImg, nLeft ),;
                                   nTop+bmpheight( ::hBmp),;
                                   if(::nLeftImg != nil, ::nLeftImg, nLeft )+bmpWidth(::hBmp)} )
                  #endif
               #endif
            else
               DrawMasked( hDC, ::hBmp, nTop, if(::nLeftImg != nil, ::nLeftImg, nLeft ))
            endif
         endif
      endif

   else

      if ::nTextAlign == 20
         nTop := aRect[1]
      else
         if empty( ::hBmp )
            if ::nImage > 0
               nTop := aRect[1]+::nHeight/2 - ::oParent:oImageList:nHSize/2
            endif
         else
            nTop := aRect[1]+::nHeight/2 - ::nHBmp/2
         endif
      endif

      nRight -= ::oParent:nMargen

      if ::nImage > 0
         if ::nLeftImg != nil
            ::oParent:oImageList:Draw( hDC, ::nImage, nTop, ::nLeftImg, ::lDisable )
         else
            ::oParent:oImageList:Draw( hDC, ::nImage, nTop, nRight, ::lDisable )
         endif
      else
         // 02-07-2004. NO pintar imagenes si no existen
         if ::hBmp != nil
            #ifdef __HARBOUR__
                DrawState ( hDC, nil, ::hBmp, , if(::nLeftImg != nil, ::nLeftImg,nLeft ), nTop, BmpWidth(::hBmp), nBmpHeight(::hBmp), nOr( 4, 32 ) )
            #else
               #ifdef __C3__
                   DrawState ( hDC, nil, ::hBmp, , if(::nLeftImg != nil, ::nLeftImg,nLeft ), nTop, BmpWidth(::hBmp), nBmpHeight(::hBmp), nOr( 4, 32 ) )
               #else
                   DrawMasked( hDC, ::hBmp, nTop, if(::nLeftImg != nil, ::nLeftImg, nLeft ))
                   DisableRec( hDC, {nTop,if(::nLeftImg != nil, ::nLeftImg, nLeft ),;
                                nTop+bmpheight( ::hBmp),;
                                if(::nLeftImg != nil, ::nLeftImg, nLeft )+bmpWidth(::hBmp)} )
               #endif
            #endif
         endif
      endif

   endif

   if !empty( ::cCaption )
      nTop := aRect[1]
      nBottom := aRect[3]
      if ::nTString != nil
         nTop := aRect[1] + ::nTString
         nBottom := aRect[3] + ::nTString
      endif
      if ::lDisable
         SetTextColor( hDC, nColor )
         nColor := SetTextColor( hDC, CLR_WHITE )
         DrawText( hDC, ::cCaption, {nTop-1, nLeft-1, nBottom-1, nRight - if( ::oPopup != nil, 14,0)-1}, if( ::nTextAlign == nil, ::oParent:nTextAlign, ::nTextAlign ) )
         SetTextColor( hDC, nColor )
         nColor := SetTextColor( hDC, CLR_HGRAY )
         DrawText( hDC, ::cCaption, {nTop, nLeft, nBottom, nRight - if( ::oPopup != nil, 14,0)}, if( ::nTextAlign == nil, ::oParent:nTextAlign, ::nTextAlign ) )
      else
         SetTextColor( hDC, ::nClrText ) // jsn
         DrawText( hDC, ::cCaption, {nTop, nLeft, nBottom, nRight - if( ::oPopup != nil, 14,0)}, if( ::nTextAlign == nil, ::oParent:nTextAlign, ::nTextAlign ) )
      endif
   endif

  // BoxEx( hDC, {0, 0, ::nHeight, ::nWidth} )


  if lOver                       .and.;
     !::lGroup                   .and.;
     ::nSeparator == 0           .and.;
     ::oParent:nTipoSel != SOLID .and.;
     ::oParent:nTipoSel != SOLIDUNDERLINE

    // ::PaintSel( hDC, aRect, lOver )

  endif

  if ::nSeparator > 0

     do case
        case ::nSeparator == 1  // SEPARATOR

        case ::nSeparator == 2  // LINE
             hPen := CreatePen( PS_SOLID, 1, ::nColorSep )
 	     hOldPen := SelectObject( hDC, hPen )
             MoveTo( hDC, nLeft-3, aRect[1]+::nHeight/2)
             LineTo( hDC, nRight, aRect[1]+::nHeight/2)
 	     SelectObject( hDC, hOldPen )
 	     DeleteObject( hPen )
        case ::nSeparator == 3  // INSET
             DrawEdge( hDC, {aRect[1]+::nHeight/2, nLeft, aRect[3]-::nHeight/2, nRight}, BDR_RAISEDINNER, BF_BOTTOM )
        case ::nSeparator == 4  // DOTDOT
             hPen = CreatePen( PS_DOT, 1, ::nColorSep )
             hOldPen = SelectObject( hDC, hPen )
             MoveTo( hDC, nLeft, aRect[1]+::nHeight/2)
             LineTo( hDC, nRight, aRect[1]+::nHeight/2)
 	     SelectObject( hDC, hOldPen )
 	     DeleteObject( hPen )
     endcase
  endif

   if nColor != nil
      SetTextColor( hDC, nColor )
   endif

   if hFont != nil
      SelectObject( hDC, hOldFont )
      if lKillFont
         DeleteObject( hFont )
      endif
   endif

   if ::oPopup != nil
      ::ArrowPopup( hDC, aRect, ::nClrText )
   endif

/*   if ::lOption()
      DrawFocusRect( hDC, aRect[1], aRect[2]+2,aRect[3],aRect[4]-2)
   endif
*/


return nil

**************************************************************************************************
      METHOD PaintSel( hDC, aRect, lOver ) CLASS TVItem
**************************************************************************************************

local nColor
local nColor2
local nOldB, nOldR

nOldB := aRect[3]
nOldR := aRect[4]


if lOver
   nColor  := ::oParent:nClrPOver
   nColor2 := ::oParent:nClrPOver2
else
   nColor  := ::oParent:nClrPSel
   nColor2 := ::oParent:nClrPSel2
endif


do case
   case  ::oParent:nTipoSel == SOLID .OR. ::oParent:nTipoSel == SOLIDUNDERLINE //::oParent:nModeSel == FILLED .OR.

        if nColor2 != nil
           if ::lVGrad
             if ::lMirGrad
                aRect[3] := (( aRect[3]-aRect[1] ) / 2 )
                DegradaSO( hDC, aRect, nColor, nColor2, .t.)
                aRect[1] := aRect[3]
                aRect[3] := nOldB
                DegradaSO( hDC, aRect, nColor2, nColor, .t.)
             else
                DegradaSO( hDC, aRect, nColor, nColor2, .t.)
             endif
          else
             if ::lMirGrad
                aRect[4] := ( aRect[4]-aRect[2] ) / 2
                DegradaSO( hDC, aRect, nColor, nColor2, .f.)
                aRect[2] := aRect[4]
                aRect[4] := nOldR
                DegradaSO( hDC, aRect, nColor2, nColor, .f.)
             else
                DegradaSO( hDC, aRect, nColor, nColor2, .f.)
             endif
          endif
        else
           #ifdef __HARBOUR__
              FillSolidRect( hDC, aRect, nColor )
           #else
              #ifdef __C3__
                 FillSolidRect( hDC, aRect, nColor )
              #else
                 FillSoliRc( hDC, aRect, nColor )
              #endif
           #endif
        endif

   case ::oParent:nTipoSel == XBOX
        nColor := oApp():nClrBar // if( ::oParent:nClrBox != nil, ::oParent:nClrBox, ::oParent:nClrText )
	     //BoxEx( hDC, {aRect[1], aRect[2], aRect[3], aRect[4]}, nColor )
		  //BoxEx( hDC, {aRect[1]+1, aRect[2]+1, aRect[3]-1, aRect[4]-1}, CLR_WHITE )
		  // BoxEx( hDC, {aRect[1], aRect[2], aRect[3], aRect[4]}, nColor )
        RoundBox( hDC, 1, aRect[1], aRect[4]-aRect[1]-1, aRect[ 3 ], 2, 2, nColor, 1 )
		  // hDC, nLeftRect, nTopRect, nRightRect, nBottomRect, nEllipseWidth, nEllipseHeight, hPen )
		  //BoxEx( hDC, {aRect[1]+1, aRect[2]+2, aRect[3]-1, aRect[4]-2}, CLR_WHITE )
        FillSolidRect( hDC, {aRect[1]+1, aRect[2]+2, aRect[3]-1, aRect[4]-2}, CLR_WHITE )

   case ::oParent:nTipoSel == INSET
        aRect[2] += 1
        aRect[4] -= 1

        DrawEdge( hDC, aRect, BDR_RAISEDINNER, BF_RECT )
        //DrawEdge( hDC, aRect, nOr( BDR_SUNKENINNER),BF_RECT )
        //DrawEdge( hDC, aRect, nOr( BDR_RAISEDINNER),BF_RECT )
        //DrawEdge( hDC, aRect, nOr( BDR_SUNKENINNER),BF_RECT )

   case ::oParent:nTipoSel == BUMP

        aRect[2] += 1
        aRect[4] -= 1

        DrawEdge( hDC, aRect, EDGE_BUMP, BF_RECT )

	/*
   case ::oParent:nTipoSel == ETCHED

        aRect[2] += 1
        aRect[4] -= 1

        DrawEdge( hDC, aRect, EDGE_ETCHED, BF_RECT )

   case ::oParent:nTipoSel == RAISED

        aRect[2] += 1
        aRect[4] -= 1

        DrawEdge( hDC, aRect, EDGE_RAISED, BF_RECT )

        //DrawEdge( hDC, aRect, EDGE_SUNKEN, BF_RECT )
        //DrawEdge( hDC, aRect, nOr( BDR_RAISEDINNER, BDR_RAISEDOUTER),BF_BOTTOM )
        //DrawEdge( hDC, aRect, nOr( BDR_SUNKENINNER, BDR_RAISEDOUTER),BF_BOTTOM )
        //DrawEdge( hDC, aRect, nOr( BDR_RAISEDINNER, BDR_SUNKENOUTER),BF_BOTTOM )
        //DrawEdge( hDC, aRect, nOr( BDR_SUNKENINNER, BDR_SUNKENOUTER),BF_BOTTOM )
        //DrawEdge( hDC, aRect, EDGE_BUMP, BF_BOTTOM )
        //DrawEdge( hDC, aRect, EDGE_ETCHED, BF_BOTTOM )
        //DrawEdge( hDC, aRect, EDGE_RAISED, BF_BOTTOM )
        //DrawEdge( hDC, aRect, EDGE_SUNKEN, BF_ADJUST )
        //DrawEdge( hDC, aRect, nOr( BDR_RAISEDINNER, BDR_RAISEDOUTER),BF_DIAGONAL_ENDBOTTOMLEFT )
        //DrawEdge( hDC, aRect, nOr( BDR_SUNKENINNER, BDR_RAISEDOUTER),BF_DIAGONAL_ENDBOTTOMLEFT )
        //DrawEdge( hDC, aRect, nOr( BDR_RAISEDINNER, BDR_SUNKENOUTER),BF_DIAGONAL_ENDBOTTOMLEFT )
        //DrawEdge( hDC, aRect, nOr( BDR_SUNKENINNER, BDR_SUNKENOUTER),BF_DIAGONAL_ENDBOTTOMLEFT )
        //DrawEdge( hDC, aRect, EDGE_BUMP, BF_DIAGONAL_ENDBOTTOMLEFT )
        //DrawEdge( hDC, aRect, EDGE_ETCHED, BF_DIAGONAL_ENDBOTTOMLEFT )
        //DrawEdge( hDC, aRect, EDGE_RAISED, BF_DIAGONAL_ENDBOTTOMLEFT )
        //DrawEdge( hDC, aRect, EDGE_SUNKEN, BF_DIAGONAL_ENDBOTTOMLEFT )
	*/
endcase

return nil

**************************************************************************************************
   METHOD lOption() CLASS TVItem
**************************************************************************************************

local lRet := .f.

if ::oParent:nOption > 0 .and. ::oParent:aItems[::oParent:nOption] == self
   lRet := .t.
endif

return lRet


**************************************************************************************************
    METHOD PaintFondo( hDC, aRect, lOver ) CLASS TVItem
**************************************************************************************************
local nColor
local nColor2
local nOldB, nOldR

nOldB := aRect[3]
nOldR := aRect[4]

if lOver
   nColor := ::oParent:nClrPOver
   nColor2 := ::oParent:nClrPOver2
else
   nColor := ::oParent:nClrPSel
   nColor2 := ::oParent:nClrPSel2
endif

do case
   case ::oParent:nModeSel == SUBRAYADO


   case ::oParent:nModeSel == FILLED

        if nColor2 != nil
           if ::oParent:lVGradSel
             if ::oParent:lMGradSel
                aRect[3] := (( aRect[3]-aRect[1] ) / 2 )
                DegradaSO( hDC, aRect, nColor, nColor2, .t.)
                aRect[1] := aRect[3]
                aRect[3] := nOldB
                DegradaSO( hDC, aRect, nColor2, nColor, .t.)
             else
                DegradaSO( hDC, aRect, nColor, nColor2, .t.)
             endif
          else
             if ::oParent:lMGradSel
                aRect[4] := ( aRect[4]-aRect[2] ) / 2
                DegradaSO( hDC, aRect, nColor, nColor2, .f.)
                aRect[2] := aRect[4]
                aRect[4] := nOldR
                DegradaSO( hDC, aRect, nColor2, nColor, .f.)
             else
                DegradaSO( hDC, aRect, nColor, nColor2, .f.)
             endif
          endif
        else
          #ifdef __HARBOUR__
             FillSolidRect( hDC, aRect, nColor )
          #else
             #ifdef __C3__
                FillSolidRect( hDC, aRect, nColor )
             #else
                FillSoliRc( hDC, aRect, nColor )
             #endif
          #endif
        endif

   /*case ::oParent:nModeSel == SOLIDUNDERLINE

        if ::nClrPSel2 != nil
           if ::lVGrad
             if ::lMirGrad
                aRect[3] := (( aRect[3]-aRect[1] ) / 2 )
                DegradaSO( hDC, aRect, nColor, nColor2, .t.)
                aRect[1] := aRect[3]
                aRect[3] := nOldB
                DegradaSO( hDC, aRect, nColor2, nColor, .t.)
             else
                DegradaSO( hDC, aRect, nColor, nColor2, .t.)
             endif
          else
             if ::lMirGrad
                aRect[4] := ( aRect[4]-aRect[2] ) / 2
                DegradaSO( hDC, aRect, nColor, nColor2, .f.)
                aRect[2] := aRect[4]
                aRect[4] := nOldR
                DegradaSO( hDC, aRect, nColor2, nColor, .f.)
             else
                DegradaSO( hDC, aRect, nColor, nColor2, .f.)
             endif
          endif
        else
          #ifdef __HARBOUR__
             FillSolidRect( hDC, aRect, nColor )
          #else
             FillSoliRc( hDC, aRect, nColor )
          #endif
        endif*/
   // otherwise
   //     #ifdef __HARBOUR__
   //        FillSolidRect( hDC, aRect, ::oParent:nClrPane )
   //     #else
   //        FillSoliRc( hDC, aRect, ::oParent:nClrPane )
   //     #endif

endcase

return nil


**************************************************************************************************
   METHOD ArrowPopup( hDC, aRect, nColor ) CLASS TVItem
**************************************************************************************************

local hBrush := CreateSolidBrush( nColor )
local hOldBrush := SelectObject( hDC, hBrush )
local hPen      := CreatePen( PS_SOLID, 1, nColor )
local hOldPen   := SelectObject( hDC, hPen )
local nTop, nLeft

nTop  := aRect[1] + ((aRect[3]-aRect[1])/2) - 3
nLeft := if( ::lLPopup, 12, aRect[4] - 12 )


if ::lLPopup
   PolyPolygon( hDC, {{nLeft+ 3,nTop        },;
                      {nLeft   ,nTop + 3    },;
                      {nLeft+ 3,nTop + 3 + 3},;
                      {nLeft   ,nTop        } } )

else
   PolyPolygon( hDC, {{nLeft   ,nTop        },;
                      {nLeft+ 3,nTop + 3    },;
                      {nLeft   ,nTop + 3 + 3},;
                      {nLeft   ,nTop        } } )

endif

SelectObject( hDC, hOldBrush )
SelectObject( hDC, hOldPen )

DeleteObject( hPen )
DeleteObject( hBrush )

return nil

*************************************************************************************************
  METHOD SetBold( lBold ) CLASS TVItem
*************************************************************************************************

DEFAULT lBold := .t.

::lSetBold := lBold
::oParent:ResizeItems()
::oParent:Refresh()

return ::lSetBold

*************************************************************************************************
  METHOD SetColor( nColor ) CLASS TVItem
*************************************************************************************************

::oParent:ResetColorsTxt()
::nClrText := nColor
::oParent:Refresh()

return nil

*************************************************************************************************
  METHOD EvalWhen( lFromPaint ) CLASS TVItem
*************************************************************************************************
local lOldDis := ::lDisable

DEFAULT lFromPaint := .f.

if ::bWhen == nil
   ::lDisable := .f.
   return .t.
endif

::lDisable := !eval( ::bWhen, self )


if !lFromPaint
   if lOldDis != ::lDisable
      ::oParent:Refresh()
   endif
endif


return ::lDisable


*************************************************************************************************
      METHOD SetDialog( cResName ) CLASS TVItem
*************************************************************************************************
local othis := self
local oBrush

DEFINE BRUSH oBrush COLOR if( oThis:nClrPane != nil, oThis:nClrPane, oThis:oParent:nClrPane )


DEFINE DIALOG othis:oDlgChild NAME cResName OF ::oParent ;
    BRUSH oBrush


return nil


*************************************************************************************************
      METHOD ActDlg() CLASS TVItem
*************************************************************************************************
local oThis := self


    ACTIVATE DIALOG oThis:oDlgChild NOWAIT ;
             ON INIT ( oThis:oDlgChild:Move( oThis:nTop, 0 ) ) ;
             VALID .f.

    ::lDlgAct     := .T.


return nil

#pragma BEGINDUMP

#include <windows.h>
#include <hbapi.h>

HB_FUNC( ROUNDBOX )
{
   HDC hDC = ( HDC ) hb_parni( 1 );
   HBRUSH hBrush = ( HBRUSH ) GetStockObject( 5 );
   HBRUSH hOldBrush = ( HBRUSH ) SelectObject( hDC, hBrush );
   HPEN hPen, hOldPen ;

   if( hb_pcount() > 8 )
      hPen = CreatePen( PS_SOLID, hb_parnl( 9 ), ( COLORREF ) hb_parnl( 8 ) );
   else
      hPen = CreatePen( PS_SOLID, 1, ( COLORREF ) hb_parnl( 8 ) );

   hOldPen = ( HPEN ) SelectObject( hDC, hPen );
   hb_retl( RoundRect( hDC ,
                                 hb_parni( 2 ),
                                 hb_parni( 3 ),
                                 hb_parni( 4 ),
                                 hb_parni( 5 ),
                                 hb_parni( 6 ),
                                 hb_parni( 7 ) ) );

   SelectObject( hDC, hOldBrush );
   DeleteObject( hBrush );
   SelectObject( hDC, hOldPen );
   DeleteObject( hPen );
}

#pragma ENDDUMP