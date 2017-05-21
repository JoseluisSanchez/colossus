#include "Fivewin.ch"
#include "xBrowse.ch"

/*_____________________________________________________________________________*/

function Ut_BrwColConfig( oBrowse, cIniEntry )
   local oDlg, oGet, oBtnShow, oBtnHide, oBtnUp, oBtnDown
   local nLen   := Len( oBrowse:aCols )
   local aHeader [ nLen ]
   local aShow   [ nlen ]
   local aSizes  [ nLen ]
	local aArray  [ nLen ]
   local hBmp   := LoadBitmap( 0, 32760 ) // MCS
   local oLbx
   local nShow  := 0
   local cState
   local n, i, oCol

   // Guardo posibles modificaciones manuales
   WritePProString("Browse",cIniEntry,oBrowse:SaveState(),oApp():cIniFile)
   cState := GetPvProfString("Browse", cIniEntry,"", oApp():cIniFile)

   for n := 1 to nLen
      aHeader [ n ] := oBrowse:aCols[ n ]:cHeader
      aShow   [ n ] := ! oBrowse:aCols[ n ]:lHide
      aSizes  [ n ] := oBrowse:aCols[ n ]:nWidth
		aArray  [ n ] := {aShow[n],aHeader[n]}
   next

   DEFINE DIALOG oDlg OF oApp():oWndMain RESOURCE "UT_BRWCONFIG_"+oApp():cLanguage ;
		FONT oApp():oWndMain:oFont

	oLbx := TXBrowse():New( oDlg )
	oLbx:SetArray(aArray)
	Ut_BrwRowConfig( oLbx, )

   oLbx:aCols[1]:cHeader  := i18n("Ver")
   oLbx:aCols[1]:nWidth   := 24
  	oLbx:aCols[1]:AddResource("CHECK")
   oLbx:aCols[1]:AddResource(" ")
   oLbx:aCols[1]:bBmpData := { || if(aArray[oLbx:nArrayAt,1]==.t.,1,2)}
 	olbx:aCols[1]:bStrData := {|| NIL }

   oLbx:aCols[2]:cHeader  := i18n("Columna")
   oLbx:aCols[2]:nWidth   := 90
	oLbx:aCols[2]:nHeadAlign := AL_LEFT

   for i := 1 TO LEN(oLbx:aCols)
      oCol := oLbx:aCols[ i ]
		oCol:bLDClickData  :=  { || iif(aShow[ oLbx:nArrayAt ],oBtnHide:Click(),oBtnShow:Click()) }
   next

	oLbx:CreateFromResource( 100 )

   REDEFINE GET oGet VAR aSizes[ oLbx:nArrayAt ] ;
      ID       101   ;
      SPINNER        ;
      MIN      1     ;
      MAX      999   ;
      PICTURE  "999" ;
      VALID    aSizes[ oLbx:nArrayAt ] > 0 ;
      OF       oDlg

   oGet:bLostFocus := { || ( oGet:SetColor( GetSysColor( 8 ), GetSysColor( 5 ) ) ,;
                             oBrowse:aCols[oLbx:nArrayAt]:nWidth := aSizes[ oLbx:nArrayAt ],;
                             oBrowse:Refresh( .t. ) ) }
   REDEFINE BUTTON ;
      ID       400 ;
      OF       oDlg ;
      ACTION   oDlg:end( IDOK )

   REDEFINE BUTTON ;
      ID       401 ;
      OF       oDlg ;
      ACTION   ( oBrowse:RestoreState( cState ), oDlg:end() )

   REDEFINE BUTTON oBtnShow ;
      ID       402          ;
      OF       oDlg         ;
      ACTION   ( aShow[ oLbx:nArrayAt ] := .t.,;
 					  oLbx:aArrayData[oLbx:nArrayAt,1] := .t., oLbx:Refresh(),;
                 oBrowse:aCols[ oLbx:nArrayAt ]:lHide := .f., oBrowse:Refresh( .t. ) )

   REDEFINE BUTTON oBtnHide ;
      ID       403          ;
      OF       oDlg         ;
      ACTION   IF(Len(oLbx:aArrayData)>1,;
                  ( aShow[ oLbx:nArrayAt ] := .f.,;
 						  oLbx:aArrayData[oLbx:nArrayAt,1] := .f., oLbx:Refresh(),;
                    oBrowse:aCols[ oLbx:nArrayAt ]:lHide := .t., oBrowse:Refresh( .t. ) ),;
                    msgAlert(i18n('No se puede ocultar la columna.'))   )

   REDEFINE BUTTON oBtnUp     ;
      ID       404            ;
      OF       oDlg           ;
      ACTION IIF( oLbx:nArrayAt > 1,;
                ( oBrowse:SwapCols( oBrowse:aCols[ oLbx:nArrayAt], oBrowse:aCols[ oLbx:nArrayAt - 1 ], .t. ),;
                  SwapUpArray( aHeader, oLbx:nArrayAt ) ,;
                  SwapUpArray( aShow  , oLbx:nArrayAt ) ,;
                  SwapUpArray( aSizes , oLbx:nArrayAt ) ,;
						SwapUpArray( aSizes , oLbx:nArrayAt ) ,;
                  SwapUpArray( oLbx:aArrayData, oLbx:nArrayAt ) ,;
						oLbx:nArrayAt --                      ,;
                  oLbx:Refresh()                   ),;
                MsgStop("No se puede desplazar la columna." ))

   REDEFINE BUTTON oBtnDown   ;
      ID       405            ;
      OF       oDlg           ;
      ACTION IIF( oLbx:nArrayAt < nLen,;
                ( oBrowse:SwapCols( oBrowse:aCols[ oLbx:nArrayAt], oBrowse:aCols[ oLbx:nArrayAt + 1 ], .t. ),;
                  SwapDwArray( aHeader, oLbx:nArrayAt ) ,;
                  SwapDwArray( aShow  , oLbx:nArrayAt ) ,;
                  SwapDwArray( aSizes , oLbx:nArrayAt ) ,;
                  SwapDwArray( oLbx:aArrayData, oLbx:nArrayAt ) ,;
                  oLbx:nArrayAt ++                      ,;
                  oLbx:Refresh()                   ),;
                MsgStop("No se puede desplazar la columna." ))

   // TLine():Redefine(oDlg,500)

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)
return NIL

/*_____________________________________________________________________________*/

function Ut_BrwRowConfig( oBrw, cAlias )
	oBrw:nRowSel      := 1
	oBrw:nColSel      := 1
	oBrw:nColOffset   := 1
	oBrw:nFreeze      := 0
	oBrw:nCaptured    := 0
	oBrw:nLastEditCol := 0
	oBrw:l2007	  	  			 := .f.
	oBrw:lMultiselect        := .f.
	oBrw:lTransparent 		 := .f.
	// oBrw:lNoBorder				 := .t.
	oBrw:nStyle       		 -= WS_BORDER
	oBrw:nMarqueeStyle		 := MARQSTYLE_HIGHLROW
	oBrw:nStretchCol 			 := 0
	oBrw:bClrStd   	   	 := {|| { CLR_BLACK, CLR_WHITE } }
	oBrw:bClrRowFocus   	    := {|| { CLR_BLACK, oApp():nClrHL }} 
	oBrw:bClrSelFocus  		 := {|| { CLR_BLACK, oApp():nClrHL }} 
	oBrw:lColDividerComplete := .t.
	oBrw:lRecordSelector     := .t.
	oBrw:nColDividerStyle    := LINESTYLE_LIGHTGRAY
	oBrw:nRowDividerStyle    := LINESTYLE_LIGHTGRAY
	oBrw:nHeaderHeight       := 24
	oBrw:nRowHeight          := 22
	oBrw:lExcelCellWise		 := .f.

	if cAlias != NIL
		oBrw:cAlias	 			 := (cAlias)
	endif
return nil

/*_____________________________________________________________________________*/

