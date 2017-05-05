#include "fivewin.ch"

#define SRCCOPY 13369376

#define STRETCH_ANDSCANS        1
#define STRETCH_ORSCANS         2
#define STRETCH_DELETESCANS     3

CLASS TC5ImgList

      DATA aBmps
      DATA nColorMask

      DATA hBmpMem

      DATA nWSize, nHSize
      DATA lGrayScale

      METHOD New     ( lGrayScale, nColorMask )  CONSTRUCTOR
      METHOD FromFile( cFileName, nItems, lGrayScale, nColorMask ) CONSTRUCTOR
      METHOD Add     ( cBmp, lIcon )
      METHOD Draw    ( hDC, nImage, nTop, nLeft, lDisable )
      METHOD DrawAlign( hDC, nImage, aRect, lDisable, nAlign )
      METHOD GetCount()       INLINE len( ::aBmps )
      METHOD End     ()       INLINE if( ::hBmpMem != nil, DeleteObject( ::hBmpMem ), ), ::hBmpMem := 0
      METHOD nWidth ( nItem ) INLINE ::aBmps[nItem, 2]
      METHOD nHeight( nItem ) INLINE ::aBmps[nItem, 3]
      METHOD GetBitmap( nItem, nWidth, nHeight )
      METHOD ToFile( nItem, cBmpFile, nWidth, nHeight )
      METHOD ImgList( nImage )

ENDCLASS

//---------------------------------------------------------------------------------------------------
      METHOD New( lGrayScale, nColorMask ) CLASS TC5ImgList
//---------------------------------------------------------------------------------------------------

      if lGrayScale == nil; lGrayScale := .f.; endif
      if nColorMask == nil; nColorMask := rgb( 255, 0, 255 ); endif

      ::aBmps  := {}
      ::lGrayScale := lGrayScale
      ::nColorMask := nColorMask

return self

//---------------------------------------------------------------------------------------------------
      METHOD FromFile( cImage, nItems, lGrayScale, nColorMask ) CLASS TC5ImgList
//---------------------------------------------------------------------------------------------------
local nW, nH
local hBmp
local n

  if nItems == nil; nItems := 1 ; endif
  if lGrayScale == nil; lGrayScale := .f.; endif
  if nColorMask == nil; nColorMask := rgb( 255, 0, 255 ); endif

  ::aBmps      := {}
  ::lGrayScale := lGrayScale
  ::nColorMask := nColorMask

  if valtype( cImage ) == "N"
     ::hBmpMem  := LoadBitmap( GetResources(), cImage )
  else
     if "." $ cImage
        ::hBmpMem  := ReadBitmap( 0, cImage )
     else
        ::hBmpMem  := LoadBitmap( GetResources(), cImage )
     endif
  endif

  if ::lGrayScale
     hBmp := BmpToGray( ::hBmpMem )
     DeleteObject( ::hBmpMem )
     ::hBmpMem := hBmp
  endif

  nW := BmpWidth ( ::hBmpMem )
  nH := BmpHeight( ::hBmpMem )

  ::nWSize := nW / nItems
  ::nHSize := nH

  for n := 1 to nItems
      aadd( ::aBmps, {"", ::nWSize, ::nHSize } )
  next

return self


//---------------------------------------------------------------------------------------------------
    METHOD Add( cImage, lIcon ) CLASS TC5ImgList
//---------------------------------------------------------------------------------------------------

local nEn := 0

local hDC, hDCMem, hDCMem2
local hBmp, hOldBmp, hOldBmp2
local hBmpMemNew
local hBmpMem
local nW, nH
local aRect
local lCreando := .f.
local hBmpConvert

DEFAULT lIcon  := ".ICO" $ upper( cImage )

if empty( cImage )
   return 0
endif

if len( ::aBmps ) > 0
   nEn := ascan( ::aBmps, {|x| x[1] == cImage } )
endif


if nEn > 0
   return nEn
endif

if lIcon
   if "." $ cImage
      hBmp := ExtractIcon( cImage )
   else
      hBmp := LoadIcon( GetResources(), cImage )
   endif
   nH := 32
   nW := 32
else
   if valtype( cImage ) == "N"
      hBmp  := LoadBitmap( GetResources(), cImage )
   else
      if "." $ cImage
         hBmp  := ReadBitmap( 0, cImage )
      else
         hBmp  := LoadBitmap( GetResources(), cImage )
      endif
   endif
   nW := BmpWidth ( hBmp )
   nH := BmpHeight( hBmp )
endif

if len( ::aBmps ) == 0
   ::nWSize := nW
   ::nHSize := nH
   DEFAULT ::nWSize := 32
   DEFAULT ::nHSize := 32
endif



if hBmp != 0

   aadd( ::aBmps, { cImage, nW, nH } )

   hDC     := CreateDC("DISPLAY", 0, 0, 0)

   #ifdef __HARBOUR__
      hDCMem  := CreateCompatibleDC( hDC )
      hDCMem2 := CreateCompatibleDC( hDC )
   #else
      #ifdef __C3__
         hDCMem  := CreateCompatibleDC( hDC )
         hDCMem2 := CreateCompatibleDC( hDC )
      #else
         hDCMem  := CompatDC( hDC )
         hDCMem2 := CompatDC( hDC )
      #endif
   #endif

   aRect   := {0, 0, ::nHSize, ::nWSize*len(::aBmps) }

   if ::hBmpMem == nil

      lCreando := .t.

      #ifdef __HARBOUR__
         ::hBmpMem := CreateCompatibleBitmap( hDC, ::nWSize, ::nHSize )
      #else
         #ifdef __C3__
            ::hBmpMem := CreateCompatibleBitmap( hDC, ::nWSize, ::nHSize )
         #else
            ::hBmpMem := CompatBmp( hDC, ::nWSize, ::nHSize )
         #endif
      #endif

      hOldBmp   := SelectObject( hDCMem, ::hBmpMem )
      #ifdef __HARBOUR__
         FillSolidRect( hDCMem, {0,0,::nHSize, ::nWSize}, RGB( 255,0,255) ) // bug 08-07-2004 ,RGB( 255,0,255) )
      #else
         #ifdef __C3__
            FillSolidRect( hDCMem, {0,0,::nHSize, ::nWSize}, RGB( 255,0,255) ) // bug 08-07-2004 ,RGB( 255,0,255) )
         #else
            FillSoliRc( hDCMem, {0,0,::nHSize, ::nWSize}, RGB( 255,0,255) ) // bug 08-07-2004 ,RGB( 255,0,255) )
         #endif
      #endif

      if ::lGrayScale
         if lIcon
            hBmpConvert := IconToGray( hBmp )
         else
            hBmpConvert := BmpToGray( hBmp )
         endif
         DrawMasked( hDCMem, hBmpConvert, 0, 0 )
         DeleteObject( hBmpConvert )
      else
         if lIcon
            DrawIcon( hDCMem, 0, 0, hBmp )
         else
            DrawMasked( hDCMem, hBmp, 0, 0 )
         endif
      endif

      SelectObject ( hDCMem, hOldBmp )

      DeleteDC     ( hDCMem  )
      DeleteDC     ( hDCMem2 )
      DeleteDC     ( hDC     )

   else

      #ifdef __HARBOUR__
         hBmpMemNew := CreateCompatibleBitmap( hDC, aRect[4], ::nHSize )
      #else
         #ifdef __C3__
            hBmpMemNew := CreateCompatibleBitmap( hDC, aRect[4], ::nHSize )
         #else
            hBmpMemNew := CompatBmp( hDC, aRect[4], ::nHSize )
         #endif
      #endif

      hOldBmp    := SelectObject( hDCMem, hBmpMemNew )
      #ifdef __HARBOUR__
         FillSolidRect( hDCMem, aRect, RGB( 255,0,255) )                   // bug 08-07-2004 ,RGB( 255,0,255) )
      #else
         #ifdef __C3__
            FillSolidRect( hDCMem, aRect, RGB( 255,0,255) )                   // bug 08-07-2004 ,RGB( 255,0,255) )
         #else
            FillSoliRc( hDCMem, aRect, RGB( 255,0,255) )                   // bug 08-07-2004 ,RGB( 255,0,255) )
         #endif
      #endif

      hOldBmp2 := SelectObject( hDCMem2, ::hBmpMem )
      BitBlt( hDCMem, 0, 0, aRect[4]-::nWSize, ::nHSize, hDCMem2, 0, 0, SRCCOPY )

      SelectObject( hDCMem2, hOldBmp2 )
      DeleteObject( ::hBmpMem )

      if ::lGrayScale
         if lIcon
            hBmpConvert := IconToGray( hBmp )
         else
            hBmpConvert := BmpToGray( hBmp )
         endif
         DrawMasked( hDCMem, hBmpConvert, 0, aRect[4]-::nWSize )
         DeleteObject( hBmpConvert )
      else
         if lIcon
            DrawIcon( hDCMem, 0, aRect[4]-::nWSize, hBmp )
         else
            DrawMasked( hDCMem, hBmp, 0, aRect[4]-::nWSize )
         endif
      endif
      SelectObject( hDCMem,  hOldBmp  )

      ::hBmpMem := hBmpMemNew

      DeleteDC( hDCMem )
      DeleteDC( hDCMem2 )
      DeleteDC( hDC )

   endif

   nEn := len( ::aBmps )

   DeleteObject( hBmp )

else
      nEn := 0
endif

return nEn


//---------------------------------------------------------------------------------------------------
    METHOD DrawAlign( hDC, nImage, aRect, lDisable, nAlign ) CLASS TC5ImgList
//---------------------------------------------------------------------------------------------------
local nTop, nLeft, nWidth, nHeight

nTop    := aRect[1]
nLeft   := aRect[2]
nWidth  := aRect[4]-aRect[2]
nHeight := aRect[3]-aRect[1]

/*
 nAlign            1   2   3
                   4   5   6
                   7   8   9
*/

do case
   case nAlign == 1

   case nAlign == 2

        nLeft := nLeft + (nWidth/2) - (::nWidth( nImage )/2)

   case nAlign == 3

        nLeft := nLeft + nWidth - ::nWidth( nImage )

   case nAlign == 4

        nTop := nTop + (nHeight/2) - (::nHeight( nImage ) / 2)

   case nAlign == 5

        nTop := nTop +  (nHeight/2) - (::nHeight( nImage ) / 2)
        nLeft := nLeft + nWidth - ::nWidth( nImage )

   case nAlign == 6

        nTop := nTop   + (nHeight/2) - (::nHeight( nImage ) / 2)
        nLeft := nLeft + nWidth  - ::nWidth( nImage )

   case nAlign == 7

        nTop := nTop + nHeight - ::nHeight( nImage )

   case nAlign == 8

        nTop := nTop + nHeight - ::nHeight( nImage )
        nLeft := nLeft + (nWidth/2) - (::nWidth( nImage )/2)

   case nAlign == 9

        nTop := nTop + nHeight - ::nHeight( nImage )
        nLeft := nLeft + nWidth - ::nWidth( nImage )

endcase

::Draw( hDC, nImage, nTop, nLeft, lDisable )

return nil


//---------------------------------------------------------------------------------------------------
    METHOD Draw( hDC, nImage, nTop, nLeft, lDisable, nWidth, nHeight ) CLASS TC5ImgList
//---------------------------------------------------------------------------------------------------

local hDCMem, hOldBmp, hOldBmp2
local hDC0     := CreateDC("DISPLAY", 0, 0, 0)
local hBmp
local hDCMem2
local iOldMode

DEFAULT lDisable := .f.
DEFAULT nWidth   := ::aBmps[nImage,2]
DEFAULT nHeight  := ::aBmps[nImage,3]


#ifdef __HARBOUR__
   hBmp     := CreateCompatibleBitmap( hDC0, nWidth, nHeight )
#else
   #ifdef __C3__
      hBmp     := CreateCompatibleBitmap( hDC0, nWidth, nHeight )
   #else
      hBmp     := CompatBmp( hDC0, nWidth, nHeight )
   #endif
#endif

#ifdef __HARBOUR__
   hDCMem   := CreateCompatibleDC( hDC0 )
#else
   #ifdef __C3__
      hDCMem   := CreateCompatibleDC( hDC0 )
   #else
      hDCMem   := CompatDC( hDC0 )
   #endif
#endif

hOldBmp  := SelectObject( hDCMem, ::hBmpMem )

#ifdef __HARBOUR__
   hDCMem2  := CreateCompatibleDC( hDC0 )
#else
   #ifdef __C3__
      hDCMem2  := CreateCompatibleDC( hDC0 )
   #else
      hDCMem2  := CompatDC( hDC0 )
   #endif
#endif

hOldBmp2 := SelectObject( hDCMem2, hBmp )
iOldMode = SetStretchBltMode( hDCMem2, STRETCH_DELETESCANS )

StretchBlt( hDCMem2, 0, 0, nWidth, nHeight, hDCMem, ::nWSize*(nImage-1), 0, ::aBmps[nImage,2], ::aBmps[nImage,3], SRCCOPY )

SetStretchBltMode( hDCMem2, iOldMode )

SelectObject( hDCMem,  hOldBmp )
SelectObject( hDCMem2, hOldBmp2 )

DeleteDC( hDCMem  )
DeleteDC( hDCMem2 )
DeleteDC( hDC0    )


if lDisable
   #ifdef __HARBOUR__
      DrawState( hDC, nil, hBmp, nLeft, nTop, nWidth, nHeight, nOr( 4, 32 ) )
   #else
      #ifdef __C3__
         DrawState( hDC, nil, hBmp, nLeft, nTop, nWidth, nHeight, nOr( 4, 32 ) )
      #else
         DrawMasked( hDC, hBmp, nTop, nLeft )
         DisableRec( hDC, {nTop, nLeft , nTop + nWidth, nLeft +nHeight } )
      #endif
   #endif
else
   DrawMasked( hDC, hBmp, nTop, nLeft )
endif

DeleteObject( hBmp )

return nil

*********************************************************************************
 METHOD GetBitmap( nItem, nWidth, nHeight ) CLASS TC5ImgList
*********************************************************************************
local hDCMem, hOldBmp, hOldBmp2
local hDC0     := CreateDC("DISPLAY", 0, 0, 0)
local hBmp

DEFAULT nWidth := ::nWidth( nItem ), nHeight := ::nHeight( nItem )

#ifdef __HARBOUR__
   hBmp     := CreateCompatibleBitmap( hDC0, nWidth, nHeight )
#else
   #ifdef __C3__
      hBmp     := CreateCompatibleBitmap( hDC0, nWidth, nHeight )
   #else
      hBmp     := CompatBmp( hDC0, nWidth, nHeight )
   #endif
#endif

#ifdef __HARBOUR__
   hDCMem   := CreateCompatibleDC( hDC0 )
#else
   #ifdef __C3__
      hDCMem   := CreateCompatibleDC( hDC0 )
   #else
      hDCMem   := CompatDC( hDC0 )
   #endif
#endif

hOldBmp  := SelectObject( hDCMem, hBmp )

FillSolidRect( hDCMem, {0,0,nWidth,nHeight},::nColorMask)

::Draw( hDCMem, nItem, 0, 0, .f., nWidth, nHeight )

SelectObject( hDCMem,  hOldBmp )

DeleteDC( hDCMem  )
DeleteDC( hDC0    )

return hBmp

*********************************************************************************
  METHOD ToFile( nItem, cBmpFile, nWidth, nHeight ) CLASS TC5ImgList
*********************************************************************************

local hBitmap := ::GetBitmap( nItem, nWidth, nHeight )

DibWrite( cBmpFile, DibFromBitmap( hBitmap ) )

DeleteObject( hBitmap )

return nil

*********************************************************************************
  METHOD ImgList( nImage ) CLASS TC5ImgList
*********************************************************************************

local hImageList
local flags
local hBitmap := ::GetBitmap( nImage )
local nColores := Colores()

if nColores > 65536
   flags := 24
elseif nColores == 32768 .or. nColores == 65536
   flags := 16
elseif nColores == 256
   flags := 8
else
   flags := 4
endif

hImageList := ImageList_Create( ::nWSize, ::nHSize, nOr(flags,1), 1 )
ImageList_Add( hImageList, hBitmap )
ImageList_AddMasked( hImageList, hBitmap, ::nColorMask )

DeleteObject( hBitmap )


return hImageList






