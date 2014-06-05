#include "FiveWin.ch"
#include "c5calen.ch"

function SelecFecha(dFechaPres, oGet)
   local oDlg, oButton1, oButton2, oSayFecha, oCalendar
   local lOk         := .f.
   local dFecha      := IIF(Empty(dFechaPres), Date(), dFechaPres)
   local aPoint      := AdjustWnd(oGet, 97*2, 88*2)

   DEFINE DIALOG oDlg RESOURCE 'Ut_Calendario'     ;
      TITLE "Selección de fecha"                   ;
      COLOR GetSysColor(18), GetSysColor(15)	 		;
		FONT oApp():oFont
   oDlg:lHelpIcon = .f.
   if oApp():cLanguage == "ES"
      REDEFINE C5CALENDAR oCalendar ID 11 OF oDlg  ;
         COLOR CLR_BLACK, GetSysColor(15)-RGB(20,20,20) ;
         COLORTITLE RGB(0,126,255), GetSysColor(15)     ;
         COLORFOCUS CLR_WHITE, RGB(0,126,255)      ;
         DATE dFecha                               ;
         EUROPEAN HEADER BOLD                      ;
         ACTION ( lOk := .t., oDlg:End())          ;
         HILITE SUNDAYS NOBORDER
   else
      REDEFINE C5CALENDAR oCalendar ID 11 OF oDlg  ;
         COLOR CLR_BLACK, GetSysColor(15)-RGB(20,20,20) ;
         COLORTITLE RGB(0,126,255), GetSysColor(15)     ;
         COLORFOCUS CLR_WHITE, RGB(0,126,255)      ;
         DATE dFecha                               ;
         HEADER BOLD                               ;
         ACTION ( lOk := .t., oDlg:End())          ;
         HILITE SUNDAYS NOBORDER
   endif
   oCalendar:oCursor := TCursor():New(,'HAND')
	oCalendar:oFont   := oApp():oFont
   oCalendar:SetSundays( RGB(0,80,255) )

   REDEFINE SAY oSayFecha ;
      PROMPT Month2Str(oCalendar:dDate)+' / '+Str(year(oCalendar:dDate),4) ;
      COLOR  CLR_BLACK, GetSysColor(15) ID 10 OF oDlg

   REDEFINE BUTTON oButton1 ID 20 OF oDlg ;
      ACTION (MesArriba(oSayFecha, oCalendar),SysRefresh())
   oButton1:cToolTip := i18n(" mes anterior ")

   REDEFINE BUTTON oButton2 ID 21 OF oDlg ;
      ACTION (MesAbajo(oSayFecha, oCalendar),SysRefresh())
   oButton2:cToolTip := i18n(" mes siguiente ")

   ACTIVATE DIALOG oDlg               ;
      ON PAINT ( oDlg:Move(aPoint[1], aPoint[2],,,.t.), ;
                 oCalendar:SetFocus(.t.) )

   if lOK
      oGet:cText( oCalendar:dDate )
   endif
return NIL


static function MesArriba(oSayFecha, oCalendar)
   local dFecha := oCalendar:dDate
   dFecha := dFecha - nDiasMes(dFecha)  // esta funcion está en calendar.prg
   oCalendar:Set2Date( , day(dFecha), month(dFecha), Year(dFecha))
   oCalendar:refresh()
   oSayFecha:refresh()
   oCalendar:setFocus()
return nil

static function MesAbajo(oSayFecha, oCalendar)
   local dFecha := oCalendar:dDate

   dFecha := dFecha + nDiasMes(dFecha)  // esta funcion está en calendar.prg
   oCalendar:Set2Date( , day(dFecha), month(dFecha), Year(dFecha))
   oCalendar:refresh()
   oSayFecha:refresh()
   oCalendar:setFocus()
return nil

static function nDiasMes( dDate )
   local nMes, cYear
   local dDay
   local aDays := {31,28,31,30,31,30,31,31,30,31,30,31}
   local nReturn
   local dateformat := set( _SET_DATEFORMAT )

	if empty( dDate )
	   return 0
	endif
	set( _SET_DATEFORMAT, "dd-mm-yyyy" )
	nMes := Month( dDate )
	cYear := str( year( dDate ),4 )
	if nMes == 2
	   if day( ctod( "29-02-" + cYear ) ) != 0
	      nReturn := 29
	   else
	      nReturn := 28
	   endif
	else
	   nReturn := aDays[ nMes ]
	endif
	set( _SET_DATEFORMAT, dateformat )
return nReturn

static function Month2Str(dDate)
   local cReturn
   if oApp():cLanguage == 'ES'
      cReturn := ( {  "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto",;
            "Septiembre", "Octubre", "Noviembre", "Diciembre" }[ Month( dDate ) ] )
   elseif oApp():cLanguage == 'EN'
      cReturn := ( {  "January", "Febrary", "March", "April", "May", "June", "July", "August",;
            "September", "October", "November", "December" }[ Month( dDate ) ] )
   endif
return cReturn

static function Ns2date1( nDia, nMes, nAnio )
   local dReturn
   Local dateformat := set( _SET_DATEFORMAT, "dd-mm-yyyy" )

   dReturn := ctod(strzero(nDia,2)+"-"+strzero(nMes,2)+"-"+str(nAnio,4) )
   set( _SET_DATEFORMAT, dateformat )
return dReturn


function Ns2date( nDia, nMes, nAnio )
   local ddate

   if oApp():cLanguage == 'ES'
      ddate := ctod( strzero(nDia,2)+"-"+strzero(nMes,2)+"-"+str(nAnio,4) )
   else
      ddate := ctod( strzero(nMes,2)+"/"+strzero(nDia,2)+"/"+str(nAnio,4) )
   endif

return ddate
