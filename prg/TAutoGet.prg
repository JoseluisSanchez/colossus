// TAutoGet.prg
// Auto complete text in get features
// By: Maurilio Viana, mouri_ryo@hotmail.com
// Date: 4/25/2007
// New features, bug fixes and enhancements are welcome :-)
// Please, let me now when you include new features, bug fixes etc in this class
//
// ToDo: Show drop down window with possible options when typing
//

/* Revisions 4/25/2007 10:49AM by James Bott
Method AutoFill: nKey was not defined as a LOCAL. Fixed.
Method AutoFill: nLength was mispelled (as nLenght). Fixed.
Method AutoFill: ::Cargo changed to ::lAuto (see reason below)
Method AutoFill: Changed to using vkey.ch manifest constants instead of numbers.
Method Redefine: Was passing aItems to the parent method (not needed).
Method LostFocus: Added this method.
Methos New() and Redefine(). Was passing bChanged, and then ::bChange to parent. Fixed.

It is not a good idea to use ::Cargo, ::bPostKey, or ::bLostFocus in the class since these
then cannot be used by the programmer. It would be better to subclass the needed methods and add
whatever functionality needed. So, ::Cargo and ::bLostFocus were eliminated.

Unfortuneately, not using ::bPostKey is somewhat of a challenge. We can subclass KeyDown() and
KeyChar() but some of each method will have to be copied into the new methods and thus if there
are any changes to these sections of code in future versions of TGET, then this method in
TAutoGet will have to be updated also.

Bug?: If the items in ::aArray are in proper case, e.g. "Mauro," they are automatically converted
to proper case when autofilled, however, if you backspace they are converted to all lower case.

*/

#include "fivewin.ch"

//---------------------------------------------------------------------------//

CLASS TAutoGet FROM TGet
   DATA aItems AS ARRAY
   DATA lAuto AS LOGICAL

   METHOD New( nRow    , nCol    , bSetGet  , oWnd     , nWidth   , nHeight,;
               cPict   , bValid  , nClrFore , nClrBack , oFont    , lDesign,;
               oCursor , lPixel  , cMsg     , lUpdate  , bWhen    , lCenter,;
               lRight  , bChanged, lReadOnly, lPassword, lNoBorder, nHelpID,;
               lSpinner, bUp     , bDown    , bMin     , bMax     , aItems  ) CONSTRUCTOR

   METHOD ReDefine( nID     , bSetGet , oWnd     , nHelpId , cPict, bValid ,;
                    nClrFore, nClrBack, oFont    , oCursor , cMsg , lUpdate,;
                    bWhen   , bChanged, lReadOnly, lSpinner, bUp  , bDown  ,;
                    bMin    , bMax, aItems ) CONSTRUCTOR
   METHOD SetItems( aItems )
   METHOD AutoFill()
   METHOD LostFocus( hWndGetFocus ) inline ::SetPos(1), ::lAuto := .t., ::super:LostFocus( hWndGetFocus )
END CLASS

//---------------------------------------------------------------------------//

METHOD New(nRow     , nCol     , bSetGet , oWnd    , nWidth , nHeight , cPict    ,;
           bValid   , nClrFore , nClrBack, oFont   , lDesign, oCursor , lPixel   ,;
           cMsg     , lUpdate  , bWhen   , lCenter , lRight , bChanged, lReadOnly,;
           lPassword, lNoBorder, nHelpId , lSpinner, bUp    , bDown   , bMin     ,;
           bMax     , aItems) CLASS TAutoGet
   local nLen, i

   Super:New(nRow   , nCol    , bSetGet  , oWnd     , nWidth   , nHeight,;
           cPict  , bValid  , nClrFore , nClrBack , oFont    , lDesign,;
           oCursor, lPixel  , cMsg     , lUpdate  , bWhen    , lCenter,;
           lRight , bChanged, lReadOnly, lPassword, lNoBorder, nHelpId,;
           lSpinner, bUp    , bDown    , bMin     , bMax )

   if(aItems == Nil, aItems := {}, )

   ::aItems := aItems

   ::bPostKey := {|oGet, cBuffer| ::AutoFill() }

return( Self )

//---------------------------------------------------------------------------//

METHOD ReDefine(nID      , bSetGet , oWnd   , nHelpId, cPict  , bValid, nClrFore,;
                nClrBack , oFont   , oCursor, cMsg   , lUpdate, bWhen , bChanged,;
                lReadOnly, lSpinner, bUp    , bDown  , bMin   , bMax  , aItems ) CLASS TAutoGet

   Super:ReDefine(nID      , bSetGet , oWnd   , nHelpId, cPict  , bValid, nClrFore ,;
                nClrBack , oFont   , oCursor, cMsg   , lUpdate, bWhen , bChanged,;
                lReadOnly, lSpinner, bUp    , bDown  , bMin   , bMax  )


   if(aItems == Nil, aItems := {}, )

   ::aItems   := aItems

   ::bPostKey := {|oGet, cBuffer| ::AutoFill() }

return( Self )

//---------------------------------------------------------------------------//
// Set items of AutoGet
//---------------------------------------------------------------------------//

METHOD SetItems( aItems ) CLASS TAutoGet
   if(aItems == Nil, aItems := {}, )
   ::aItems   := aItems
return( Nil )

//---------------------------------------------------------------------------//
// Auto fill text when typed based on aItems
// Return: Always returns .T.
//---------------------------------------------------------------------------//

METHOD AutoFill() CLASS TAutoGet
   local nPosItem   := 0                           // Text position into ::aItems
   local nPosCursor := ::nPos                      // Current cursor position
   local nLength    := len(::cText)                // Text length
   local cStartTxt  := left(::cText, nPosCursor-1) // Start text (position 1 to cursor position -1)
   local cItem      := ""
   local nKey       := 0

   if len(::aItems) = 0      // We have no items to search in this GET
      return(.T.)
   endif

   //-------------------------------------------------------------------------
   // We use ::lAuto to control when we must search in ::aItems for typed text
   // We must seek in ::aItems when GET is blank or when user clear it
   //-------------------------------------------------------------------------
   if valtype(::lAuto) != "L" // Cargo isn't logical yet -> GET received focus now
      if ! empty(::Value)     // GET isn't empty
         ::lAuto := .F.       // We don't use autofill
      else                    // GET is empty
         ::lAuto := .T.       // Use autofill
      endif
   else                       // We are controlling if use or no autofill
      if empty(::Value)       // User could cleaned the GET text
         ::lAuto := .T.       // Use autofill
      endif
   endif

   if ! ::lAuto    // If don't control autofill
      return(.t.)
   endif

   nKey := ::nLastKey
   do case
      case nKey == VK_TAB .or. ;
         nKey == VK_RETURN .or. ;
         nKey == VK_DELETE
         ::Assign()           // Assign typed text
      case nKey >= 32 .and. nKey <= 256
         FOR EACH cItem IN ::aItems
            nPosItem += 1
            if ToUpper( cItem ) = ToUpper(cStartTxt)
               nLength := len( rtrim( cItem ) )
               cItem   += space( nLength - len(cItem) )
               ::SetText( cItem )
               ::SetSel( nPosCursor -1, nLength) // Select found text
               ::oGet:Buffer = Pad( cItem, Len( ::oGet:Buffer ))
               return(.t.)
            endif
         NEXT
         ::HideSel()   // Text not found -> Undo selected text
   endcase
return( .T. )

//---------------------------------------------------------------------------//
// Convert latin characters to ANSI upper case
// (for some reason AnsiUpper causes a GPF with Commercial xHB)
//---------------------------------------------------------------------------//

STATIC function ToUpper( cString )
   cString := upper( cString )
   cString := strtran(strtran(strtran(strtran(cString,"á","Á"),"à","À"),"ã","Ã"),"â","Â")
   cString := strtran(strtran(cString,"é","É"),"ê","Ê")
   cString := strtran(cString,"í","Í")
   cString := strtran(strtran(strtran(cString,"ó","Ó"),"õ","Õ"),"ô","Ô")
   cString := strtran(strtran(strtran(cString,"ú","Ú"),"ñ","Ñ"),"ç","Ç")
return( cString )

//---------------------------------------------------------------------------//

