#include "Fivewin.ch"

/*_____________________________________________________________________________*/

FUNCTION msginfo(cText, cCaption)
   LOCAL oDlgInfo, oPage
   LOCAL oBmp

   DEFAULT cCaption := oApp():cAppName+oApp():cVersion

   DEFINE DIALOG oDlgInfo RESOURCE "UT_INFO_ES" TITLE cCaption
   oDlgInfo:SetFont(oApp():oFont)

   REDEFINE SAY PROMPT cText ID 10 OF oDlgInfo
   REDEFINE BITMAP oBmp ID 111 OF oDlgInfo RESOURCE "xpinfo" TRANSPARENT

   REDEFINE BUTTON ID IDOK OF oDlgInfo  ;
      ACTION oDlgInfo:End()

   ACTIVATE DIALOG oDlgInfo ;
      ON INIT oDlgInfo:Center( oApp():oWndMain )

RETURN Nil

/*_____________________________________________________________________________*/
FUNCTION msgstop(cText, cCaption)
   LOCAL oDlgStop, oPage
   LOCAL oBmp

   DEFAULT cCaption := oApp():cAppName+oApp():cVersion

   DEFINE DIALOG oDlgStop RESOURCE "UT_INFO_ES" TITLE cCaption
   oDlgStop:SetFont(oApp():oFont)

   REDEFINE SAY PROMPT cText ID 10 OF oDlgStop
   REDEFINE BITMAP oBmp ID 111 OF oDlgStop RESOURCE "xpstop" TRANSPARENT

   REDEFINE BUTTON ID IDOK OF oDlgStop  ;
      ACTION oDlgStop:End()

   ACTIVATE DIALOG oDlgStop ;
      ON INIT oDlgStop:Center( oApp():oWndMain )

RETURN Nil

/*_____________________________________________________________________________*/

FUNCTION msgAlert(cText,cCaption)
   LOCAL oDlgAlert, oPage
   LOCAL oBmp

   DEFAULT cCaption := oApp():cAppName+oApp():cVersion

   DEFINE DIALOG oDlgAlert RESOURCE "UT_INFO_ES" TITLE cCaption
   oDlgAlert:SetFont(oApp():oFont)

   REDEFINE SAY PROMPT cText ID 10 OF oDlgAlert
   REDEFINE BITMAP oBmp ID 111 OF oDlgAlert RESOURCE "xpalert" TRANSPARENT

   REDEFINE BUTTON ID IDOK OF oDlgAlert ;
      ACTION oDlgAlert:End()

   ACTIVATE DIALOG oDlgAlert ;
      ON INIT oDlgAlert:Center( oApp():oWndMain )

RETURN Nil

/*_____________________________________________________________________________*/

FUNCTION MsgYesNo(cText, cCaption )
   LOCAL oDlgYesNo, oPage
   LOCAL oBmp
   LOCAL lRet := .t.

   DEFAULT cCaption := oApp():cAppName+oApp():cVersion

   DEFINE DIALOG oDlgYesNo RESOURCE "UT_YESNO_ES" TITLE cCaption
   oDlgYesNo:SetFont(oApp():oFont)

   REDEFINE SAY PROMPT cText ID 10 OF oDlgYesNo
   REDEFINE BITMAP oBmp ID 111 OF oDlgYesNo RESOURCE "xpquest" TRANSPARENT

   REDEFINE BUTTON ID IDOK OF oDlgYesNo ;
      ACTION (lRet := .t., oDlgYesNo:End())
   REDEFINE BUTTON ID IDCANCEL OF oDlgYesNo ;
      ACTION (lRet := .f., oDlgYesNo:End())

   ACTIVATE DIALOG oDlgYesNo ;
      ON INIT oDlgYesNo:Center( oApp():oWndMain )

RETURN lRet

/*_____________________________________________________________________________*/

FUNCTION c5yesnobig(cText, cCaption)
   LOCAL oDlgYesNo
   LOCAL oBmp
   LOCAL lRet := .t.

   DEFAULT cCaption := oApp():cAppName+oApp():cVersion

   DEFINE DIALOG oDlgYesNo RESOURCE "m5yesnobig" TITLE cCaption
   oDlgYesNo:SetFont(oApp():oFont)

   REDEFINE SAY PROMPT cText ID 10 OF oDlgYesNo
   REDEFINE BITMAP oBmp ID 111 OF oDlgYesNo RESOURCE "xpquest" TRANSPARENT

   REDEFINE BUTTON ID 400 OF oDlgYesNo ;
      ACTION (lRet := .t., oDlgYesNo:End())
   REDEFINE BUTTON ID 401 OF oDlgYesNo ;
      ACTION (lRet := .f., oDlgYesNo:End())

   ACTIVATE DIALOG oDlgYesNo ;
      ON INIT oDlgYesNo:Center( oApp():oWndMain )

RETURN lRet

