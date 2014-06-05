#include "Fivewin.ch"
#include "Report.ch"
#include "DbStruct.ch"

/*_____________________________________________________________________________*/

FUNCTION TakeOffExt(cFile)
   local nAt := At(".", cFile)
   if nAt > 0
      cFile := Left(cFile, nAt-1)
   endif
RETURN cFile

/*_____________________________________________________________________________*/

FUNCTION GoWeb( cUrl )

   cUrl := allTrim( cUrl )
   IF cURL == ""
      MsgStop("La dirección web está vacia.")
      RETURN NIL
   ENDIF

   IF ! IsWinNt()
      WinExec("start urlto:"+cURL,0)
   ELSE
      WinExec("rundll32.exe url.dll,FileProtocolHandler " + cURL)
   ENDIF

RETURN nil

/*_____________________________________________________________________________*/

FUNCTION GoMail( cMail )

   cMail := allTrim( cMail )
   IF cMail == ""
      MsgStop("La dirección de e-mail está vacia.")
      RETURN NIL
   ENDIF

   IF ! IsWinNt()
      WinExec( "start mailto: " + cMail, 0 )
   ELSE
      WinExec( "rundll32.exe url.dll,FileProtocolHandler mailto:" + cMail )
   ENDIF

RETURN nil
/*_____________________________________________________________________________*/

FUNCTION GoFile( cFile )

   cFile := allTrim( cFile )
   IF cFile == ""
      MsgStop("La ruta del fichero está vacia.")
      RETURN NIL
   ENDIF

   WinExec("rundll32.exe url.dll,FileProtocolHandler " + cFile)
RETURN nil

/*_____________________________________________________________________________*/

FUNCTION ValEmpty( cDato, oGet )

   IF empty( cDato )
      MsgStop( i18n( "Es obligatorio rellenar este campo." ) )
      oGet:setFocus()
      RETURN .F.
   END IF

RETURN .T.

/*_____________________________________________________________________________*/

Function DlgCenter( oDlg,oWnd )
   oDlg:Center( oWnd )
Return NIL

/*_____________________________________________________________________________*/

function SwapUpArray( aArray, nPos )

   local uTmp

   DEFAULT nPos   := len( aArray )

   if nPos <= len( aArray ) .and. nPos > 1
      uTmp              := aArray[nPos]
      aArray[nPos]      := aArray[nPos - 1 ]
      aArray[nPos - 1 ] := uTmp
   end if

return nil

/*_____________________________________________________________________________*/

function SwapDwArray( aArray, nPos )

   local uTmp

   DEFAULT nPos   := len( aArray )

   if nPos < len( aArray ) .and. nPos > 0
      uTmp              := aArray[nPos]
      aArray[nPos]      := aArray[nPos + 1 ]
      aArray[nPos + 1 ] := uTmp
   end if

return nil

/*_____________________________________________________________________________*/

function aGetFont( oWnd )

   local aFont    := {}
   local hDC      := GetDC( oWnd:hWnd)
   local nCounter := 0

   if hDC != 0

      while ( empty( aFont := GetFontNames( hDC ) ) ) .AND. ( ++nCounter ) < 5
      end while

      if empty( aFont )
         msgAlert( i18n("Error al obtener las fuentes.") + CRLF + ;
                    i18n("Sólo podrá usar las fuentes predefinidas.") )
      else
         aSort( aFont,,, { |x, y| upper( x ) < upper( y ) } )
      endif

   else

      msgAlert( i18n("Error al procesar el manejador de la ventana.") + CRLF + ;
                i18n("Sólo podrá usar las fuentes predefinidas.") )

   endif

   ReleaseDC( oWnd:hWnd, hDC )

return aFont

/*_____________________________________________________________________________*/

FUNCTION FillCmb( cAlias, cTag, aCmb, cField, nOrd, nRec, cVar )

   DEFAULT nOrd := ( cAlias )->( ordNumber() ),;
           nRec := ( cAlias )->( recNo() )

   ( cAlias )->( ordSetFocus( cTag ) )
   ( cAlias )->( dbGoTop() )
   DO WHILE ! ( cAlias )->( eof() )
      aAdd( aCmb, ( cAlias )->&cField )
      ( cAlias )->( dbSkip() )
   END WHILE
   ( cAlias )->( dbSetOrder( nOrd ) )
   ( cAlias )->( dbGoTo( nRec ) )
   cVar := iif( len( aCmb ) > 0, aCmb[1], "" )

RETURN nil

/*_____________________________________________________________________________*/

FUNCTION GetFieldWidth( cAlias, cField )

   LOCAL aDbf := ( cAlias )->( dbStruct() )
   LOCAL i    := 0
   LOCAL nLen := len( aDbf )
   LOCAL nPos := 0

   // encuentro la posición del campo a partir del nombre
   FOR i := 1 TO nLen
      IF aDbf[i,1] == cField
         nPos := i
         EXIT
      ENDIF
   NEXT

   // devuelvo el ancho del campo

RETURN ( cAlias )->( dbFieldInfo( DBS_LEN, nPos ) )

/*_____________________________________________________________________________*/

FUNCTION GetDir( oGet )

   LOCAL cFile

   cFile := cGetDir32()

   IF ! empty( cFile )
      oGet:cText := cFile + "\"
   ENDIF

RETURN nil

/*_____________________________________________________________________________*/

FUNCTION RefreshCont()
   oApp():oVMenu:cTitle := i18n("Claves")+tran(CL->(OrdKeyNo()),'999')+" / "+tran(CL->(OrdKeyCount()),'999')
   oApp():oVMenu:refresh()
RETURN nil

/*_____________________________________________________________________________*/

FUNCTION aScanN( aArray, xExpr )
   LOCAL nFound := 0
   LOCAL i      := 0
   LOCAL nLen   := len( aArray )

   IF nLen > 0
      FOR i := 1 TO nLen
         IF aArray[i] == xExpr
            nFound++
         ENDIF
      NEXT
   ENDIF

RETURN nFound

/*_____________________________________________________________________________*/

//FUNCTION GetFreeSystemResources() ; RETURN 0
//FUNCTION nPtrWord() ; RETURN 0

/*_____________________________________________________________________________*/


Function AdjustWnd( oBtn, nWidth, nHeight )
   Local nMaxWidth, nMaxHeight
   Local aPoint

   aPoint := { oBtn:nTop + oBtn:nHeight(), oBtn:nLeft }
   clientToScreen( oBtn:oWnd:hWnd, @aPoint )
   nMaxWidth  := GetSysMetrics(0)
   nMaxHeight := GetSysMetrics(1)

   IF  aPoint[2] + nWidth > nMaxWidth
      aPoint[2] := nMaxWidth -  nWidth
   ENDIF

   IF  aPoint[1] + nHeight > nMaxHeight
      aPoint[1] := nMaxHeight - nHeight
   ENDIF
Return aPoint

/*_____________________________________________________________________________*/

