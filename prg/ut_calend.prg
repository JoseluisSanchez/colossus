#include "FiveWin.ch"
#include "calendar.ch"

Function SelecFecha(dFechaPres, oGet)

   local oDlg, oButton1, oButton2, oSayFecha, oCalendar
   local lOk := .f.
   local dFecha
   local aPoint := AdjustWnd(oGet, 97*2, 88*2)

   IF Empty(dFechaPres)
      dFecha := Date()
   ELSE
      dFecha := dFechaPres
   ENDIF

   DEFINE DIALOG oDlg RESOURCE 'Ut_Calendar'       ;
      TITLE "Selección de fecha"                   ;
      COLOR GetSysColor(18), GetSysColor(15)
   oDlg:lHelpIcon = .f.
   oDlg:SetFont(oApp():oFont)

   REDEFINE CALENDAR oCalendar VAR dFecha ;
      ID 11 OF oDlg DBLCLICK  ( lOk := .t., oDlg:End()) 

   oCalendar:SetFont(oApp():oFont)
	oCalendar:oCursor := TCursor():New(,'HAND')

   ACTIVATE DIALOG oDlg               ;
      ON PAINT ( oDlg:Move(aPoint[1], aPoint[2],,,.t.), ;
                 oCalendar:SetFocus(.t.) )

   if lOK
      oGet:cText( oCalendar:dDate )
      sysrefresh()
   endif

return NIL