/* 
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
    Functin Proper()                  was added by RAMESH BABU P on 19-06-2011
    DATA nCase                        was added by RAMESH BABU P on 19-06-2011
    DATA lAddNewItems                 was added by RAMESH BABU P on 20-06-2011
    DATA bAddNewItem                  was added by RAMESH BABU P on 25-06-2011

    FUNCTION AddNewItem(aItems,cText) was added by RAMESH BABU P on 20-06-2011

    * Revisions 24/06/2011
    Use DBF File
    Method AuroSeek() : Added this method.
    DATA cAlias                       was added by Ghirardini Maurizio P on 24-06-2011
    DATA nIndex                       was added by Ghirardini Maurizio P on 24-06-2011



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
       DATA nCase AS NUMERIC INIT 3           // 1 UPPER CASE, 2 lower case, 3 Proper Case - Added by RAMESH BABU P
       DATA lAddNewItems AS LOGICAL INIT .T.  // .T. to Add New Items to aItems, .F. Don't Add - Added by RAMESH BABU P
       DATA bAddNewItem                       // was added by RAMESH BABU P on 25-06-2011
       DATA cAlias                            // was added by Ghirardini Maurizio P on 24-06-2011
       DATA nIndex                            // was added by Ghirardini Maurizio P on 24-06-2011

       METHOD New( nRow    , nCol    , bSetGet  , oWnd     , nWidth   , nHeight,;
                   cPict   , bValid  , nClrFore , nClrBack , oFont    , lDesign,;
                   oCursor , lPixel  , cMsg     , lUpdate  , bWhen    , lCenter,;
                   lRight  , bChanged, lReadOnly, lPassword, lNoBorder, nHelpID,;
                   lSpinner, bUp     , bDown    , bMin     , bMax     , aItems ,;
                   nCase   , lAddNewItems ,cAlias, nIndex ) CONSTRUCTOR

       METHOD ReDefine( nID     , bSetGet , oWnd     , nHelpId , cPict, bValid ,;
                        nClrFore, nClrBack, oFont    , oCursor , cMsg , lUpdate,;
                        bWhen   , bChanged, lReadOnly, lSpinner, bUp  , bDown  ,;
                        bMin    , bMax, aItems, nCase, lAddNewItems ,cAlias ,nIndex  ) CONSTRUCTOR
       METHOD SetItems( aItems )
       METHOD AutoFill()
       METHOD Autoseek() // Added by Ghirardini Maurizio P on 24-06-2011  
       
       METHOD LostFocus( hWndGetFocus ) inline ::SetPos(1), ::lAuto := .T., IF(::lAddNewItems,AddNewItem(@::aItems,::cText,::cAlias,::bAddNewItem),) ,::super:LostFocus( hWndGetFocus )

    END CLASS

    //---------------------------------------------------------------------------//

    METHOD New(nRow     , nCol     , bSetGet , oWnd    , nWidth , nHeight , cPict    ,;
               bValid   , nClrFore , nClrBack, oFont   , lDesign, oCursor , lPixel   ,;
               cMsg     , lUpdate  , bWhen   , lCenter , lRight , bChanged, lReadOnly,;
               lPassword, lNoBorder, nHelpId , lSpinner, bUp    , bDown   , bMin     ,;
               bMax     , aItems,  nCase, lAddNewItems,cAlias ,nIndex) CLASS TAutoGet

       local nLen, i

       DEFAULT nCase := 3, lAddNewItems := .T.
       DEFAULT cAlias := ""
       DEFAULT nIndex := 0
       
       ::Super:New(nRow   , nCol    , bSetGet  , oWnd     , nWidth   , nHeight,;
               cPict  , bValid  , nClrFore , nClrBack , oFont    , lDesign,;
               oCursor, lPixel  , cMsg     , lUpdate  , bWhen    , lCenter,;
               lRight , bChanged, lReadOnly, lPassword, lNoBorder, nHelpId,;
               lSpinner, bUp    , bDown    , bMin     , bMax )

       if(aItems == Nil, aItems := {}, )

       ::nCase        := nCase           // Added by RAMESH BABU P
       ::lAddNewItems := lAddNewItems    // Added by RAMESH BABU P
       ::cAlias := cAlias                // Added by Ghirardini Maurizio P on 24-06-2011  
       ::nIndex := nIndex                // Added by Ghirardini Maurizio P on 24-06-2011  
       ::aItems := aItems
         
       IF empty(cAlias)
         ::bPostKey := {|oGet, cBuffer| ::AutoFill()}
       ELSE
         ::bPostKey := {|oGet, cBuffer| ::Autoseek()}
       ENDIF

    return( Self )

    //---------------------------------------------------------------------------//

    METHOD ReDefine(nID      , bSetGet , oWnd   , nHelpId, cPict  , bValid, nClrFore,;
                    nClrBack , oFont   , oCursor, cMsg   , lUpdate, bWhen , bChanged,;
                    lReadOnly, lSpinner, bUp    , bDown  , bMin   , bMax  , aItems  ,;
                    nCase, lAddNewItems ,cAlias ,nIndex) CLASS TAutoGet

       DEFAULT nCase := 3, lAddNewItems := .T.
       DEFAULT cAlias := ""
       DEFAULT nIndex := 0


       ::Super:ReDefine(nID      , bSetGet , oWnd   , nHelpId, cPict  , bValid, nClrFore ,;
                    nClrBack , oFont   , oCursor, cMsg   , lUpdate, bWhen , bChanged,;
                    lReadOnly, lSpinner, bUp    , bDown  , bMin   , bMax  )

       if(aItems == Nil, aItems := {}, )

       ::nCase        := nCase           // Added by RAMESH BABU P
       ::lAddNewItems := lAddNewItems    // Added by RAMESH BABU P
       ::cAlias := cAlias                // Added by Ghirardini Maurizio P on 24-06-2011  
       ::nIndex := nIndex                // Added by Ghirardini Maurizio P on 24-06-2011  
       ::aItems := aItems

       IF empty(cAlias)
         ::bPostKey := {|oGet, cBuffer| ::AutoFill()}
       ELSE
         ::bPostKey := {|oGet, cBuffer| ::Autoseek()}
       ENDIF
       

    return( Self )

    //---------------------------------------------------------------------------//
    // Set items of AutoGet
    //---------------------------------------------------------------------------//

    METHOD SetItems( aItems ) CLASS TAutoGet
       if(aItems == Nil, aItems := {}, )
       ::aItems   := aItems
    return( Nil )

    //---------------------------------------------------------------------------//
    // Set items of AutoGet
    //---------------------------------------------------------------------------//

    METHOD AutoSeek() CLASS TAutoGet

       local nPosCursor := ::nPos                      // Current cursor position
       local nLength    := len(::cText)                // Text length
       local cStartTxt  := left(::cText, nPosCursor-1) // Start text (position 1 to cursor position -1)
       local cItem      := ""
       local nKey       := 0
       Local nOrder  := (::cAlias)->(indexord())
       Local lReturn := .F.

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
             select(::calias)
             dbgotop()
             dbseek(cStartTxt,.t.)
             cItem := &( indexKey() )
             if  cItem = ToUpper(cStartTxt, ::nCase)          // ADDED   BY RAMESH BABU P on 19-06-2011
                 nLength := len( rtrim( cItem ) )
                 cItem   += space( nLength - len(cItem) )
                 ::SetText( cItem )
                 ::SetSel( nPosCursor -1, nLength) // Select found text
                 ::oGet:Buffer = Pad( cItem, Len( ::oGet:Buffer )) // add by:ss-bbs
                 lReturn := .T.
             endif
             (::calias)->(dbsetorder(nOrder))
             IF lReturn
                Return .t.
             ENDIF    
             
             
             ::HideSel()   // Text not found -> Undo selected text
       endcase

    Return .t.

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
                //if  ToUpper( cItem )  = ToUpper( cStartTxt )   // REMOVED BY RAMESH BABU P on 19-06-2011
                cItem := ToUpper( cItem,::nCase )                // ADDED   BY RAMESH BABU P on 19-06-2011
               
                if  cItem = ToUpper(cStartTxt, ::nCase)          // ADDED   BY RAMESH BABU P on 19-06-2011
                   nLength := len( rtrim( cItem ) )
                   cItem   += space( nLength - len(cItem) )
                   ::SetText( cItem )
                   ::SetSel( nPosCursor -1, nLength) // Select found text
                   ::oGet:Buffer = Pad( cItem, Len( ::oGet:Buffer )) // add by:ss-bbs
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

    STATIC function ToUpper( cString, nCase )

       if nCase = 2
          cString := lower( cString )
       elseif nCase = 3
          cString := proper( cString )
       else
          cString := upper( cString )
       endif

       cString := strtran(strtran(strtran(strtran(cString,"á","Á"),"à","À"),"ã","Ã"),"â","Â")
       cString := strtran(strtran(cString,"é","É"),"ê","Ê")
       cString := strtran(cString,"í","Í")
       cString := strtran(strtran(strtran(cString,"ó","Ó"),"õ","Õ"),"ô","Ô")
       cString := strtran(strtran(strtran(cString,"ú","Ú"),"ñ","Ñ"),"ç","Ç")

    return( cString )

    //---------------------------------------------------------------------------//
    // ADDED BY RAMESH BABU P on 19-06-2011
    FUNCTION proper(cString)

    LOCAL point,spot,times,char1,char2,char3,char4,char5

    STORE 1 TO point,spot,times
    STORE " " TO char1
    STORE "." TO char2
    STORE "/" TO char3
    STORE "-" TO char4
    STORE "_" TO char5

    * Convert beginning letter of string to Upper Case & last letter to lower case
    cString = UPPER(LEFT(cString,1))+LOWER(RIGHT(cString,LEN(cString)-1))

    * First capitalise every 1st letter in a word after a space and after a dot
    DO WHILE point >0 .AND. times <= 5

       point = AT(char1,SUBSTR(cString,spot,LEN(TRIM(cString))-spot))

       IF point >0
          spot = point + spot
          cString = STUFF(cString,spot,1,UPPER(SUBSTR(cString,spot,1)))
       ELSE
          IF times = 1
             char1 = char2
          ELSEIF times = 2
             char1 = char3
          ELSEIF times = 3
             char1 = char4
          ELSEIF times = 4
             char1 = char5
          ENDIF
          STORE 1 TO  point,spot
          times = times + 1
          IF times >5
               EXIT
          ELSE
              LOOP
          ENDIF
       ENDIF

    ENDDO

    RETURN cString

    //---------------------------------------------------------------------------//

    STATIC FUNCTION AddNewItem(aItems,cText,cAlias,bAddNewItem)

    IF EMPTY(cAlias)
       IF ASCAN(aItems,{|x|UPPER(ALLTRIM(x)) == UPPER(ALLTRIM(cText))}) = 0
          AADD(aItems,cText)
       ENDIF
    ELSE
       IF bAddNewItem != nil
          Eval(bAddNewItem)
       ENDIF
    ENDIF

    RETURN nil
     
    //---------------------------------------------------------------------------//

     

 */